import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

import 'daos/body_weight_dao.dart';
import 'daos/burned_calories_dao.dart';
import 'daos/custom_lists_dao.dart';
import 'daos/foods_dao.dart';
import 'daos/meal_plan_dao.dart';
import 'daos/recipe_ingredients_dao.dart';
import 'daos/recipes_dao.dart';
import 'daos/shopping_list_dao.dart';
import 'daos/user_profile_dao.dart';
import 'enums.dart';
import 'tables/body_weight_logs_table.dart';
import 'tables/burned_calories_table.dart';
import 'tables/custom_list_items_table.dart';
import 'tables/custom_lists_table.dart';
import 'tables/foods_table.dart';
import 'tables/meal_plan_entries_table.dart';
import 'tables/recipe_ingredients_table.dart';
import 'tables/recipes_table.dart';
import 'tables/shopping_list_manual_items_table.dart';
import 'tables/user_profile_table.dart';

export 'enums.dart';

part 'app_database.g.dart';

@DriftDatabase(tables: [
  UserProfile,
  Foods,
  Recipes,
  RecipeIngredients,
  MealPlanEntries,
  BodyWeightLogs,
  BurnedCalories,
  ShoppingListManualItems,
  ShoppingListWeekModes,
  CustomLists,
  CustomListItems,
], daos: [
  UserProfileDao,
  FoodsDao,
  RecipesDao,
  RecipeIngredientsDao,
  MealPlanDao,
  BodyWeightDao,
  BurnedCaloriesDao,
  ShoppingListDao,
  CustomListsDao,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 8;

  @override
  MigrationStrategy get migration => MigrationStrategy(
        onUpgrade: (Migrator m, int from, int to) async {
          if (from < 2) {
            await m.addColumn(foods, foods.category);
          }
          if (from < 3) {
            await m.addColumn(recipes, recipes.imageBytes);
          }
          if (from < 4) {
            await m.createTable(mealPlanEntries);
          }
          if (from < 5) {
            // The Diario and Plan semanal used to be two separate tables —
            // DiaryEntries snapshotted its macros at log time, MealPlanEntries
            // always recomputed them live. Now the Diario is just "the Plan's
            // entries for today (or a past day)", so there's one table left:
            // copy every still-existing diary row into it (raw SQL, since the
            // DiaryEntries Dart table class is gone — this reads the old
            // on-disk schema, not a generated one) and drop the old table.
            await customStatement('''
              INSERT INTO meal_plan_entries
                (date, meal_type, food_id, recipe_id, quantity_grams, servings, order_index)
              SELECT date, meal_type, food_id, recipe_id, quantity_grams, servings, order_index
              FROM diary_entries;
            ''');
            await m.deleteTable('diary_entries');
          }
          if (from < 6) {
            await m.createTable(shoppingListManualItems);
            await m.createTable(shoppingListWeekModes);
          }
          if (from < 7) {
            await m.createTable(customLists);
            await m.createTable(customListItems);
          }
          if (from < 8) {
            // Planned vs. eaten split. The table was created with the current
            // schema (these columns included) by the from < 4 step above, so
            // only add them when it already existed before this upgrade.
            if (from >= 4) {
              await m.addColumn(mealPlanEntries, mealPlanEntries.isEaten);
              await m.addColumn(mealPlanEntries, mealPlanEntries.kcal);
              await m.addColumn(mealPlanEntries, mealPlanEntries.proteinG);
              await m.addColumn(mealPlanEntries, mealPlanEntries.carbsG);
              await m.addColumn(mealPlanEntries, mealPlanEntries.fatG);
              await m.addColumn(mealPlanEntries, mealPlanEntries.labelSnapshot);
            }
            await m.addColumn(userProfile, userProfile.lastBackupAt);
            // Everything up to today was shown as "consumed" before this split
            // existed, so it stays that way — frozen at today's values.
            await mealPlanDao.backfillEatenUpTo(DateTime.now());
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
      await delete(mealPlanEntries).go();
      await delete(shoppingListManualItems).go();
      await delete(shoppingListWeekModes).go();
      await delete(customListItems).go();
      await delete(customLists).go();
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
