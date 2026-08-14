import '../../data/database/enums.dart';

extension MealTypeLabel on MealType {
  String get label => switch (this) {
        MealType.breakfast => 'Desayuno',
        MealType.lunch => 'Comida',
        MealType.snackMerienda => 'Merienda',
        MealType.dinner => 'Cena',
        MealType.snack => 'Snack',
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
