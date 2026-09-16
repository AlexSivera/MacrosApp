import '../../data/database/app_database.dart';
import 'food_macros_calculator.dart';
import 'recipe_macros_calculator.dart';

// Resolves a MealPlanEntry's macros live from whatever it currently points
// to — the Diario and the Plan both need this now that neither snapshots
// macros at add time (see meal_plan_entries_table.dart): editing a food's
// values or a recipe's ingredients is meant to ripple through every day,
// past or future, that references it.
//
// Returns FoodMacros.zero for an entry whose food/recipe was since deleted,
// or a recipe with no servings — never throws, since a deleted reference is
// an expected, everyday state (see FoodSearchSheet's delete action).
Future<FoodMacros> resolveEntryMacros(AppDatabase db, MealPlanEntry entry) async {
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
