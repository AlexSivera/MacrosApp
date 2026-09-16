import 'package:flutter/material.dart';

import '../../data/database/enums.dart';

extension MealTypeLabel on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Desayuno',
        MealType.almuerzo => 'Almuerzo',
        MealType.lunch => 'Comida',
        MealType.snackMerienda => 'Merienda',
        MealType.dinner => 'Cena',
        MealType.snack => 'Extra',
      };

  // One icon per meal so each Diario/Plan section is identifiable at a
  // glance — all rendered in the theme's single accent color (never a
  // per-meal palette) to stay consistent with the app's "one vivid accent"
  // identity.
  IconData get icon => switch (this) {
        MealType.breakfast => Icons.free_breakfast_rounded,
        MealType.almuerzo => Icons.bakery_dining_rounded,
        MealType.lunch => Icons.lunch_dining_rounded,
        MealType.snackMerienda => Icons.local_cafe_rounded,
        MealType.dinner => Icons.dinner_dining_rounded,
        MealType.snack => Icons.cookie_rounded,
      };
}

// Diario/Plan section order — fixed, not alphabetical or enum-declaration
// order: Desayuno, Almuerzo, Comida, Merienda, Cena, Extra.
const mealSectionOrder = [
  MealType.breakfast,
  MealType.almuerzo,
  MealType.lunch,
  MealType.snackMerienda,
  MealType.dinner,
  MealType.snack,
];
