import 'package:drift/drift.dart';
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
    final afterFirstRun = await db.foodsDao.watchAll().first;
    expect(afterFirstRun, hasLength(foodSeedData.length));

    // Simulate a second app launch against the same (now-populated) DB.
    await syncSeedFoods(db);
    final afterSecondRun = await db.foodsDao.watchAll().first;
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
    final all = await db.foodsDao.watchAll().first;
    expect(all, hasLength(foodSeedData.length + 1));
    final custom = all.firstWhere((f) => f.name == 'Mi batido casero');
    expect(custom.isCustom, isTrue);
  });
}
