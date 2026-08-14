import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recipe_ingredients_table.dart';
import '../tables/recipes_table.dart';

part 'recipes_dao.g.dart';

// Includes RecipeIngredients (not just Recipes) so deleteRecipe can clean up
// its ingredient rows in one transaction — drift's `.references(..,
// onDelete: KeyAction.cascade)` doesn't reliably emit an actual SQLite FK
// constraint for this schema (same limitation observed in GymApp's own
// generated tables), so cascade deletion is handled explicitly here instead
// of relied upon at the database level.
@DriftAccessor(tables: [Recipes, RecipeIngredients])
class RecipesDao extends DatabaseAccessor<AppDatabase> with _$RecipesDaoMixin {
  RecipesDao(super.db);

  Stream<List<Recipe>> watchAll({RecipeCategory? category, bool favoritesOnly = false}) {
    final query = select(recipes)..orderBy([(r) => OrderingTerm.desc(r.createdAt)]);
    if (category != null) {
      query.where((r) => r.category.equalsValue(category));
    }
    if (favoritesOnly) {
      query.where((r) => r.isFavorite.equals(true));
    }
    return query.watch();
  }

  Stream<List<Recipe>> watchSearch(String query) {
    final q = '%${query.trim()}%';
    return (select(recipes)
          ..where((r) => r.name.like(q))
          ..orderBy([(r) => OrderingTerm.desc(r.createdAt)]))
        .watch();
  }

  Stream<Recipe?> watchById(int id) =>
      (select(recipes)..where((r) => r.id.equals(id))).watchSingleOrNull();

  Future<Recipe?> getById(int id) =>
      (select(recipes)..where((r) => r.id.equals(id))).getSingleOrNull();

  Future<int> insert(RecipesCompanion entry) => into(recipes).insert(entry);

  Future<bool> updateRecipe(Recipe entry) => update(recipes).replace(entry);

  Future<void> toggleFavorite(int id, bool isFavorite) async {
    await (update(recipes)..where((r) => r.id.equals(id)))
        .write(RecipesCompanion(isFavorite: Value(isFavorite)));
  }

  Future<int> deleteRecipe(int id) async {
    return transaction(() async {
      await (delete(recipeIngredients)..where((i) => i.recipeId.equals(id))).go();
      return (delete(recipes)..where((r) => r.id.equals(id))).go();
    });
  }
}
