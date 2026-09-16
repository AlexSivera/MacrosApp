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

// The single date driving the whole Plan semanal screen: which week's grid
// is shown (its Monday) and which day's meal sections are shown below it.
// Kept as one provider (not a separate "selected week" + "selected day"
// pair) so navigating weeks and picking a day chip can never disagree about
// which week is on screen.
final selectedPlanDateProvider = StateProvider<DateTime>((ref) => normalizeDate(DateTime.now()));

final selectedWeekDaysProvider = Provider<List<DateTime>>((ref) {
  final monday = mondayOf(ref.watch(selectedPlanDateProvider));
  return [for (var i = 0; i < 7; i++) monday.add(Duration(days: i))];
});

final mealPlanEntriesForSelectedDateProvider =
    StreamProvider.autoDispose<List<MealPlanEntryDisplay>>((ref) {
  final date = ref.watch(selectedPlanDateProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesForDate(date);
});

// Backs the day chips' "has meals planned" dot — one range query for the
// whole week rather than one per day.
final mealPlanEntriesForWeekProvider =
    StreamProvider.autoDispose<List<MealPlanEntryDisplay>>((ref) {
  final days = ref.watch(selectedWeekDaysProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesInRange(days.first, days.last);
});

Set<DateTime> datesWithPlanEntries(List<MealPlanEntryDisplay> weekEntries) =>
    {for (final display in weekEntries) normalizeDate(display.entry.date)};

Map<MealType, List<MealPlanEntryDisplay>> groupPlanEntriesByMeal(
  List<MealPlanEntryDisplay> entries,
) {
  final grouped = {for (final meal in MealType.values) meal: <MealPlanEntryDisplay>[]};
  for (final entry in entries) {
    grouped[entry.entry.mealType]!.add(entry);
  }
  return grouped;
}

// Resolves every Food/Recipe/RecipeIngredient the currently visible week's
// plan entries reference, then hands them to the pure aggregator — the only
// place in the feature that talks to the DB, so aggregateShoppingList stays
// trivially testable.
final shoppingListForWeekProvider =
    FutureProvider.autoDispose<List<ShoppingListSection>>((ref) async {
  final days = ref.watch(selectedWeekDaysProvider);
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
