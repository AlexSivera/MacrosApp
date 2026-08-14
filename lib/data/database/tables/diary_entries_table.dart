import 'package:drift/drift.dart';

import '../enums.dart';
import 'foods_table.dart';
import 'recipes_table.dart';

// One row per logged item. Exactly one of foodId/recipeId is set — enforced
// by DiaryDao.logFood()/logRecipe(), not by the schema (Drift can't express
// a CHECK across two nullable FKs cleanly).
//
// kcal/proteinG/carbsG/fatG are snapshotted at log time rather than derived
// live from the current Foods/Recipes row. This is deliberate: if a food's
// macros or a recipe's ingredients are edited later, past diary days must
// not silently change. onDelete: setNull on both FKs means deleting the
// referenced food/recipe never breaks a past entry — its snapshot already
// carries everything the summary needs.
class DiaryEntries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  IntColumn get mealType => intEnum<MealType>()();
  IntColumn get foodId => integer().nullable().references(Foods, #id, onDelete: KeyAction.setNull)();
  IntColumn get recipeId =>
      integer().nullable().references(Recipes, #id, onDelete: KeyAction.setNull)();
  RealColumn get quantityGrams => real().nullable()();
  RealColumn get servings => real().nullable()();
  IntColumn get orderIndex => integer()();
  RealColumn get kcal => real()();
  RealColumn get proteinG => real()();
  RealColumn get carbsG => real()();
  RealColumn get fatG => real()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
