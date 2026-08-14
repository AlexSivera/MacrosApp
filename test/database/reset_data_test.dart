import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/seed/food_seeder.dart';

void main() {
  test('resetAllData wipes user data but keeps the seeded food catalog', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    await db.userProfileDao.ensureDefaultRow();
    await db.userProfileDao.updateProfile(const UserProfileCompanion(
      name: Value('Alex'),
      onboardingCompleted: Value(true),
    ));
    final customFoodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Mi batido',
      kcalPer100g: 120,
      proteinPer100g: 8,
      carbsPer100g: 15,
      fatPer100g: 2,
      isCustom: const Value(true),
    ));
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Receta test'));
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(
        recipeId: recipeId,
        foodId: customFoodId,
        grams: 100,
        orderIndex: 0,
      ),
    ]);
    await db.diaryDao.logFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.breakfast,
      foodId: customFoodId,
      quantityGrams: 100,
      orderIndex: 0,
      kcal: 120,
      proteinG: 8,
      carbsG: 15,
      fatG: 2,
    );
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime(2026, 8, 1),
      weightKg: 80,
    ));

    final seededCountBefore = (await db.foodsDao.watchAll().first).length;
    expect(seededCountBefore, greaterThan(100)); // seed + the 1 custom food

    await db.resetAllData();

    expect(await db.userProfileDao.getProfile(), isNull);
    expect(await db.recipesDao.watchAll().first, isEmpty);
    expect(await db.diaryDao.watchEntriesForDate(DateTime(2026, 8, 1)).first, isEmpty);
    expect(await db.bodyWeightDao.watchLatest().first, isNull);

    final foodsAfter = await db.foodsDao.watchAll().first;
    expect(foodsAfter.any((f) => f.name == 'Mi batido'), isFalse, reason: 'custom food removed');
    expect(foodsAfter.length, seededCountBefore - 1, reason: 'seeded catalog kept intact');
  });
}
