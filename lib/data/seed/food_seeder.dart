import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'food_seed_data.dart';

// Imports the bundled food list: entries missing by name are inserted, and
// entries already present get their nutrition/category updated in place —
// so correcting a seed value (wrong macros, a rewritten product) actually
// reaches installs that already synced the old one, not just newly-added
// names. Runs on every launch (a no-op once nothing's missing or stale).
// Never touches isCustom rows, even if a user happened to name their own
// food the same as a seed entry.
Future<void> syncSeedFoods(AppDatabase db) async {
  final existing = await db.foodsDao.allByName();

  final toInsert = <FoodsCompanion>[];
  final toUpdate = <Food>[];

  for (final seed in foodSeedData) {
    final current = existing[seed.name];
    if (current == null) {
      toInsert.add(FoodsCompanion.insert(
        name: seed.name,
        kcalPer100g: seed.kcalPer100g,
        proteinPer100g: seed.proteinPer100g,
        carbsPer100g: seed.carbsPer100g,
        fatPer100g: seed.fatPer100g,
        fiberPer100g: Value(seed.fiberPer100g),
        defaultServingGrams: Value(seed.defaultServingGrams),
        servingLabel: Value(seed.servingLabel),
        isCustom: const Value(false),
        category: Value(seed.category),
      ));
    } else if (!current.isCustom && !_matchesSeed(current, seed)) {
      toUpdate.add(current.copyWith(
        kcalPer100g: seed.kcalPer100g,
        proteinPer100g: seed.proteinPer100g,
        carbsPer100g: seed.carbsPer100g,
        fatPer100g: seed.fatPer100g,
        fiberPer100g: Value(seed.fiberPer100g),
        defaultServingGrams: Value(seed.defaultServingGrams),
        servingLabel: Value(seed.servingLabel),
        category: seed.category,
      ));
    }
  }

  if (toInsert.isNotEmpty) await db.foodsDao.insertAll(toInsert);
  for (final food in toUpdate) {
    await db.foodsDao.updateFood(food);
  }
}

bool _matchesSeed(Food current, FoodSeed seed) {
  return current.kcalPer100g == seed.kcalPer100g &&
      current.proteinPer100g == seed.proteinPer100g &&
      current.carbsPer100g == seed.carbsPer100g &&
      current.fatPer100g == seed.fatPer100g &&
      current.fiberPer100g == seed.fiberPer100g &&
      current.defaultServingGrams == seed.defaultServingGrams &&
      current.servingLabel == seed.servingLabel &&
      current.category == seed.category;
}
