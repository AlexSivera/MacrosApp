import 'package:drift/drift.dart';

import '../enums.dart';

// Macro totals are never stored here — they're always derived live from
// RecipeIngredients (see services/nutrition_engine/recipe_macros_calculator),
// so editing an ingredient's quantity can never leave a stale total behind.
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get imagePath => text().nullable()();
  IntColumn get category =>
      intEnum<RecipeCategory>().withDefault(Constant(RecipeCategory.lunch.index))();
  RealColumn get servings => real().withDefault(const Constant(1))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get prepTimeMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
