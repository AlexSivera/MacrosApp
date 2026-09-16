import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('addFood + watchEntriesForDate resolves the food name via the join', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Avena',
      kcalPer100g: 389,
      proteinPer100g: 17,
      carbsPer100g: 66,
      fatPer100g: 7,
    ));
    final date = DateTime(2026, 9, 14);
    await db.mealPlanDao.addFood(
      date: date,
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 80,
      orderIndex: 0,
    );

    final entries = await db.mealPlanDao.watchEntriesForDate(date).first;
    expect(entries, hasLength(1));
    expect(entries.first.label, 'Avena');
    expect(entries.first.entry.quantityGrams, 80);
  });

  test('watchEntriesInRange only returns entries within [start, end]', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Manzana',
      kcalPer100g: 52,
      proteinPer100g: 0.3,
      carbsPer100g: 14,
      fatPer100g: 0.2,
    ));
    for (final day in [13, 14, 15, 21]) {
      await db.mealPlanDao.addFood(
        date: DateTime(2026, 9, day),
        mealType: MealType.snack,
        foodId: foodId,
        quantityGrams: 100,
        orderIndex: 0,
      );
    }

    final weekEntries = await db.mealPlanDao
        .watchEntriesInRange(DateTime(2026, 9, 14), DateTime(2026, 9, 20))
        .first;
    expect(weekEntries.map((e) => e.entry.date.day), [14, 15]);
  });

  test('nextOrderIndex increments per (date, mealType) slot', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Yogur',
      kcalPer100g: 60,
      proteinPer100g: 4,
      carbsPer100g: 5,
      fatPer100g: 2,
    ));
    final date = DateTime(2026, 9, 14);
    expect(await db.mealPlanDao.nextOrderIndex(date, MealType.breakfast), 0);

    await db.mealPlanDao.addFood(
      date: date,
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
    );
    expect(await db.mealPlanDao.nextOrderIndex(date, MealType.breakfast), 1);
    // A different meal slot on the same day starts its own count from 0.
    expect(await db.mealPlanDao.nextOrderIndex(date, MealType.dinner), 0);
  });

  test('moveEntry updates the date and/or meal type without touching the quantity', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Arroz',
      kcalPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
    ));
    final entryId = await db.mealPlanDao.addFood(
      date: DateTime(2026, 9, 14),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 150,
      orderIndex: 0,
    );

    await db.mealPlanDao.moveEntry(entryId, newMealType: MealType.dinner);
    var entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 14)).first;
    expect(entries.single.entry.mealType, MealType.dinner);
    expect(entries.single.entry.quantityGrams, 150);

    await db.mealPlanDao.moveEntry(entryId, newDate: DateTime(2026, 9, 15));
    entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 14)).first;
    expect(entries, isEmpty);
    entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 15)).first;
    expect(entries.single.entry.mealType, MealType.dinner);
  });

  test('updateEntryQuantity overwrites grams/servings, nothing else', () async {
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Ensalada'));
    final entryId = await db.mealPlanDao.addRecipe(
      date: DateTime(2026, 9, 14),
      mealType: MealType.lunch,
      recipeId: recipeId,
      servings: 1,
      orderIndex: 0,
    );

    await db.mealPlanDao.updateEntryQuantity(entryId, servings: 2.5);
    final entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 14)).first;
    expect(entries.single.entry.servings, 2.5);
    expect(entries.single.entry.recipeId, recipeId);
  });

  test('deleteEntry removes the row', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Plátano',
      kcalPer100g: 89,
      proteinPer100g: 1.1,
      carbsPer100g: 23,
      fatPer100g: 0.3,
    ));
    final entryId = await db.mealPlanDao.addFood(
      date: DateTime(2026, 9, 14),
      mealType: MealType.snack,
      foodId: foodId,
      quantityGrams: 120,
      orderIndex: 0,
    );

    await db.mealPlanDao.deleteEntry(entryId);
    final entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 14)).first;
    expect(entries, isEmpty);
  });

  test('resetAllData wipes planned meals too', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Nueces',
      kcalPer100g: 654,
      proteinPer100g: 15,
      carbsPer100g: 14,
      fatPer100g: 65,
    ));
    await db.mealPlanDao.addFood(
      date: DateTime(2026, 9, 14),
      mealType: MealType.snack,
      foodId: foodId,
      quantityGrams: 30,
      orderIndex: 0,
    );

    await db.resetAllData();
    final entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 9, 14)).first;
    expect(entries, isEmpty);
  });
}
