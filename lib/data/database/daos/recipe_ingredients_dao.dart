import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/recipe_ingredients_table.dart';

part 'recipe_ingredients_dao.g.dart';

@DriftAccessor(tables: [RecipeIngredients])
class RecipeIngredientsDao extends DatabaseAccessor<AppDatabase>
    with _$RecipeIngredientsDaoMixin {
  RecipeIngredientsDao(super.db);

  Stream<List<RecipeIngredient>> watchForRecipe(int recipeId) {
    return (select(recipeIngredients)
          ..where((i) => i.recipeId.equals(recipeId))
          ..orderBy([(i) => OrderingTerm.asc(i.orderIndex)]))
        .watch();
  }

  Future<List<RecipeIngredient>> getForRecipe(int recipeId) {
    return (select(recipeIngredients)
          ..where((i) => i.recipeId.equals(recipeId))
          ..orderBy([(i) => OrderingTerm.asc(i.orderIndex)]))
        .get();
  }

  // Deletes every existing ingredient row for the recipe and inserts the
  // given list in one transaction — the recipe editor always submits its
  // full ingredient list rather than diffing individual adds/removes, so a
  // wholesale replace is simpler and avoids id bookkeeping in the UI layer.
  Future<void> replaceIngredients(int recipeId, List<RecipeIngredientsCompanion> entries) async {
    await transaction(() async {
      await (delete(recipeIngredients)..where((i) => i.recipeId.equals(recipeId))).go();
      if (entries.isNotEmpty) {
        await batch((b) => b.insertAll(recipeIngredients, entries));
      }
    });
  }
}
