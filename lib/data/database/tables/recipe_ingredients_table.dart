import 'package:drift/drift.dart';

import 'foods_table.dart';
import 'recipes_table.dart';

class RecipeIngredients extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get recipeId =>
      integer().references(Recipes, #id, onDelete: KeyAction.cascade)();
  IntColumn get foodId => integer().references(Foods, #id)();
  RealColumn get grams => real()();
  IntColumn get orderIndex => integer()();
}
