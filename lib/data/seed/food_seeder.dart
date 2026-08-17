import 'package:drift/drift.dart';

import '../database/app_database.dart';
import 'food_seed_data.dart';

// Imports the bundled food list: entries missing by name are inserted,
// entries already present get their nutrition/category updated in place (so
// correcting a seed value reaches installs that already synced the old one),
// and non-custom entries no longer present in the list are deleted (so
// trimming a product out of foodSeedData actually removes it from installs
// that already synced it in, not just from fresh installs). Runs on every
// launch (a no-op once nothing's missing, stale, or removed). Never touches
// isCustom rows, even if a user happened to name their own food the same as
// a seed entry.
//
// Returns the names of foods that *would* have been deleted but were kept
// because they're still used by a recipe ingredient — same FK-not-enforced
// situation as FoodSearchSheet's delete action, checked at the application
// level rather than trusted to the database. Callers should surface this
// list to the user so they know to remove the food from those recipes first.
Future<List<String>> syncSeedFoods(AppDatabase db) async {
  final existing = await db.foodsDao.allByName();
  final seedNames = foodSeedData.map((seed) => seed.name).toSet();

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

  final skipped = <String>[];
  for (final food in existing.values) {
    if (food.isCustom || seedNames.contains(food.name)) continue;
    final usedInRecipe = await (db.select(db.recipeIngredients)
          ..where((i) => i.foodId.equals(food.id)))
        .get();
    if (usedInRecipe.isNotEmpty) {
      skipped.add(food.name);
      continue;
    }
    await db.foodsDao.deleteFood(food.id);
  }
  return skipped;
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
