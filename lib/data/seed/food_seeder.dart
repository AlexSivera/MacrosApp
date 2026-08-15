import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'food_seed_data.dart';

// Imports the bundled food list, inserting only the entries not already
// present (matched by name). Runs on every launch instead of "only if
// empty" so foods added to foodSeedData in an app update actually reach
// installs that already seeded an earlier, smaller list — a no-op query
// once nothing's missing. Mirrors GymApp's syncSeedExercises exactly.
Future<void> syncSeedFoods(AppDatabase db) async {
  final existingNames = await db.foodsDao.allNames();
  final missing = foodSeedData.where((seed) => !existingNames.contains(seed.name));

  final entries = [
    for (final seed in missing)
      FoodsCompanion.insert(
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
      ),
  ];
  if (entries.isNotEmpty) await db.foodsDao.insertAll(entries);
}
