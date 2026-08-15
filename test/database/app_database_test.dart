import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() {
    db = AppDatabase.forTesting(NativeDatabase.memory());
  });

  tearDown(() => db.close());

  test('user profile: default row + read', () async {
    await db.userProfileDao.ensureDefaultRow();
    final profile = await db.userProfileDao.getProfile();
    expect(profile, isNotNull);
    expect(profile!.onboardingCompleted, isFalse);
    expect(profile.activityLevel, ActivityLevel.moderate);
  });

  test('foods: insert + search', () async {
    await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    final results = await db.foodsDao.watchFiltered(query: 'pollo').first;
    expect(results, hasLength(1));
    expect(results.first.name, 'Pechuga de pollo');
  });

  test('recipes + ingredients: insert, replace, cascade delete', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Arroz',
      kcalPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
    ));
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Arroz con pollo'));

    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: foodId, grams: 200, orderIndex: 0),
    ]);
    final ingredients = await db.recipeIngredientsDao.getForRecipe(recipeId);
    expect(ingredients, hasLength(1));
    expect(ingredients.first.grams, 200);

    await db.recipesDao.deleteRecipe(recipeId);
    final afterDelete = await db.recipeIngredientsDao.getForRecipe(recipeId);
    expect(afterDelete, isEmpty);
  });

  test('diary entries: log food, watch by date, delete', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 11,
    ));
    final date = DateTime(2026, 8, 13);
    final entryId = await db.diaryDao.logFood(
      date: date,
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
      kcal: 155,
      proteinG: 13,
      carbsG: 1.1,
      fatG: 11,
    );

    final entries = await db.diaryDao.watchEntriesForDate(date).first;
    expect(entries, hasLength(1));
    expect(entries.first.label, 'Huevo');
    expect(entries.first.entry.kcal, 155);

    await db.diaryDao.deleteEntry(entryId);
    expect(await db.diaryDao.watchEntriesForDate(date).first, isEmpty);
  });

  test('body weight logs: insert + latest', () async {
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 1),
      weightKg: 80,
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 10),
      weightKg: 79.2,
    ));
    final latest = await db.bodyWeightDao.watchLatest().first;
    expect(latest!.weightKg, 79.2);
  });

  test('burned calories: insert + watch for date', () async {
    final date = DateTime(2026, 8, 13);
    await db.burnedCaloriesDao.insertLog(BurnedCaloriesCompanion.insert(date: date, kcal: 300));
    final logs = await db.burnedCaloriesDao.watchForDate(date).first;
    expect(logs, hasLength(1));
    expect(logs.first.kcal, 300);
  });
}
