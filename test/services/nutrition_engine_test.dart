import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/diary_summary_calculator.dart';
import 'package:macrosapp/services/nutrition_engine/food_macros_calculator.dart';
import 'package:macrosapp/services/nutrition_engine/macro_targets_calculator.dart';
import 'package:macrosapp/services/nutrition_engine/tdee_calculator.dart';

void main() {
  group('TDEE / calorie target', () {
    test('BMR matches Mifflin-St Jeor for a known male example', () {
      // 80kg, 180cm, 30y male: 10*80 + 6.25*180 - 5*30 + 5 = 800+1125-150+5 = 1780
      final bmr = calculateBmr(weightKg: 80, heightCm: 180, age: 30, sex: BiologicalSex.male);
      expect(bmr, closeTo(1780, 0.01));
    });

    test('BMR matches Mifflin-St Jeor for a known female example', () {
      // 65kg, 165cm, 28y female: 10*65 + 6.25*165 - 5*28 - 161 = 650+1031.25-140-161 = 1380.25
      final bmr = calculateBmr(weightKg: 65, heightCm: 165, age: 28, sex: BiologicalSex.female);
      expect(bmr, closeTo(1380.25, 0.01));
    });

    test('calorieTarget applies activity factor and rounds to nearest 10, maintain goal', () {
      final target = calculateCalorieTarget(TdeeInput(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
        weeklyWeightChangeKg: 0,
      ));
      // TDEE = 1780 * 1.55 = 2759 -> rounds to 2760
      expect(target, 2760);
    });

    test('calorieTarget subtracts a deficit for a lose goal', () {
      final maintain = calculateCalorieTarget(TdeeInput(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.maintain,
        weeklyWeightChangeKg: 0,
      ));
      final losing = calculateCalorieTarget(TdeeInput(
        weightKg: 80,
        heightCm: 180,
        age: 30,
        sex: BiologicalSex.male,
        activityLevel: ActivityLevel.moderate,
        goalType: GoalType.lose,
        weeklyWeightChangeKg: -0.5,
      ));
      expect(losing, lessThan(maintain));
      // 0.5kg/week deficit = 550 kcal/day
      expect(maintain - losing, closeTo(550, 10));
    });

    test('calorieTarget never drops below BMR even for an aggressive deficit', () {
      final bmr = calculateBmr(weightKg: 60, heightCm: 160, age: 40, sex: BiologicalSex.female);
      final target = calculateCalorieTarget(TdeeInput(
        weightKg: 60,
        heightCm: 160,
        age: 40,
        sex: BiologicalSex.female,
        activityLevel: ActivityLevel.sedentary,
        goalType: GoalType.lose,
        weeklyWeightChangeKg: -5, // unrealistic, should still floor at BMR
      ));
      expect(target, greaterThanOrEqualTo(bmr.round()));
    });
  });

  group('macro targets', () {
    test('protein/fat/carbs split sums back to the calorie target', () {
      final targets = calculateMacroTargets(
        calorieTarget: 2400,
        weightKg: 80,
        proteinGramsPerKg: 1.8,
        fatPercentOfCalories: 0.28,
      );
      expect(targets.proteinG, closeTo(144, 0.01));
      expect(targets.fatG, closeTo((2400 * 0.28) / 9, 0.01));
      final totalKcal = targets.proteinG * 4 + targets.carbsG * 4 + targets.fatG * 9;
      expect(totalKcal, closeTo(2400, 1));
    });

    test('carbs never go negative for an unrealistic protein/fat combination', () {
      final targets = calculateMacroTargets(
        calorieTarget: 1200,
        weightKg: 120,
        proteinGramsPerKg: 3.0, // 360g protein = 1440 kcal alone, exceeds the target
        fatPercentOfCalories: 0.5,
      );
      expect(targets.carbsG, 0);
    });
  });

  group('food/recipe macro scaling', () {
    final chicken = Food(
      id: 1,
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
      isCustom: false,
      category: FoodCategory.carnePescado,
    );

    test('scaleFoodMacros scales linearly with grams', () {
      final macros = scaleFoodMacros(chicken, 200);
      expect(macros.kcal, closeTo(330, 0.01));
      expect(macros.proteinG, closeTo(62, 0.01));
    });

    test('FoodMacros arithmetic: sum, divide, multiply', () {
      const a = FoodMacros(kcal: 100, proteinG: 10, carbsG: 5, fatG: 2);
      const b = FoodMacros(kcal: 200, proteinG: 20, carbsG: 10, fatG: 4);
      final sum = a + b;
      expect(sum.kcal, 300);
      final perServing = sum / 2;
      expect(perServing.kcal, 150);
      final scaled = perServing * 3;
      expect(scaled.kcal, 450);
    });
  });

  group('DiarySummary contract', () {
    test('remainingKcal = target - consumed + burned, not clamped', () {
      const summary = DiarySummary(
        calorieTarget: 2000,
        consumed: FoodMacros(kcal: 2200, proteinG: 0, carbsG: 0, fatG: 0),
        burnedKcal: 100,
        macroTargets: FoodMacros(kcal: 0, proteinG: 100, carbsG: 200, fatG: 60),
      );
      // 2000 - 2200 + 100 = -100 (over target, visibly negative)
      expect(summary.remainingKcal, -100);
      expect(summary.isOverTarget, isTrue);
    });

    test('netKcal = consumed - burned, distinct from remainingKcal', () {
      const summary = DiarySummary(
        calorieTarget: 2500,
        consumed: FoodMacros(kcal: 1800, proteinG: 0, carbsG: 0, fatG: 0),
        burnedKcal: 300,
        macroTargets: FoodMacros(kcal: 0, proteinG: 100, carbsG: 200, fatG: 60),
      );
      expect(summary.netKcal, 1500);
      expect(summary.remainingKcal, 1000); // 2500 - 1800 + 300
      expect(summary.remainingKcal, isNot(summary.netKcal));
    });

    test('ringFraction clamps at 1 even when over target', () {
      const summary = DiarySummary(
        calorieTarget: 2000,
        consumed: FoodMacros(kcal: 3000, proteinG: 0, carbsG: 0, fatG: 0),
        burnedKcal: 0,
        macroTargets: FoodMacros(kcal: 0, proteinG: 100, carbsG: 200, fatG: 60),
      );
      expect(summary.ringFraction, 1.0);
    });

    test('macro remaining is not clamped and can go negative', () {
      const summary = DiarySummary(
        calorieTarget: 2000,
        consumed: FoodMacros(kcal: 500, proteinG: 150, carbsG: 50, fatG: 20),
        burnedKcal: 0,
        macroTargets: FoodMacros(kcal: 0, proteinG: 100, carbsG: 200, fatG: 60),
      );
      expect(summary.proteinRemainingG, -50);
      expect(summary.carbsRemainingG, 150);
    });
  });
}
