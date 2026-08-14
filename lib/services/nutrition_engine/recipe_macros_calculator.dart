import '../../data/database/app_database.dart';
import 'food_macros_calculator.dart';

// ingredients: the (RecipeIngredient, Food) pairs for one recipe — food is
// resolved by the caller (provider layer) since this stays a pure function.
FoodMacros computeRecipeTotals(List<(RecipeIngredient, Food)> ingredients) {
  return ingredients.fold(
    FoodMacros.zero,
    (sum, pair) => sum + scaleFoodMacros(pair.$2, pair.$1.grams),
  );
}

// servings must be > 0 — validated at the recipe editor before save, not
// here, so this stays a pure computation with no error path to reason about.
FoodMacros computePerServing(FoodMacros totals, double servings) => totals / servings;
