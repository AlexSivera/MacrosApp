import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/database_provider.dart';
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

// Backs the grid's "has meals planned" dot — one range query for every
// visible day rather than one per cell.
final mealPlanEntriesForMonthGridProvider =
    StreamProvider.autoDispose<List<MealPlanEntryDisplay>>((ref) {
  final days = ref.watch(monthGridDaysProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesInRange(days.first, days.last);
});

Set<DateTime> datesWithPlanEntries(List<MealPlanEntryDisplay> entries) =>
    {for (final display in entries) normalizeDate(display.entry.date)};

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
final shoppingListForWeekProvider =
    FutureProvider.autoDispose<List<ShoppingListSection>>((ref) async {
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
