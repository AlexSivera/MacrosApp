import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../data/database/app_database.dart';

// Confirms a food/recipe landed where intended ("Añadido a Desayuno"), with
// an undo — the quantity sheets close straight away, so without this the
// only feedback was the Diario's numbers moving behind the sheet.
void showAddedEntrySnackBar(
  ScaffoldMessengerState messenger, {
  required AppDatabase db,
  required int entryId,
  required MealType mealType,
  required bool eaten,
}) {
  messenger
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(
      content: Text(eaten ? 'Añadido a ${mealType.label}' : 'Planificado en ${mealType.label}'),
      action: SnackBarAction(label: 'Deshacer', onPressed: () => db.mealPlanDao.deleteEntry(entryId)),
    ));
}
