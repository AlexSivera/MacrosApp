import '../../data/database/app_database.dart';

class FoodMacros {
  const FoodMacros({
    required this.kcal,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final double kcal;
  final double proteinG;
  final double carbsG;
  final double fatG;

  FoodMacros operator +(FoodMacros other) => FoodMacros(
        kcal: kcal + other.kcal,
        proteinG: proteinG + other.proteinG,
        carbsG: carbsG + other.carbsG,
        fatG: fatG + other.fatG,
      );

  FoodMacros operator /(double divisor) => FoodMacros(
        kcal: kcal / divisor,
        proteinG: proteinG / divisor,
        carbsG: carbsG / divisor,
        fatG: fatG / divisor,
      );

  FoodMacros operator *(double factor) => FoodMacros(
        kcal: kcal * factor,
        proteinG: proteinG * factor,
        carbsG: carbsG * factor,
        fatG: fatG * factor,
      );

  static const zero = FoodMacros(kcal: 0, proteinG: 0, carbsG: 0, fatG: 0);
}

// The single low-level primitive reused by the diary add-food preview and
// the recipe ingredient builder preview — every place quantity math happens.
FoodMacros scaleFoodMacros(Food food, double grams) {
  final factor = grams / 100;
  return FoodMacros(
    kcal: food.kcalPer100g * factor,
    proteinG: food.proteinPer100g * factor,
    carbsG: food.carbsPer100g * factor,
    fatG: food.fatPer100g * factor,
  );
}
