import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/daos/meal_plan_dao.dart';
import 'package:macrosapp/services/nutrition_engine/meal_plan_macros_calculator.dart';

// Eaten entries (logged from the Diario, or ticked off from the plan) freeze
// their macros and name, so editing or deleting a food later never rewrites
// a day that already happened. Planned entries stay live — see
// meal_plan_live_macros_test.dart.
void main() {
  late AppDatabase db;
  final day = DateTime(2026, 8, 1);

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  Future<int> insertRice({bool custom = false}) => db.foodsDao.insert(FoodsCompanion.insert(
        name: 'Arroz blanco',
        kcalPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28,
        fatPer100g: 0.3,
        isCustom: Value(custom),
      ));

  Future<MealPlanEntryDisplay> only() async =>
      (await db.mealPlanDao.watchEntriesForDate(day).first).single;

  test('an entry added as eaten is snapshotted and ignores later food edits', () async {
    final foodId = await insertRice();
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 200,
      orderIndex: 0,
      eaten: true,
    );

    final food = (await db.foodsDao.getById(foodId))!;
    await db.foodsDao.updateFood(food.copyWith(kcalPer100g: 999));

    final display = await only();
    expect(display.entry.isEaten, isTrue);
    expect((await resolveEntryMacros(db, display.entry)).kcal, closeTo(260, 0.01));
  });

  test('deleting the food keeps an eaten entry\'s kcal and name', () async {
    final foodId = await insertRice(custom: true);
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
      eaten: true,
    );

    await db.foodsDao.deleteFood(foodId);

    final display = await only();
    expect(display.label, 'Arroz blanco');
    expect((await resolveEntryMacros(db, display.entry)).kcal, closeTo(130, 0.01));

    // Re-marking it eaten (e.g. via a quantity edit) must not zero it out.
    await db.mealPlanDao.markEaten(display.entry.id);
    expect((await resolveEntryMacros(db, (await only()).entry)).kcal, closeTo(130, 0.01));
  });

  test('markEaten / markPlanned toggle between frozen and live', () async {
    final foodId = await insertRice();
    final id = await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.dinner,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
    );
    expect((await only()).entry.isEaten, isFalse);

    await db.mealPlanDao.markEaten(id);
    final food = (await db.foodsDao.getById(foodId))!;
    await db.foodsDao.updateFood(food.copyWith(kcalPer100g: 200));
    expect((await resolveEntryMacros(db, (await only()).entry)).kcal, closeTo(130, 0.01));

    await db.mealPlanDao.markPlanned(id);
    final planned = (await only()).entry;
    expect(planned.isEaten, isFalse);
    expect(planned.kcal, isNull);
    expect((await resolveEntryMacros(db, planned)).kcal, closeTo(200, 0.01));
  });

  test('changing the quantity of an eaten entry re-snapshots at the new amount', () async {
    final foodId = await insertRice();
    final id = await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
      eaten: true,
    );
    await db.mealPlanDao.updateEntryQuantity(id, quantityGrams: 300);
    expect((await only()).entry.kcal, closeTo(390, 0.01));
  });

  test('restoreEntry puts a deleted entry back exactly as it was', () async {
    final foodId = await insertRice();
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 150,
      orderIndex: 0,
      eaten: true,
    );
    final original = (await only()).entry;
    await db.mealPlanDao.deleteEntry(original.id);
    expect(await db.mealPlanDao.watchEntriesForDate(day).first, isEmpty);

    await db.mealPlanDao.restoreEntry(original);
    expect((await only()).entry, original);
  });

  test('copyMeal repeats a meal slot on another day, eaten when asked', () async {
    final foodId = await insertRice();
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 80,
      orderIndex: 0,
      eaten: true,
    );
    final next = day.add(const Duration(days: 1));
    final copied = await db.mealPlanDao.copyMeal(
      fromDate: day,
      toDate: next,
      mealType: MealType.breakfast,
      eaten: true,
    );
    expect(copied, 1);
    final entries = await db.mealPlanDao.watchEntriesForDate(next).first;
    expect(entries.single.entry.quantityGrams, 80);
    expect(entries.single.entry.isEaten, isTrue);
  });

  test('recentFoodIds returns distinct foods, newest first', () async {
    final a = await insertRice();
    final b = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pollo',
      kcalPer100g: 110,
      proteinPer100g: 23,
      carbsPer100g: 0,
      fatPer100g: 1.5,
    ));
    for (final id in [a, b, a]) {
      await db.mealPlanDao.addFood(
        date: day,
        mealType: MealType.lunch,
        foodId: id,
        quantityGrams: 100,
        orderIndex: 0,
      );
    }
    expect(await db.mealPlanDao.recentFoodIds(), [a, b]);
  });

  test('eatenOnly range query skips planned entries', () async {
    final foodId = await insertRice();
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
      eaten: true,
    );
    await db.mealPlanDao.addFood(
      date: day,
      mealType: MealType.dinner,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
    );
    final eaten = await db.mealPlanDao.watchEntriesInRange(day, day, eatenOnly: true).first;
    expect(eaten, hasLength(1));
    expect(eaten.single.entry.mealType, MealType.lunch);
  });
}
