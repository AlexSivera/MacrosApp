import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/features/recetas/providers/recipes_providers.dart';
import 'package:macrosapp/services/nutrition_engine/food_macros_calculator.dart';

void main() {
  test('applyRecipeFilter matches accented recipe names against an unaccented query', () async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    addTearDown(db.close);

    final macarronesId =
        await db.recipesDao.insert(RecipesCompanion.insert(name: 'Macarrones con brócoli'));
    final pastaId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Pasta con pollo'));
    final macarrones = (await db.recipesDao.getById(macarronesId))!;
    final pasta = (await db.recipesDao.getById(pastaId))!;
    final all = [
      RecipeCardData(recipe: macarrones, perServing: FoodMacros.zero),
      RecipeCardData(recipe: pasta, perServing: FoodMacros.zero),
    ];

    final result = applyRecipeFilter(all, filter: RecipeFilter.all, query: 'brocoli');

    expect(result.map((r) => r.recipe.name), ['Macarrones con brócoli']);
  });
}
