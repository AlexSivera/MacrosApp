import '../../data/database/enums.dart';

class TdeeInput {
  const TdeeInput({
    required this.weightKg,
    required this.heightCm,
    required this.age,
    required this.sex,
    required this.activityLevel,
    required this.goalType,
    required this.weeklyWeightChangeKg,
  });

  final double weightKg;
  final double heightCm;
  final int age;
  final BiologicalSex sex;
  final ActivityLevel activityLevel;
  final GoalType goalType;
  final double weeklyWeightChangeKg;
}

const _activityFactors = {
  ActivityLevel.sedentary: 1.2,
  ActivityLevel.light: 1.375,
  ActivityLevel.moderate: 1.55,
  ActivityLevel.active: 1.725,
  ActivityLevel.veryActive: 1.9,
};

// Mifflin-St Jeor — the most widely validated resting-energy formula for
// general use (vs. Harris-Benedict, which tends to overestimate).
double calculateBmr({
  required double weightKg,
  required double heightCm,
  required int age,
  required BiologicalSex sex,
}) {
  final base = 10 * weightKg + 6.25 * heightCm - 5 * age;
  return sex == BiologicalSex.male ? base + 5 : base - 161;
}

double calculateTdee(TdeeInput input) {
  final bmr = calculateBmr(
    weightKg: input.weightKg,
    heightCm: input.heightCm,
    age: input.age,
    sex: input.sex,
  );
  return bmr * _activityFactors[input.activityLevel]!;
}

// 7700 kcal ≈ 1kg of body mass; spread over 7 days for a daily adjustment.
// The sign of weeklyWeightChangeKg already encodes lose (-) vs gain (+) —
// goalType itself isn't consulted here, it's the UI's job to keep the two
// consistent (e.g. reset weeklyWeightChangeKg to 0 when goalType flips to
// maintain).
int calculateCalorieTarget(TdeeInput input) {
  final bmr = calculateBmr(
    weightKg: input.weightKg,
    heightCm: input.heightCm,
    age: input.age,
    sex: input.sex,
  );
  final tdee = calculateTdee(input);
  final dailyAdjustment = input.weeklyWeightChangeKg * 1100;
  final raw = (tdee + dailyAdjustment).clamp(bmr, double.infinity);
  return (raw / 10).round() * 10;
}
