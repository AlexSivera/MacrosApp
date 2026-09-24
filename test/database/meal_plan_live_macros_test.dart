import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/meal_plan_macros_calculator.dart';

// A *planned* MealPlanEntry (isEaten = false, the default) never snapshots
// macros — a plan tracks live edits to the food/recipe it points to. Eaten
// entries are frozen instead: see meal_plan_eaten_snapshot_test.dart.
void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('editing a food after it was logged changes what a past day now resolves to', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Arroz blanco',
      kcalPer100g: 130,
      proteinPer100g: 2.7,
      carbsPer100g: 28,
      fatPer100g: 0.3,
    ));
    final entryId = await db.mealPlanDao.addFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 200,
      orderIndex: 0,
    );

    final initial = await resolveEntryMacros(
      db,
      (await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 8, 1)).first)
          .firstWhere((e) => e.entry.id == entryId)
          .entry,
    );
    expect(initial.kcal, closeTo(260, 0.01)); // 200g at 130kcal/100g

    // The user corrects the food's calorie value later.
    final food = (await db.foodsDao.getById(foodId))!;
    await db.foodsDao.updateFood(food.copyWith(kcalPer100g: 999));

    final updated = await resolveEntryMacros(
      db,
      (await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 8, 1)).first)
          .firstWhere((e) => e.entry.id == entryId)
          .entry,
    );
    expect(updated.kcal, closeTo(999 * 2, 0.01), reason: 'past days recompute from the live food');
  });

  test("editing a recipe's ingredients after logging it changes a past day's macros", () async {
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
    final entryId = await db.mealPlanDao.addRecipe(
      date: DateTime(2026, 8, 1),
      mealType: MealType.dinner,
      recipeId: recipeId,
      servings: 1,
      orderIndex: 0,
    );

    // The user later doubles the recipe's ingredient quantity.
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(recipeId: recipeId, foodId: foodId, grams: 200, orderIndex: 0),
    ]);

    final entry = (await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 8, 1)).first)
        .firstWhere((e) => e.entry.id == entryId)
        .entry;
    final macros = await resolveEntryMacros(db, entry);
    expect(macros.kcal, closeTo(742, 0.01), reason: 'past day now reflects the doubled ingredients');
  });

  test('editing quantity changes only that entry, not siblings using the same food', () async {
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 155,
      proteinPer100g: 13,
      carbsPer100g: 1.1,
      fatPer100g: 11,
    ));
    final entryId = await db.mealPlanDao.addFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.breakfast,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
    );
    final otherEntryId = await db.mealPlanDao.addFood(
      date: DateTime(2026, 8, 1),
      mealType: MealType.snack,
      foodId: foodId,
      quantityGrams: 100,
      orderIndex: 0,
    );

    await db.mealPlanDao.updateEntryQuantity(entryId, quantityGrams: 250);

    final entries = await db.mealPlanDao.watchEntriesForDate(DateTime(2026, 8, 1)).first;
    final updated = entries.firstWhere((e) => e.entry.id == entryId).entry;
    final other = entries.firstWhere((e) => e.entry.id == otherEntryId).entry;
    expect(updated.quantityGrams, 250);
    expect(other.quantityGrams, 100, reason: 'a sibling entry is untouched by editing this one');

    final updatedMacros = await resolveEntryMacros(db, updated);
    expect(updatedMacros.kcal, closeTo(155 * 2.5, 0.01));
  });
}
