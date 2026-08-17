import 'dart:convert';

import 'package:drift/drift.dart';

import '../../data/database/app_database.dart';

// "Copia de seguridad" (Perfil > Configuración): a portable JSON snapshot of
// everything the user actually created — profile, custom foods, recipes,
// diary history, weight/burned-calorie logs. Deliberately excludes the
// bundled food catalog (~750 rows, see food_seed_data.dart) since
// food_seeder.dart recreates that deterministically from the app itself on
// every launch; including it would just bloat the file.
//
// Foods and recipes are matched/re-inserted by name+content on import
// rather than reusing their exported row id: the catalog's ids aren't
// stable across app versions (a new seed entry can shift what id an
// existing name lands on), so blindly reusing an id from an old backup
// could silently attach a restored diary entry to the wrong food.
const _schemaVersionKey = 'schemaVersion';

Future<String> exportBackup(AppDatabase db) async {
  final profile = await db.userProfileDao.getProfile();
  final recipes = await db.select(db.recipes).get();
  final ingredients = await db.select(db.recipeIngredients).get();
  final diaryEntries = await db.select(db.diaryEntries).get();
  final weightLogs = await db.select(db.bodyWeightLogs).get();
  final burnedCalories = await db.select(db.burnedCalories).get();

  // Every food actually referenced by a diary entry or a recipe ingredient,
  // plus every custom food even if unused so far — not the bundled catalog,
  // which import resolves by name against whatever's already on that device.
  final referencedFoodIds = <int>{
    for (final entry in diaryEntries)
      if (entry.foodId != null) entry.foodId!,
    for (final ingredient in ingredients) ingredient.foodId,
  };
  final allFoods = await db.select(db.foods).get();
  final foods = [
    for (final food in allFoods)
      if (food.isCustom || referencedFoodIds.contains(food.id)) food,
  ];

  final json = {
    _schemaVersionKey: db.schemaVersion,
    'exportedAt': DateTime.now().toIso8601String(),
    'userProfile': profile?.toJson(),
    'foods': [for (final f in foods) f.toJson()],
    'recipes': [for (final r in recipes) r.toJson()],
    'recipeIngredients': [for (final i in ingredients) i.toJson()],
    'diaryEntries': [for (final e in diaryEntries) e.toJson()],
    'bodyWeightLogs': [for (final w in weightLogs) w.toJson()],
    'burnedCalories': [for (final b in burnedCalories) b.toJson()],
  };
  return const JsonEncoder.withIndent('  ').convert(json);
}

class BackupSummary {
  const BackupSummary({
    required this.foods,
    required this.recipes,
    required this.diaryEntries,
    required this.bodyWeightLogs,
    required this.burnedCalories,
  });

  final int foods;
  final int recipes;
  final int diaryEntries;
  final int bodyWeightLogs;
  final int burnedCalories;
}

class BackupFormatException implements Exception {
  BackupFormatException(this.message);
  final String message;
  @override
  String toString() => message;
}

Future<BackupSummary> importBackup(AppDatabase db, String jsonString) async {
  final Map<String, dynamic> data;
  try {
    data = jsonDecode(jsonString) as Map<String, dynamic>;
  } on FormatException {
    throw BackupFormatException('El archivo no es una copia de seguridad válida.');
  }
  if (data[_schemaVersionKey] is! int || data['foods'] is! List) {
    throw BackupFormatException('El archivo no es una copia de seguridad válida.');
  }

  return db.transaction(() async {
    // Profile: upsert into the single existing row rather than reusing the
    // backup's id — updateProfile() already targets whatever row is really
    // there.
    final profileJson = data['userProfile'] as Map<String, dynamic>?;
    if (profileJson != null) {
      final profile = UserProfileData.fromJson(profileJson);
      await db.userProfileDao.updateProfile(profile.toCompanion(true).copyWith(id: const Value.absent()));
    }

    // Foods: reuse an existing row (by exact name) when there's a match,
    // insert a fresh one otherwise — never trust the exported id.
    final foodIdMap = <int, int>{};
    final existingFoodsByName = await db.foodsDao.allByName();
    for (final raw in (data['foods'] as List).cast<Map<String, dynamic>>()) {
      final food = Food.fromJson(raw);
      final existing = existingFoodsByName[food.name];
      if (existing != null) {
        foodIdMap[food.id] = existing.id;
      } else {
        final newId =
            await db.foodsDao.insert(food.toCompanion(true).copyWith(id: const Value.absent()));
        foodIdMap[food.id] = newId;
        // Avoid re-inserting the same name twice within this same import.
        existingFoodsByName[food.name] = food.copyWith(id: newId);
      }
    }

    // Recipes always come in as new rows — there's no "same recipe" concept
    // to dedupe against, unlike foods.
    final recipeIdMap = <int, int>{};
    for (final raw in (data['recipes'] as List).cast<Map<String, dynamic>>()) {
      final recipe = Recipe.fromJson(raw);
      final newId =
          await db.recipesDao.insert(recipe.toCompanion(true).copyWith(id: const Value.absent()));
      recipeIdMap[recipe.id] = newId;
    }

    for (final raw in (data['recipeIngredients'] as List).cast<Map<String, dynamic>>()) {
      final ingredient = RecipeIngredient.fromJson(raw);
      final recipeId = recipeIdMap[ingredient.recipeId];
      final foodId = foodIdMap[ingredient.foodId];
      // Orphaned reference (shouldn't happen from our own export) — skip
      // rather than let one bad row abort the whole restore.
      if (recipeId == null || foodId == null) continue;
      await db.into(db.recipeIngredients).insert(ingredient.toCompanion(true).copyWith(
            id: const Value.absent(),
            recipeId: Value(recipeId),
            foodId: Value(foodId),
          ));
    }

    for (final raw in (data['diaryEntries'] as List).cast<Map<String, dynamic>>()) {
      final entry = DiaryEntry.fromJson(raw);
      final mappedFoodId = entry.foodId != null ? foodIdMap[entry.foodId] : null;
      final mappedRecipeId = entry.recipeId != null ? recipeIdMap[entry.recipeId] : null;
      if (entry.foodId != null && mappedFoodId == null) continue;
      if (entry.recipeId != null && mappedRecipeId == null) continue;
      await db.into(db.diaryEntries).insert(entry.toCompanion(true).copyWith(
            id: const Value.absent(),
            foodId: Value(mappedFoodId),
            recipeId: Value(mappedRecipeId),
          ));
    }

    for (final raw in (data['bodyWeightLogs'] as List).cast<Map<String, dynamic>>()) {
      final log = BodyWeightLog.fromJson(raw);
      await db.bodyWeightDao.insertLog(log.toCompanion(true).copyWith(id: const Value.absent()));
    }

    for (final raw in (data['burnedCalories'] as List).cast<Map<String, dynamic>>()) {
      final entry = BurnedCalory.fromJson(raw);
      await db.burnedCaloriesDao.insertLog(entry.toCompanion(true).copyWith(id: const Value.absent()));
    }

    return BackupSummary(
      foods: foodIdMap.length,
      recipes: recipeIdMap.length,
      diaryEntries: (data['diaryEntries'] as List).length,
      bodyWeightLogs: (data['bodyWeightLogs'] as List).length,
      burnedCalories: (data['burnedCalories'] as List).length,
    );
  });
}
