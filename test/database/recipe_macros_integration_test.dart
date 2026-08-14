import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/recipe_macros_calculator.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('recipe totals and per-serving are computed from real ingredient rows', () async {
    final riceId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Arroz blanco (crudo)',
      kcalPer100g: 365,
      proteinPer100g: 7.1,
      carbsPer100g: 80,
      fatPer100g: 0.7,
    ));
    final chickenId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    final oilId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Aceite de oliva',
      kcalPer100g: 884,
      proteinPer100g: 0,
      carbsPer100g: 0,
      fatPer100g: 100,
    ));

    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(
      name: 'Pollo con arroz',
      servings: const Value(2),
    ));
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: riceId, grams: 150, orderIndex: 0),
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: chickenId, grams: 200, orderIndex: 1),
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: oilId, grams: 10, orderIndex: 2),
    ]);

    final ingredients = await db.recipeIngredientsDao.getForRecipe(recipeId);
    final foods = await Future.wait(ingredients.map((i) => db.foodsDao.getById(i.foodId)));
    final pairs = [
      for (var i = 0; i < ingredients.length; i++) (ingredients[i], foods[i]!),
    ];
    final totals = computeRecipeTotals(pairs);

    // 150g rice: 547.5 kcal, 200g chicken: 330 kcal, 10g oil: 88.4 kcal = 965.9
    expect(totals.kcal, closeTo(965.9, 0.01));
    final perServing = computePerServing(totals, 2);
    expect(perServing.kcal, closeTo(482.95, 0.01));

    // Changing servings recomputes per-serving without touching totals.
    final perServingSingle = computePerServing(totals, 1);
    expect(perServingSingle.kcal, closeTo(965.9, 0.01));
  });

  test('duplicating a recipe copies its ingredients into a separate recipe', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 11,
    ));
    final originalId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Tortilla'));
    await db.recipeIngredientsDao.replaceIngredients(originalId, [
      RecipeIngredientsCompanion.insert(recipeId: originalId, foodId: foodId, grams: 150, orderIndex: 0),
    ]);

    final duplicateId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Tortilla (copia)'));
    final originalIngredients = await db.recipeIngredientsDao.getForRecipe(originalId);
    await db.recipeIngredientsDao.replaceIngredients(duplicateId, [
      for (final i in originalIngredients)
        RecipeIngredientsCompanion.insert(
          recipeId: duplicateId,
          foodId: i.foodId,
          grams: i.grams,
          orderIndex: i.orderIndex,
        ),
    ]);

    final duplicateIngredients = await db.recipeIngredientsDao.getForRecipe(duplicateId);
    expect(duplicateIngredients, hasLength(1));
    expect(duplicateIngredients.first.grams, 150);

    // Editing the duplicate's ingredients must not affect the original.
    await db.recipeIngredientsDao.replaceIngredients(duplicateId, [
      RecipeIngredientsCompanion.insert(recipeId: duplicateId, foodId: foodId, grams: 300, orderIndex: 0),
    ]);
    final originalStillIntact = await db.recipeIngredientsDao.getForRecipe(originalId);
    expect(originalStillIntact.first.grams, 150);
  });

  test('toggleFavorite flips isFavorite without touching other fields', () async {
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Ensalada'));
    await db.recipesDao.toggleFavorite(recipeId, true);
    var recipe = await db.recipesDao.getById(recipeId);
    expect(recipe!.isFavorite, isTrue);
    expect(recipe.name, 'Ensalada');

    await db.recipesDao.toggleFavorite(recipeId, false);
    recipe = await db.recipesDao.getById(recipeId);
    expect(recipe!.isFavorite, isFalse);
  });

  test('editing a recipe (name, category, servings) persists and leaves untouched ingredients intact',
      () async {
    // Mirrors RecipeEditorScreen._submit()'s update path: fetch the
    // existing row, copyWith the edited fields, updateRecipe — the same
    // sequence the "Editar" flow drives from the UI.
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Avena',
      kcalPer100g: 389,
      proteinPer100g: 17,
      carbsPer100g: 66,
      fatPer100g: 7,
    ));
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(
      name: 'Porridge',
      category: const Value(RecipeCategory.breakfast),
      servings: const Value(1),
    ));
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: foodId, grams: 80, orderIndex: 0),
    ]);

    final existing = await db.recipesDao.getById(recipeId);
    await db.recipesDao.updateRecipe(existing!.copyWith(
      name: 'Porridge de avena',
      category: RecipeCategory.snack,
      servings: 2,
    ));

    final updated = await db.recipesDao.getById(recipeId);
    expect(updated!.name, 'Porridge de avena');
    expect(updated.category, RecipeCategory.snack);
    expect(updated.servings, 2);

    // Ingredients weren't part of this edit, so they must survive untouched.
    final ingredients = await db.recipeIngredientsDao.getForRecipe(recipeId);
    expect(ingredients, hasLength(1));
    expect(ingredients.first.grams, 80);
  });

  test('watchAll filters by category and favorites', () async {
    final id1 = await db.recipesDao.insert(RecipesCompanion.insert(
      name: 'Tostadas',
      category: const Value(RecipeCategory.breakfast),
    ));
    await db.recipesDao.insert(RecipesCompanion.insert(
      name: 'Pasta',
      category: const Value(RecipeCategory.dinner),
    ));
    await db.recipesDao.toggleFavorite(id1, true);

    final breakfasts = await db.recipesDao.watchAll(category: RecipeCategory.breakfast).first;
    expect(breakfasts, hasLength(1));
    expect(breakfasts.first.name, 'Tostadas');

    final favorites = await db.recipesDao.watchAll(favoritesOnly: true).first;
    expect(favorites, hasLength(1));
    expect(favorites.first.name, 'Tostadas');
  });
}
