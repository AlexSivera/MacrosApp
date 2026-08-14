// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recipe_ingredients_dao.dart';

// ignore_for_file: type=lint
mixin _$RecipeIngredientsDaoMixin on DatabaseAccessor<AppDatabase> {
  $RecipeIngredientsTable get recipeIngredients =>
      attachedDatabase.recipeIngredients;
  RecipeIngredientsDaoManager get managers => RecipeIngredientsDaoManager(this);
}

class RecipeIngredientsDaoManager {
  final _$RecipeIngredientsDaoMixin _db;
  RecipeIngredientsDaoManager(this._db);
  $$RecipeIngredientsTableTableManager get recipeIngredients =>
      $$RecipeIngredientsTableTableManager(
        _db.attachedDatabase,
        _db.recipeIngredients,
      );
}
