class MacroTargets {
  const MacroTargets({required this.proteinG, required this.carbsG, required this.fatG});

  final double proteinG;
  final double carbsG;
  final double fatG;
}

// Protein and fat are set from the user's body weight / calorie-split
// preferences; carbs absorb whatever calorie budget is left. Never returns
// negative carbs — an unrealistic protein/fat combination just floors carbs
// at 0 rather than producing a nonsensical target.
MacroTargets calculateMacroTargets({
  required int calorieTarget,
  required double weightKg,
  required double proteinGramsPerKg,
  required double fatPercentOfCalories,
}) {
  final proteinG = weightKg * proteinGramsPerKg;
  final fatG = (calorieTarget * fatPercentOfCalories) / 9;
  final carbsKcal = (calorieTarget - proteinG * 4 - fatG * 9).clamp(0, double.infinity);
  final carbsG = carbsKcal / 4;
  return MacroTargets(proteinG: proteinG, carbsG: carbsG, fatG: fatG);
}
