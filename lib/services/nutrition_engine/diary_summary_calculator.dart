import 'food_macros_calculator.dart';

class DiarySummary {
  const DiarySummary({
    required this.calorieTarget,
    required this.consumed,
    required this.burnedKcal,
    required this.macroTargets,
  });

  final int calorieTarget;
  final FoodMacros consumed;
  final double burnedKcal;
  final FoodMacros macroTargets; // .kcal unused here — carries protein/carbs/fat targets only

  double get consumedKcal => consumed.kcal;

  // Restantes = objetivo - consumidas + quemadas. Deliberately NOT clamped:
  // going over target must show as a visible negative/red number, not
  // silently floor at 0.
  double get remainingKcal => calorieTarget - consumedKcal + burnedKcal;

  // Detalles-modal-only figure — consumidas menos quemadas, distinct from
  // "restantes" so the two concepts the brief insists on never being mixed
  // (consumidas vs. quemadas) stay visibly separate.
  double get netKcal => consumedKcal - burnedKcal;

  double get proteinRemainingG => macroTargets.proteinG - consumed.proteinG;
  double get carbsRemainingG => macroTargets.carbsG - consumed.carbsG;
  double get fatRemainingG => macroTargets.fatG - consumed.fatG;

  // Visual-only: the ring never overshoots 100%, even when remainingKcal is
  // negative — the numeric "Restantes" text is the actual source of truth.
  double get ringFraction =>
      calorieTarget <= 0 ? 0 : (consumedKcal / calorieTarget).clamp(0, 1);

  bool get isOverTarget => remainingKcal < 0;
}
