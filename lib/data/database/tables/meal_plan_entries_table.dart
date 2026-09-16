import 'package:drift/drift.dart';

import '../enums.dart';
import 'foods_table.dart';
import 'recipes_table.dart';

// A planned meal for a future/past day, distinct from DiaryEntries: nothing
// here is snapshotted, since a plan is meant to be freely edited or moved
// before it's actually eaten. Macros and the weekly shopping list are always
// derived live from foodId/recipeId (see meal_plan_dao.dart). "Log to
// Diario" copies a plan entry into DiaryEntries at that point, snapshotting
// it the same way any other diary entry is.
class MealPlanEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mealType => intEnum<MealType>()();
  IntColumn get foodId =>
      integer().nullable().references(Foods, #id, onDelete: KeyAction.setNull)();
  IntColumn get recipeId =>
      integer().nullable().references(Recipes, #id, onDelete: KeyAction.setNull)();
  RealColumn get quantityGrams => real().nullable()();
  RealColumn get servings => real().nullable()();
  IntColumn get orderIndex => integer()();
}
