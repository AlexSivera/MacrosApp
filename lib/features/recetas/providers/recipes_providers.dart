import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/text_search.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';
import 'package:flutter/material.dart' show IconData, Icons;

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

extension RecipeCategoryLabel on RecipeCategory {
  String get label => switch (this) {
        RecipeCategory.breakfast => 'Desayuno',
        RecipeCategory.lunch => 'Comida',
        RecipeCategory.dinner => 'Cena',
        RecipeCategory.snack => 'Extra',
      };

  // Same icons as the matching Diario meal sections.
  IconData get icon => switch (this) {
        RecipeCategory.breakfast => Icons.free_breakfast_rounded,
        RecipeCategory.lunch => Icons.lunch_dining_rounded,
        RecipeCategory.dinner => Icons.dinner_dining_rounded,
        RecipeCategory.snack => Icons.cookie_rounded,
      };
}

enum RecipeFilter { all, breakfast, lunch, dinner, snack, favorites, highProtein }

extension RecipeFilterLabel on RecipeFilter {
  String get label => switch (this) {
        RecipeFilter.all => 'Todas',
        RecipeFilter.breakfast => 'Desayunos',
        RecipeFilter.lunch => 'Comidas',
        RecipeFilter.dinner => 'Cenas',
        RecipeFilter.snack => 'Extras',
        RecipeFilter.favorites => 'Favoritas',
        RecipeFilter.highProtein => 'Alta proteína',
      };
}

// Diario/Plan's meal sections (6: breakfast/almuerzo/lunch/snackMerienda/
// dinner/snack) don't line up 1:1 with a recipe's own category (4:
// breakfast/lunch/dinner/snack — recipes have no "merienda" or "almuerzo"
// of their own), so both map to the closest existing category rather than
// getting their own filter value.
RecipeFilter recipeFilterForMealType(MealType mealType) => switch (mealType) {
      MealType.breakfast => RecipeFilter.breakfast,
      MealType.lunch => RecipeFilter.lunch,
      MealType.dinner => RecipeFilter.dinner,
      MealType.snack || MealType.snackMerienda || MealType.almuerzo => RecipeFilter.snack,
    };

final recipeFilterProvider = StateProvider.autoDispose<RecipeFilter>((ref) => RecipeFilter.all);

List<RecipeCardData> applyRecipeFilter(
  List<RecipeCardData> all, {
  required RecipeFilter filter,
  required String query,
}) {
  var result = all;
  final trimmedQuery = query.trim();
  if (trimmedQuery.isNotEmpty) {
    final q = normalizeForSearch(trimmedQuery);
    result = result.where((r) => normalizeForSearch(r.recipe.name).contains(q)).toList();
  }
  return switch (filter) {
    RecipeFilter.all => result,
    RecipeFilter.breakfast =>
      result.where((r) => r.recipe.category == RecipeCategory.breakfast).toList(),
    RecipeFilter.lunch => result.where((r) => r.recipe.category == RecipeCategory.lunch).toList(),
    RecipeFilter.dinner => result.where((r) => r.recipe.category == RecipeCategory.dinner).toList(),
    RecipeFilter.snack => result.where((r) => r.recipe.category == RecipeCategory.snack).toList(),
    RecipeFilter.favorites => result.where((r) => r.recipe.isFavorite).toList(),
    RecipeFilter.highProtein => result.where((r) => r.isHighProtein).toList(),
  };
}

final filteredRecipesProvider = Provider.autoDispose<AsyncValue<List<RecipeCardData>>>((ref) {
  final filter = ref.watch(recipeFilterProvider);
  final query = ref.watch(recipeSearchQueryProvider);
  return ref
      .watch(recipesWithMacrosProvider)
      .whenData((all) => applyRecipeFilter(all, filter: filter, query: query));
});
