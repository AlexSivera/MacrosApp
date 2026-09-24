import '../../data/database/app_database.dart';
import 'food_macros_calculator.dart';
import 'recipe_macros_calculator.dart';

// The macros frozen on an eaten entry (see meal_plan_entries_table.dart),
// or null for a planned entry — which resolves live instead.
FoodMacros? snapshotMacros(MealPlanEntry entry) {
  if (!entry.isEaten || entry.kcal == null) return null;
  return FoodMacros(
    kcal: entry.kcal!,
    proteinG: entry.proteinG ?? 0,
    carbsG: entry.carbsG ?? 0,
    fatG: entry.fatG ?? 0,
  );
}

// Resolves a MealPlanEntry's macros: an eaten entry's snapshot when it has
// one, otherwise live from whatever food/recipe it currently points to — so
// editing a food or recipe ripples through planned days but never rewrites
// what was already eaten.
Future<FoodMacros> resolveEntryMacros(AppDatabase db, MealPlanEntry entry) async {
  return snapshotMacros(entry) ?? resolveLiveEntryMacros(db, entry);
}

// Always computes from the live food/recipe, ignoring any snapshot — what
// MealPlanDao freezes when an entry is marked eaten.
//
// Returns FoodMacros.zero for an entry whose food/recipe was since deleted,
// or a recipe with no servings — never throws, since a deleted reference is
// an expected, everyday state (see FoodSearchSheet's delete action).
Future<FoodMacros> resolveLiveEntryMacros(AppDatabase db, MealPlanEntry entry) async {
  if (entry.foodId != null && entry.quantityGrams != null) {
    final food = await db.foodsDao.getById(entry.foodId!);
    return food != null ? scaleFoodMacros(food, entry.quantityGrams!) : FoodMacros.zero;
  }
  if (entry.recipeId != null && entry.servings != null) {
    final recipe = await db.recipesDao.getById(entry.recipeId!);
    if (recipe == null || recipe.servings <= 0) return FoodMacros.zero;
    final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
    final foods = await Future.wait(ingredients.map((i) => db.foodsDao.getById(i.foodId)));
    final pairs = [
      for (var i = 0; i < ingredients.length; i++)
        if (foods[i] != null) (ingredients[i], foods[i]!),
    ];
    final totals = computeRecipeTotals(pairs);
    final perServing = computePerServing(totals, recipe.servings);
    return perServing * entry.servings!;
  }
  return FoodMacros.zero;
}
