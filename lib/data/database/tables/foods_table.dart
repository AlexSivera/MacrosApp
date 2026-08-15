import 'package:drift/drift.dart';

import '../enums.dart';

class Foods extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  RealColumn get kcalPer100g => real()();
  RealColumn get proteinPer100g => real()();
  RealColumn get carbsPer100g => real()();
  RealColumn get fatPer100g => real()();
  RealColumn get fiberPer100g => real().nullable()();
  // e.g. "1 huevo = 50g" — shown as a quick-pick alongside the gram field.
  RealColumn get defaultServingGrams => real().nullable()();
  TextColumn get servingLabel => text().nullable()();
  // false = bundled seed data, true = created via "Crear alimento personalizado".
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
  IntColumn get category =>
      intEnum<FoodCategory>().withDefault(Constant(FoodCategory.otros.index))();
}
