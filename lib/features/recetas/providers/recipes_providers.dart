import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';

final recipeSearchQueryProvider = StateProvider.autoDispose<String>((ref) => '');

final recipeSearchResultsProvider = StreamProvider.autoDispose<List<Recipe>>((ref) {
  final query = ref.watch(recipeSearchQueryProvider);
  final dao = ref.watch(appDatabaseProvider).recipesDao;
  return query.trim().isEmpty ? dao.watchAll() : dao.watchSearch(query);
});

class RecipeCardData {
  const RecipeCardData({required this.recipe, required this.perServing});

  final Recipe recipe;
  final FoodMacros perServing;

  // A recipe is "alta proteína" when at least 30% of its per-serving
  // calories come from protein — a common nutrition-app heuristic, applied
  // here since the brief doesn't store an explicit flag for it.
  bool get isHighProtein =>
      perServing.kcal > 0 && (perServing.proteinG * 4 / perServing.kcal) >= 0.30;
}

Future<FoodMacros> _perServingMacrosFor(AppDatabase db, Recipe recipe) async {
  final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
  final foods = await Future.wait(ingredients.map((i) => db.foodsDao.getById(i.foodId)));
  final pairs = [
    for (var i = 0; i < ingredients.length; i++)
      if (foods[i] != null) (ingredients[i], foods[i]!),
  ];
  final totals = computeRecipeTotals(pairs);
  return recipe.servings > 0 ? computePerServing(totals, recipe.servings) : FoodMacros.zero;
}

// Every recipe with its computed per-serving macros — the single source
// filtering (category, favorites, alta proteína) and cards render from, so
// macros are computed once per list refresh rather than once per card.
final recipesWithMacrosProvider = StreamProvider.autoDispose<List<RecipeCardData>>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return db.recipesDao.watchAll().asyncMap((recipes) async {
    final result = <RecipeCardData>[];
    for (final recipe in recipes) {
      result.add(RecipeCardData(recipe: recipe, perServing: await _perServingMacrosFor(db, recipe)));
    }
    return result;
  });
});

final recipePerServingMacrosProvider =
    FutureProvider.autoDispose.family<FoodMacros, Recipe>((ref, recipe) {
  return _perServingMacrosFor(ref.watch(appDatabaseProvider), recipe);
});

enum RecipeFilter { all, breakfast, lunch, dinner, snack, favorites, highProtein }

final recipeFilterProvider = StateProvider.autoDispose<RecipeFilter>((ref) => RecipeFilter.all);

final filteredRecipesProvider = Provider.autoDispose<AsyncValue<List<RecipeCardData>>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  final query = ref.watch(recipeSearchQueryProvider);
  return ref.watch(recipesWithMacrosProvider).whenData((all) {
    var result = all;
    if (query.trim().isNotEmpty) {
      final q = query.trim().toLowerCase();
      result = result.where((r) => r.recipe.name.toLowerCase().contains(q)).toList();
    }
    return switch (filter) {
      RecipeFilter.all => result,
      RecipeFilter.breakfast =>
        result.where((r) => r.recipe.category == RecipeCategory.breakfast).toList(),
      RecipeFilter.lunch => result.where((r) => r.recipe.category == RecipeCategory.lunch).toList(),
      RecipeFilter.dinner =>
        result.where((r) => r.recipe.category == RecipeCategory.dinner).toList(),
      RecipeFilter.snack => result.where((r) => r.recipe.category == RecipeCategory.snack).toList(),
      RecipeFilter.favorites => result.where((r) => r.recipe.isFavorite).toList(),
      RecipeFilter.highProtein => result.where((r) => r.isHighProtein).toList(),
    };
  });
});
