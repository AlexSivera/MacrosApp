import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/meal_plan_macros_calculator.dart';
import '../../../services/shopping_list/shopping_list_calculator.dart';

DateTime normalizeDate(DateTime date) => DateTime(date.year, date.month, date.day);

DateTime mondayOf(DateTime date) {
  final normalized = normalizeDate(date);
  return normalized.subtract(Duration(days: normalized.weekday - 1));
}

DateTime sundayOf(DateTime date) {
  final normalized = normalizeDate(date);
  return normalized.add(Duration(days: DateTime.daysPerWeek - normalized.weekday));
}

// yyyy-MM-dd, used as the /plan/dia/:fecha route param.
String planDayPathSegment(DateTime date) =>
    '${date.year.toString().padLeft(4, '0')}-'
    '${date.month.toString().padLeft(2, '0')}-'
    '${date.day.toString().padLeft(2, '0')}';

DateTime parsePlanDayPathSegment(String segment) {
  final parts = segment.split('-').map(int.parse).toList();
  return DateTime(parts[0], parts[1], parts[2]);
}

// --- Month calendar (Plan semanal's landing screen) -----------------------

// The month currently shown in the calendar grid, anchored to its 1st day.
final selectedPlanMonthProvider =
    StateProvider<DateTime>((ref) => DateTime(DateTime.now().year, DateTime.now().month, 1));

// Every day the grid renders: full weeks (Mon-Sun) from the week containing
// the 1st of the month through the week containing its last day — a
// Google-Calendar-style grid, so leading/trailing days from adjacent months
// fill out the last row instead of leaving it ragged.
final monthGridDaysProvider = Provider<List<DateTime>>((ref) {
  final month = ref.watch(selectedPlanMonthProvider);
  final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
  final gridStart = mondayOf(month);
  final gridEnd = sundayOf(lastDayOfMonth);
  final dayCount = gridEnd.difference(gridStart).inDays + 1;
  return [for (var i = 0; i < dayCount; i++) gridStart.add(Duration(days: i))];
});

// Backs the grid's per-day meal previews — one range query for every
// visible day rather than one per cell.
final mealPlanEntriesForMonthGridProvider =
    StreamProvider.autoDispose<List<MealPlanEntryDisplay>>((ref) {
  final days = ref.watch(monthGridDaysProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesInRange(days.first, days.last);
});

Map<DateTime, List<MealPlanEntryDisplay>> groupPlanEntriesByDay(
  List<MealPlanEntryDisplay> entries,
) {
  final grouped = <DateTime, List<MealPlanEntryDisplay>>{};
  for (final display in entries) {
    (grouped[normalizeDate(display.entry.date)] ??= []).add(display);
  }
  return grouped;
}

// --- Week view (Plan semanal's alternate, more spacious landing view) -----

enum PlanViewMode { month, week }

// Which of the two landing layouts is showing — the month grid is compact
// but every cell is tiny, so a full-width week list gives more room to
// actually read what's planned that week.
final planViewModeProvider = StateProvider<PlanViewMode>((ref) => PlanViewMode.month);

final selectedPlanWeekStartProvider = StateProvider<DateTime>((ref) => mondayOf(DateTime.now()));

final planWeekDaysProvider = Provider<List<DateTime>>((ref) {
  final monday = ref.watch(selectedPlanWeekStartProvider);
  return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
});

final mealPlanEntriesForWeekViewProvider =
    StreamProvider.autoDispose<List<MealPlanEntryDisplay>>((ref) {
  final days = ref.watch(planWeekDaysProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesInRange(days.first, days.last);
});

// --- A single day's meal sections (PlanDayScreen) --------------------------

final mealPlanEntriesForDateProvider =
    StreamProvider.autoDispose.family<List<MealPlanEntryDisplay>, DateTime>((ref, date) {
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesForDate(date);
});

Map<MealType, List<MealPlanEntryDisplay>> groupPlanEntriesByMeal(
  List<MealPlanEntryDisplay> entries,
) {
  final grouped = {for (final meal in MealType.values) meal: <MealPlanEntryDisplay>[]};
  for (final entry in entries) {
    grouped[entry.entry.mealType]!.add(entry);
  }
  return grouped;
}

// --- Live macros (neither the Diario nor the Plan snapshot them anymore) --

// Per-entry macros, shown on its tile — a Drift data class has proper value
// equality/hashCode (see recipePerServingMacrosProvider's identical use of a
// Recipe as a family key), so MealPlanEntry is a safe, idiomatic family key.
// Deliberately depends only on appDatabaseProvider and point Future queries
// (foodsDao.getById/recipesDao.getById) — never on another provider's own
// watched Drift stream. Chaining onto a StreamProvider.family's `.future`
// here previously hung widget tests: if that parent gets autoDisposed (e.g.
// because the day changed and nothing watches yesterday's entries anymore)
// before its stream delivers a value, the `.future` this depended on never
// resolves, and the `await` above it hangs forever — pump() has no real
// clock to advance and never surfaces that as a timeout on its own.
final entryMacrosProvider = FutureProvider.autoDispose.family<FoodMacros, MealPlanEntry>(
  (ref, entry) => resolveEntryMacros(ref.watch(appDatabaseProvider), entry),
);

// Sums a list of entries' live macros — used for a meal section's kcal pill
// and the Diario's day total alike. Returns null while any entry's macros
// are still loading, so callers can show a placeholder instead of a
// misleadingly-low partial sum.
//
// Takes the `watch` function itself (i.e. call as `sumEntryMacros(ref.watch,
// entries)`) rather than a WidgetRef/Ref, so it works the same from a
// ConsumerWidget's WidgetRef and a Provider's Ref — the two don't share a
// common base type in riverpod, but both expose an identically-shaped
// `watch<T>(ProviderListenable<T>)`.
FoodMacros? sumEntryMacros(
  T Function<T>(ProviderListenable<T>) watch,
  List<MealPlanEntryDisplay> entries,
) {
  var total = FoodMacros.zero;
  for (final display in entries) {
    final macros = watch(entryMacrosProvider(display.entry)).valueOrNull;
    if (macros == null) return null;
    total = total + macros;
  }
  return total;
}

// --- Shopping list (its own week, independent of the calendar month) ------

final shoppingListWeekStartProvider =
    StateProvider<DateTime>((ref) => mondayOf(DateTime.now()));

final shoppingListWeekDaysProvider = Provider<List<DateTime>>((ref) {
  final monday = ref.watch(shoppingListWeekStartProvider);
  return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
});

// Resolves every Food/Recipe/RecipeIngredient the selected week's plan
// entries reference, then hands them to the pure aggregator — the only
// place in the feature that talks to the DB, so aggregateShoppingList stays
// trivially testable.
//
// Deliberately not `.autoDispose`: ShoppingListScreen swaps this provider's
// only consumer out of the tree whenever the week is switched to manual
// mode, and swaps it back on return. Disposing on that swap would force a
// cold restart of `watchEntriesInRange(...).first` on every toggle back —
// Drift delivers a stream's very first value via a real Timer, which is a
// no-op delay in the real app but doesn't exist under flutter_test's
// fake-async pump() (see the meal_plan/diary hang-bug notes elsewhere in
// this file), so autoDispose here also made the toggle flaky under test.
final shoppingListForWeekProvider =
    FutureProvider<List<ShoppingListSection>>((ref) async {
  final days = ref.watch(shoppingListWeekDaysProvider);
  final db = ref.watch(appDatabaseProvider);
  final displays = await db.mealPlanDao.watchEntriesInRange(days.first, days.last).first;
  final entries = [for (final display in displays) display.entry];

  final recipeIds = entries.map((e) => e.recipeId).nonNulls.toSet();
  final recipes = await Future.wait(recipeIds.map(db.recipesDao.getById));
  final recipesById = {for (final r in recipes.nonNulls) r.id: r};

  final ingredientsByRecipeId = <int, List<RecipeIngredient>>{
    for (final id in recipeIds) id: await db.recipeIngredientsDao.getForRecipe(id),
  };

  final foodIds = {
    ...entries.map((e) => e.foodId).nonNulls,
    for (final ingredients in ingredientsByRecipeId.values)
      for (final i in ingredients) i.foodId,
  };
  final foods = await Future.wait(foodIds.map(db.foodsDao.getById));
  final foodsById = {for (final f in foods.nonNulls) f.id: f};

  final items = aggregateShoppingList(
    entries: entries,
    foodsById: foodsById,
    recipesById: recipesById,
    ingredientsByRecipeId: ingredientsByRecipeId,
  );
  return groupShoppingListByCategory(items);
});

// --- Manual mode (per-week: automatic aggregation, or a free-text list) ---

// Plain (non-family) StreamProvider watching shoppingListWeekStartProvider
// itself, not a `.family` keyed by it — the same fix as
// diaryEntriesForSelectedDateProvider: shoppingListWeekStartProvider changes
// while ShoppingListScreen stays mounted (prev/next week buttons), and a
// `.family.autoDispose` provider churns a new instance per key in that
// situation, which can leave a first subscription's Future waiting forever
// under widget tests' fake_async clock (see that provider's own comment for
// the full failure mode).
//
// Not `.autoDispose` either, for the same reason as shoppingListForWeekProvider
// above: toggling the mode segmented button swaps this provider's consumer
// out of the tree and back, and a cold restart on every toggle is exactly
// the same real-Timer-vs-fake-clock trap.
final shoppingListModeProvider = StreamProvider<bool>((ref) {
  final weekStart = ref.watch(shoppingListWeekStartProvider);
  return ref.watch(appDatabaseProvider).shoppingListDao.watchMode(weekStart);
});

final shoppingListManualItemsProvider = StreamProvider<List<ShoppingListManualItem>>((ref) {
  final weekStart = ref.watch(shoppingListWeekStartProvider);
  return ref.watch(appDatabaseProvider).shoppingListDao.watchManualItems(weekStart);
});
