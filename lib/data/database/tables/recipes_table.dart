import 'package:drift/drift.dart';

import '../enums.dart';

// Macro totals are never stored here — they're always derived live from
// RecipeIngredients (see services/nutrition_engine/recipe_macros_calculator),
// so editing an ingredient's quantity can never leave a stale total behind.
class Recipes extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  // Legacy field from before web support: a path into the native app's own
  // document storage, which doesn't exist as a concept on web. Only ever
  // read now (see legacy_recipe_image.dart), never written — new photos on
  // every platform go into imageBytes instead, which works identically
  // everywhere and needs no filesystem.
  TextColumn get imagePath => text().nullable()();
  BlobColumn get imageBytes => blob().nullable()();
  IntColumn get category =>
      intEnum<RecipeCategory>().withDefault(Constant(RecipeCategory.lunch.index))();
  RealColumn get servings => real().withDefault(const Constant(1))();
  BoolColumn get isFavorite => boolean().withDefault(const Constant(false))();
  IntColumn get prepTimeMinutes => integer().nullable()();
  DateTimeColumn get createdAt => dateTime().withDefault(currentDateAndTime)();
}
