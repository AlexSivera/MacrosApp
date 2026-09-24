import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/shopping_list/shopping_list_calculator.dart';

Food _food(int id, String name, {FoodCategory category = FoodCategory.otros}) => Food(
      id: id,
      name: name,
      kcalPer100g: 100,
      proteinPer100g: 10,
      carbsPer100g: 10,
      fatPer100g: 10,
      isCustom: false,
      category: category,
    );

Recipe _recipe(int id, {double servings = 1}) => Recipe(
      id: id,
      name: 'Receta $id',
      category: RecipeCategory.lunch,
      servings: servings,
      isFavorite: false,
      createdAt: DateTime(2026),
    );

MealPlanEntry _foodEntry({required int id, required int foodId, required double grams}) =>
    MealPlanEntry(
      id: id,
      date: DateTime(2026, 9, 14),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: grams,
      orderIndex: 0,
      isEaten: false,
    );

MealPlanEntry _recipeEntry({required int id, required int recipeId, required double servings}) =>
    MealPlanEntry(
      id: id,
      date: DateTime(2026, 9, 14),
      mealType: MealType.dinner,
      recipeId: recipeId,
      servings: servings,
      orderIndex: 0,
      isEaten: false,
    );

void main() {
  group('aggregateShoppingList', () {
    test('sums grams for repeated food entries', () {
      final chicken = _food(1, 'Pechuga de pollo');
      final entries = [
        _foodEntry(id: 1, foodId: 1, grams: 200),
        _foodEntry(id: 2, foodId: 1, grams: 150),
      ];

      final items = aggregateShoppingList(
        entries: entries,
        foodsById: {1: chicken},
        recipesById: const {},
        ingredientsByRecipeId: const {},
      );

      expect(items, hasLength(1));
      expect(items.single.grams, 350);
    });

    // RecipeIngredients.grams is always for the recipe's whole batch (see
    // recipe_macros_calculator.dart), so a planned quantity of 3 servings of
    // a 2-serving recipe must scale ingredients by 3/2, not by 3.
    test('scales recipe ingredients by planned servings over the recipe batch size', () {
      final rice = _food(1, 'Arroz');
      final chicken = _food(2, 'Pechuga de pollo');
      final recipe = _recipe(10, servings: 2);
      final entries = [_recipeEntry(id: 1, recipeId: 10, servings: 3)];

      final items = aggregateShoppingList(
        entries: entries,
        foodsById: {1: rice, 2: chicken},
        recipesById: {10: recipe},
        ingredientsByRecipeId: {
          10: [
            RecipeIngredient(id: 1, recipeId: 10, foodId: 1, grams: 150, orderIndex: 0),
            RecipeIngredient(id: 2, recipeId: 10, foodId: 2, grams: 200, orderIndex: 1),
          ],
        },
      );

      final byFoodId = {for (final item in items) item.food.id: item.grams};
      expect(byFoodId[1], closeTo(225, 0.01)); // 150 * 3/2
      expect(byFoodId[2], closeTo(300, 0.01)); // 200 * 3/2
    });

    test('combines a plain food entry with the same food used inside a recipe', () {
      final egg = _food(1, 'Huevo');
      final recipe = _recipe(10, servings: 1);
      final entries = [
        _foodEntry(id: 1, foodId: 1, grams: 60),
        _recipeEntry(id: 2, recipeId: 10, servings: 1),
      ];

      final items = aggregateShoppingList(
        entries: entries,
        foodsById: {1: egg},
        recipesById: {10: recipe},
        ingredientsByRecipeId: {
          10: [RecipeIngredient(id: 1, recipeId: 10, foodId: 1, grams: 120, orderIndex: 0)],
        },
      );

      expect(items, hasLength(1));
      expect(items.single.grams, 180);
    });

    test('skips an entry whose food or recipe was deleted', () {
      final entries = [
        _foodEntry(id: 1, foodId: 99, grams: 100),
        _recipeEntry(id: 2, recipeId: 98, servings: 1),
      ];

      final items = aggregateShoppingList(
        entries: entries,
        foodsById: const {},
        recipesById: const {},
        ingredientsByRecipeId: const {},
      );

      expect(items, isEmpty);
    });
  });

  group('groupShoppingListByCategory', () {
    test('groups items by category in FoodCategory declaration order', () {
      final items = [
        ShoppingListItem(food: _food(1, 'Manzana', category: FoodCategory.fruta), grams: 100),
        ShoppingListItem(
          food: _food(2, 'Pechuga de pollo', category: FoodCategory.carnePescado),
          grams: 200,
        ),
        ShoppingListItem(food: _food(3, 'Plátano', category: FoodCategory.fruta), grams: 150),
      ];

      final sections = groupShoppingListByCategory(items);

      expect(sections.map((s) => s.category), [FoodCategory.fruta, FoodCategory.carnePescado]);
      expect(sections.first.items, hasLength(2));
    });
  });
}
