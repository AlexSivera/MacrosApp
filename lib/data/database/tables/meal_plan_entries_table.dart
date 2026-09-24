import 'package:drift/drift.dart';

import '../enums.dart';
import 'foods_table.dart';
import 'recipes_table.dart';

// One food/recipe slot on a given day, shared by the Diario and the Plan.
// An entry starts out either *planned* (added from the Plan: isEaten =
// false) or *eaten* (added from the Diario, or ticked off later: isEaten =
// true).
//
// Planned entries derive their macros live from foodId/recipeId, since a
// plan is meant to be freely edited before it's eaten. Eaten entries
// snapshot kcal/proteinG/carbsG/fatG (plus the food/recipe name) at the
// moment they're marked eaten, so editing or deleting a food or recipe
// later never rewrites a day that already happened — see
// resolveEntryMacros() and MealPlanDao.markEaten().
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

  // Only counts towards the Diario's "consumidas" once true.
  BoolColumn get isEaten => boolean().withDefault(const Constant(false))();

  // Snapshot taken when the entry is marked eaten (null while planned).
  RealColumn get kcal => real().nullable()();
  RealColumn get proteinG => real().nullable()();
  RealColumn get carbsG => real().nullable()();
  RealColumn get fatG => real().nullable()();
  TextColumn get labelSnapshot => text().nullable()();
}
