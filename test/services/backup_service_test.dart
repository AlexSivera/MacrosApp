import 'package:drift/drift.dart' hide isNotNull;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/seed/food_seeder.dart';
import 'package:macrosapp/services/backup/backup_service.dart';

void main() {
  test('export then import onto a fresh database restores everything', () async {
    final source = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(source.close);
    await syncSeedFoods(source);
    await source.userProfileDao.updateProfile(const UserProfileCompanion(
      name: Value('Alex'),
      heightCm: Value(180),
      onboardingCompleted: Value(true),
    ));

    final customFoodId = await source.foodsDao.insert(FoodsCompanion.insert(
      name: 'Batido casero',
      kcalPer100g: 120,
      proteinPer100g: 8,
      carbsPer100g: 15,
      fatPer100g: 2,
      isCustom: const Value(true),
    ));
    final seededFoods = await source.foodsDao.allByName();
    final seededFoodId = seededFoods['Manzana']!.id;

    final recipeId = await source.recipesDao.insert(RecipesCompanion.insert(
      name: 'Receta de prueba',
      servings: const Value(2),
    ));
    await source.recipeIngredientsDao.replaceIngredients(recipeId, [
      RecipeIngredientsCompanion.insert(
          recipeId: recipeId, foodId: customFoodId, grams: 100, orderIndex: 0),
    ]);

    final today = DateTime(2026, 1, 1);
    await source.diaryDao.logFood(
      date: today,
      mealType: MealType.breakfast,
      foodId: seededFoodId,
      quantityGrams: 150,
      orderIndex: 0,
      kcal: 78,
      proteinG: 0.5,
      carbsG: 21,
      fatG: 0.3,
    );
    await source.diaryDao.logRecipe(
      date: today,
      mealType: MealType.lunch,
      recipeId: recipeId,
      servings: 1,
      orderIndex: 0,
      kcal: 240,
      proteinG: 16,
      carbsG: 30,
      fatG: 4,
    );
    await source.bodyWeightDao.insertLog(
      BodyWeightLogsCompanion.insert(date: today, weightKg: 79.5),
    );
    await source.burnedCaloriesDao.insertLog(
      BurnedCaloriesCompanion.insert(date: today, kcal: 300, label: const Value('Correr')),
    );

    final json = await exportBackup(source);

    // A fresh install whose food catalog assigns different ids than the
    // source's — e.g. an extra custom food from a previous session shifted
    // every seeded id up by one. Import must still land on "Manzana" by
    // name, not by the source's (now-wrong) numeric id.
    final target = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(target.close);
    await target.foodsDao.insert(FoodsCompanion.insert(
      name: 'Alimento previo del dispositivo',
      kcalPer100g: 1,
      proteinPer100g: 1,
      carbsPer100g: 1,
      fatPer100g: 1,
      isCustom: const Value(true),
    ));
    await syncSeedFoods(target);
    final targetSeeded = await target.foodsDao.allByName();
    final targetManzanaId = targetSeeded['Manzana']!.id;
    expect(targetManzanaId, isNot(seededFoodId), reason: 'the two DBs must disagree on this id');

    final summary = await importBackup(target, json);

    expect(summary.recipes, 1);
    expect(summary.diaryEntries, 2);
    expect(summary.bodyWeightLogs, 1);
    expect(summary.burnedCalories, 1);

    final profile = await target.userProfileDao.getProfile();
    expect(profile!.name, 'Alex');
    expect(profile.heightCm, 180);

    final restoredCustom = (await target.foodsDao.allByName())['Batido casero'];
    expect(restoredCustom, isNotNull);
    expect(restoredCustom!.kcalPer100g, 120);

    final entries = await target.diaryDao.watchEntriesForDate(today).first;
    expect(entries, hasLength(2));
    final foodEntry = entries.firstWhere((e) => e.entry.foodId != null);
    expect(foodEntry.label, 'Manzana', reason: 'must resolve to the target DB\'s own Manzana row');
    expect(foodEntry.entry.foodId, targetManzanaId);
    expect(foodEntry.entry.kcal, 78);

    final recipeEntry = entries.firstWhere((e) => e.entry.recipeId != null);
    expect(recipeEntry.label, 'Receta de prueba');

    final restoredIngredients =
        await target.recipeIngredientsDao.getForRecipe(recipeEntry.entry.recipeId!);
    expect(restoredIngredients, hasLength(1));
    expect(restoredIngredients.single.foodId, restoredCustom.id);

    final weightLog = await target.bodyWeightDao.watchLatest().first;
    expect(weightLog!.weightKg, 79.5);
  });

  test('rejects a file that is not valid JSON or missing the expected shape', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    expect(() => importBackup(db, 'not json'), throwsA(isA<BackupFormatException>()));
    expect(
      () => importBackup(db, '{"foo": "bar"}'),
      throwsA(isA<BackupFormatException>()),
    );
  });
}
