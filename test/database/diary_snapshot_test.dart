import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/food_macros_calculator.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('editing a food after it was logged does not change past diary entries', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Arroz blanco',
      kcalPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
    ));
    final food = (await db.foodsDao.getById(foodId))!;
    final macros = scaleFoodMacros(food, 200);

    final entryId = await db.diaryDao.logFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 200,
      orderIndex: 0,
      kcal: macros.kcal,
      proteinG: macros.proteinG,
      carbsG: macros.carbsG,
      fatG: macros.fatG,
    );

    // The user edits the food's calorie value later (e.g. corrects a typo).
    await db.foodsDao.updateFood(food.copyWith(kcalPer100g: 999));

    final entries = await db.diaryDao.watchEntriesForDate(DateTime(2026, 8, 1)).first;
    final loggedEntry = entries.firstWhere((e) => e.entry.id == entryId);
    expect(loggedEntry.entry.kcal, macros.kcal, reason: 'snapshot must not follow the edited food');
    expect(loggedEntry.entry.kcal, isNot(999 * 2), reason: 'must not recompute from the new value');
  });

  test('editing a recipe\'s ingredients after logging it does not change past diary entries', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pasta',
      kcalPer100g: 371,
      proteinPer100g: 13,
      carbsPer100g: 75,
      fatPer100g: 1.5,
    ));
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Pasta sola'));
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: foodId, grams: 100, orderIndex: 0),
    ]);
    // 1 serving of 100g pasta = 371 kcal.
    final entryId = await db.diaryDao.logRecipe(
      date: DateTime(2026, 8, 1),
      mealType: MealType.dinner,
      recipeId: recipeId,
      servings: 1,
      orderIndex: 0,
      kcal: 371,
      proteinG: 13,
      carbsG: 75,
      fatG: 1.5,
    );

    // The user later doubles the recipe's ingredient quantity.
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: foodId, grams: 200, orderIndex: 0),
    ]);

    final entries = await db.diaryDao.watchEntriesForDate(DateTime(2026, 8, 1)).first;
    final loggedEntry = entries.firstWhere((e) => e.entry.id == entryId);
    expect(loggedEntry.entry.kcal, 371, reason: 'past diary day must keep its original snapshot');
  });

  test('editing quantity re-snapshots macros for that entry only', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 11,
    ));
    final food = (await db.foodsDao.getById(foodId))!;
    final initial = scaleFoodMacros(food, 100);
    final entryId = await db.diaryDao.logFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
      kcal: initial.kcal,
      proteinG: initial.proteinG,
      carbsG: initial.carbsG,
      fatG: initial.fatG,
    );

    final updated = scaleFoodMacros(food, 250);
    await db.diaryDao.updateEntryQuantityAndMacros(
      entryId,
      quantityGrams: 250,
      kcal: updated.kcal,
      proteinG: updated.proteinG,
      carbsG: updated.carbsG,
      fatG: updated.fatG,
    );

    final entries = await db.diaryDao.watchEntriesForDate(DateTime(2026, 8, 1)).first;
    final loggedEntry = entries.firstWhere((e) => e.entry.id == entryId);
    expect(loggedEntry.entry.quantityGrams, 250);
    expect(loggedEntry.entry.kcal, closeTo(updated.kcal, 0.01));
  });
}
