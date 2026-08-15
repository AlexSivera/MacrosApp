import 'package:flutter/material.dart';

import '../../data/database/enums.dart';

extension MealTypeLabel on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Desayuno',
        MealType.lunch => 'Comida',
        MealType.snackMerienda => 'Merienda',
        MealType.dinner => 'Cena',
        MealType.snack => 'Snack',
      };

  // One icon per meal so each Diario section is identifiable at a glance —
  // all rendered in the theme's single accent color (never a per-meal
  // palette) to stay consistent with the app's "one vivid accent" identity.
  IconData get icon => switch (this) {
        MealType.breakfast => Icons.free_breakfast_rounded,
        MealType.lunch => Icons.lunch_dining_rounded,
        MealType.snackMerienda => Icons.local_cafe_rounded,
        MealType.dinner => Icons.dinner_dining_rounded,
        MealType.snack => Icons.cookie_rounded,
      };
}

// Diario section order — fixed, not alphabetical or enum-declaration order.
const mealSectionOrder = [
  MealType.breakfast,
  MealType.lunch,
  MealType.snackMerienda,
  MealType.dinner,
  MealType.snack,
];
