import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/body_weight_dao.dart';
import 'daos/burned_calories_dao.dart';
import 'daos/diary_dao.dart';
import 'daos/foods_dao.dart';
import 'daos/recipe_ingredients_dao.dart';
import 'daos/recipes_dao.dart';
import 'daos/user_profile_dao.dart';
import 'enums.dart';
import 'tables/body_weight_logs_table.dart';
import 'tables/burned_calories_table.dart';
import 'tables/diary_entries_table.dart';
import 'tables/foods_table.dart';
import 'tables/recipe_ingredients_table.dart';
import 'tables/recipes_table.dart';
import 'tables/user_profile_table.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserProfile,
  Foods,
  Recipes,
  RecipeIngredients,
  DiaryEntries,
  BodyWeightLogs,
  BurnedCalories,
], daos: [
  UserProfileDao,
  FoodsDao,
  RecipesDao,
  RecipeIngredientsDao,
  DiaryDao,
  BodyWeightDao,
  BurnedCaloriesDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 3;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(foods, foods.category);
          }
          if (from < 3) {
            await m.addColumn(recipes, recipes.imageBytes);
          }
        },
        beforeOpen: (details) async {
          // Required for onDelete: KeyAction.cascade/setNull to actually take
          // effect — SQLite ignores foreign key constraints unless this is
          // set per connection.
          await customStatement('PRAGMA foreign_keys = ON');
        },
      );

  // Perfil > Configuración > "Restablecer datos" — wipes every user-entered
  // row but keeps the schema and the bundled food seed (re-synced by
  // food_seeder.dart on next launch anyway, so clearing it here would just
  // be undone).
  Future<void> resetAllData() async {
    await transaction(() async {
      await delete(diaryEntries).go();
      await delete(recipeIngredients).go();
      await delete(recipes).go();
      await delete(burnedCalories).go();
      await delete(bodyWeightLogs).go();
      await (delete(foods)..where((f) => f.isCustom.equals(true))).go();
      await delete(userProfile).go();
    });
  }
}

// Cross-platform: a real sqlite3 file (via sqlite3_flutter_libs) on
// Android/iOS/desktop, a wasm sqlite3 database backed by OPFS/IndexedDB
// (via web/sqlite3.wasm + web/drift_worker.js) on web. `web:` is ignored on
// native, `native:`'s defaults (path_provider-based file location) are
// ignored on web.
QueryExecutor _openConnection() {
  return driftDatabase(
    name: 'macrosapp',
    web: DriftWebOptions(
      sqlite3Wasm: Uri.parse('sqlite3.wasm'),
      driftWorker: Uri.parse('drift_worker.js'),
    ),
  );
}
