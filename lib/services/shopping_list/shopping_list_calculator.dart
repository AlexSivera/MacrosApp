import '../../data/database/app_database.dart';

class ShoppingListItem {
  const ShoppingListItem({required this.food, required this.grams});

  final Food food;
  final double grams;

  ShoppingListItem operator +(double moreGrams) =>
      ShoppingListItem(food: food, grams: grams + moreGrams);
}

class ShoppingListSection {
  const ShoppingListSection({required this.category, required this.items});

  final FoodCategory category;
  final List<ShoppingListItem> items;
}

// Sums grams per Food across every plan entry in a date range: a food entry
// contributes its own quantityGrams, a recipe entry expands into its
// RecipeIngredients scaled by (planned servings / the recipe's own batch
// servings) — RecipeIngredients.grams is always for the recipe's full batch,
// never per serving (see recipe_macros_calculator.dart).
//
// Callers resolve foodsById/recipesById/ingredientsByRecipeId themselves
// (the provider layer, via a handful of DB queries) so this stays a pure,
// easily testable function with no DB access of its own. An entry whose
// food/recipe was since deleted (foodsById/recipesById has no match) is
// silently skipped rather than crashing the whole list. Entries already
// eaten are skipped too: what's been eaten was already bought, so only
// what's still planned for the week is left to buy.
List<ShoppingListItem> aggregateShoppingList({
  required List<MealPlanEntry> entries,
  required Map<int, Food> foodsById,
  required Map<int, Recipe> recipesById,
  required Map<int, List<RecipeIngredient>> ingredientsByRecipeId,
}) {
  final totalGramsByFoodId = <int, double>{};

  void addGrams(int foodId, double grams) {
    totalGramsByFoodId.update(foodId, (g) => g + grams, ifAbsent: () => grams);
  }

  for (final entry in entries) {
    if (entry.isEaten) continue;
    if (entry.foodId != null) {
      addGrams(entry.foodId!, entry.quantityGrams ?? 0);
      continue;
    }
    if (entry.recipeId == null) continue;
    final recipe = recipesById[entry.recipeId];
    if (recipe == null || recipe.servings <= 0) continue;
    final factor = (entry.servings ?? 1) / recipe.servings;
    for (final ingredient in ingredientsByRecipeId[entry.recipeId] ?? const []) {
      addGrams(ingredient.foodId, ingredient.grams * factor);
    }
  }

  final items = [
    for (final e in totalGramsByFoodId.entries)
      if (foodsById[e.key] != null) ShoppingListItem(food: foodsById[e.key]!, grams: e.value),
  ];
  items.sort((a, b) => a.food.name.compareTo(b.food.name));
  return items;
}

// Grouped in FoodCategory's declared order (fruta, verdura, ... otros) so
// the list reads like a produce-first shopping trip rather than alphabetical
// or insertion order.
List<ShoppingListSection> groupShoppingListByCategory(List<ShoppingListItem> items) {
  final byCategory = <FoodCategory, List<ShoppingListItem>>{};
  for (final item in items) {
    (byCategory[item.food.category] ??= []).add(item);
  }
  return [
    for (final category in FoodCategory.values)
      if (byCategory[category] case final items?) ShoppingListSection(category: category, items: items),
  ];
}
