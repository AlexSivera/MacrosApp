import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/seed/food_seed_data.dart';
import 'package:macrosapp/data/seed/food_seeder.dart';

void main() {
  test('syncSeedFoods inserts all seed entries once and is idempotent on relaunch', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    final afterFirstRun = await db.foodsDao.watchFiltered().first;
    expect(afterFirstRun, hasLength(foodSeedData.length));

    // Simulate a second app launch against the same (now-populated) DB.
    await syncSeedFoods(db);
    final afterSecondRun = await db.foodsDao.watchFiltered().first;
    expect(afterSecondRun, hasLength(foodSeedData.length));

    final names = afterSecondRun.map((f) => f.name).toSet();
    expect(names.length, foodSeedData.length, reason: 'no duplicate names should exist');
  });

  test('a custom user-created food survives syncSeedFoods and is flagged isCustom', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Mi batido casero',
      kcalPer100g: 120,
      proteinPer100g: 8,
      carbsPer100g: 15,
      fatPer100g: 2,
      isCustom: const Value(true),
    ));

    await syncSeedFoods(db);
    final all = await db.foodsDao.watchFiltered().first;
    expect(all, hasLength(foodSeedData.length + 1));
    final custom = all.firstWhere((f) => f.name == 'Mi batido casero');
    expect(custom.isCustom, isTrue);
  });

  test('re-running sync after a seed value changes updates the existing row in place', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    final seedFood = foodSeedData.first;
    final before = (await db.foodsDao.allByName())[seedFood.name]!;
    final originalId = before.id;

    // Simulate correcting foodSeedData.first's macros in an app update.
    await db.foodsDao.updateFood(before.copyWith(kcalPer100g: 999));
    await syncSeedFoods(db);

    final all = await db.foodsDao.watchFiltered().first;
    expect(all, hasLength(foodSeedData.length), reason: 'the row should be updated, not duplicated');
    final after = all.firstWhere((f) => f.name == seedFood.name);
    expect(after.id, originalId, reason: 'same row, not a new insert');
    expect(after.kcalPer100g, seedFood.kcalPer100g, reason: 'resynced back to the seed value');
  });

  test('a non-custom food no longer in the seed list is deleted on sync', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    final staleId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Producto descatalogado',
      kcalPer100g: 100,
      proteinPer100g: 5,
      carbsPer100g: 10,
      fatPer100g: 3,
      isCustom: const Value(false),
    ));

    final skipped = await syncSeedFoods(db);

    expect(skipped, isEmpty);
    expect(await db.foodsDao.getById(staleId), isNull);
  });

  test('a stale food still used by a recipe is kept and reported instead of deleted', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    final staleId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Producto descatalogado en receta',
      kcalPer100g: 100,
      proteinPer100g: 5,
      carbsPer100g: 10,
      fatPer100g: 3,
      isCustom: const Value(false),
    ));
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Receta con producto viejo'));
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: staleId, grams: 100, orderIndex: 0),
    ]);

    final skipped = await syncSeedFoods(db);

    expect(skipped, ['Producto descatalogado en receta']);
    expect(await db.foodsDao.getById(staleId), isNotNull, reason: 'kept because a recipe still references it');
  });

  test('a stale food logged in the diary is deleted, and the diary entry keeps its snapshot', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    await syncSeedFoods(db);
    final staleId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Producto descatalogado ya comido',
      kcalPer100g: 100,
      proteinPer100g: 5,
      carbsPer100g: 10,
      fatPer100g: 3,
      isCustom: const Value(false),
    ));
    final today = DateTime.now();
    final entryId = await db.diaryDao.logFood(
      date: today,
      mealType: MealType.snack,
      foodId: staleId,
      quantityGrams: 100,
      orderIndex: 0,
      kcal: 100,
      proteinG: 5,
      carbsG: 10,
      fatG: 3,
    );

    final skipped = await syncSeedFoods(db);

    expect(skipped, isEmpty);
    expect(await db.foodsDao.getById(staleId), isNull);
    final entries = await db.diaryDao.watchEntriesForDate(today).first;
    final entry = entries.firstWhere((e) => e.entry.id == entryId);
    expect(entry.entry.kcal, 100, reason: 'the snapshotted macros survive the food being deleted');
    expect(entry.label, 'Alimento eliminado');
  });
}
