import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/daos/diary_dao.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/macro_targets_calculator.dart';
import '../../../services/nutrition_engine/tdee_calculator.dart';

// The day currently shown in the Diario — normalized to midnight so it can
// be compared directly against DiaryEntries.date.
final selectedDiaryDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final userProfileStreamProvider = StreamProvider<UserProfileData?>((ref) {
  return ref.watch(appDatabaseProvider).userProfileDao.watchProfile();
});

final diaryEntriesForSelectedDateProvider = StreamProvider<List<DiaryEntryDisplay>>((ref) {
  final date = ref.watch(selectedDiaryDateProvider);
  return ref.watch(appDatabaseProvider).diaryDao.watchEntriesForDate(date);
});

final burnedCaloriesForSelectedDateProvider = StreamProvider<List<BurnedCalory>>((ref) {
  final date = ref.watch(selectedDiaryDateProvider);
  return ref.watch(appDatabaseProvider).burnedCaloriesDao.watchForDate(date);
});

// Resolves the profile's calorie/macro targets — either the user's manual
// overrides or the TDEE-derived automatic calculation. Falls back to a
// reasonable default (2000kcal) when the profile is incomplete (e.g. no
// height/birth date yet, so onboarding hasn't finished) rather than crashing
// the Diario before the user has entered their data.
class ResolvedTargets {
  const ResolvedTargets({
    required this.calorieTarget,
    required this.proteinG,
    required this.carbsG,
    required this.fatG,
  });

  final int calorieTarget;
  final double proteinG;
  final double carbsG;
  final double fatG;
}

const _fallbackTargets = ResolvedTargets(calorieTarget: 2000, proteinG: 120, carbsG: 220, fatG: 65);

ResolvedTargets resolveTargets(UserProfileData? profile, double? latestWeightKg) {
  if (profile == null) return _fallbackTargets;

  if (profile.calorieTargetMode == CalorieTargetMode.manual) {
    final target = profile.manualCalorieTarget ?? _fallbackTargets.calorieTarget;
    return ResolvedTargets(
      calorieTarget: target,
      proteinG: profile.manualProteinTargetG ?? _fallbackTargets.proteinG,
      carbsG: profile.manualCarbTargetG ?? _fallbackTargets.carbsG,
      fatG: profile.manualFatTargetG ?? _fallbackTargets.fatG,
    );
  }

  final weightKg = latestWeightKg ?? profile.startingWeightKg;
  if (weightKg == null || profile.heightCm == null || profile.birthDate == null) {
    return _fallbackTargets;
  }

  final age = _ageFrom(profile.birthDate!);
  final calorieTarget = calculateCalorieTarget(TdeeInput(
    weightKg: weightKg,
    heightCm: profile.heightCm!,
    age: age,
    sex: profile.sex ?? BiologicalSex.male,
    activityLevel: profile.activityLevel,
    goalType: profile.goalType,
    weeklyWeightChangeKg: profile.weeklyWeightChangeKg,
  ));
  final macros = calculateMacroTargets(
    calorieTarget: calorieTarget,
    weightKg: weightKg,
    proteinGramsPerKg: profile.proteinGramsPerKg,
    fatPercentOfCalories: profile.fatPercentOfCalories,
  );
  return ResolvedTargets(
    calorieTarget: calorieTarget,
    proteinG: macros.proteinG,
    carbsG: macros.carbsG,
    fatG: macros.fatG,
  );
}

int _ageFrom(DateTime birthDate) {
  final now = DateTime.now();
  var age = now.year - birthDate.year;
  if (now.month < birthDate.month ||
      (now.month == birthDate.month && now.day < birthDate.day)) {
    age--;
  }
  return age;
}

final resolvedTargetsProvider = Provider<ResolvedTargets>((ref) {
  final profile = ref.watch(userProfileStreamProvider).valueOrNull;
  final latestWeight = ref.watch(latestWeightKgProvider);
  return resolveTargets(profile, latestWeight);
});

final latestWeightKgProvider = Provider<double?>((ref) {
  final latest = ref.watch(_latestWeightStreamProvider).valueOrNull;
  return latest?.weightKg;
});

final _latestWeightStreamProvider = StreamProvider<BodyWeightLog?>((ref) {
  return ref.watch(appDatabaseProvider).bodyWeightDao.watchLatest();
});

final diarySummaryProvider = Provider<DiarySummary>((ref) {
  final entries = ref.watch(diaryEntriesForSelectedDateProvider).valueOrNull ?? [];
  final burned = ref.watch(burnedCaloriesForSelectedDateProvider).valueOrNull ?? [];
  final targets = ref.watch(resolvedTargetsProvider);

  final consumed = entries.fold(
    FoodMacros.zero,
    (sum, e) => sum +
        FoodMacros(
          kcal: e.entry.kcal,
          proteinG: e.entry.proteinG,
          carbsG: e.entry.carbsG,
          fatG: e.entry.fatG,
        ),
  );
  final burnedKcal = burned.fold(0.0, (sum, b) => sum + b.kcal);

  return DiarySummary(
    calorieTarget: targets.calorieTarget,
    consumed: consumed,
    burnedKcal: burnedKcal,
    macroTargets: FoodMacros(
      kcal: 0,
      proteinG: targets.proteinG,
      carbsG: targets.carbsG,
      fatG: targets.fatG,
    ),
  );
});

// Groups the day's entries by meal, in the fixed 5-slot order the Diario
// renders sections in.
Map<MealType, List<DiaryEntryDisplay>> groupEntriesByMeal(List<DiaryEntryDisplay> entries) {
  final grouped = {for (final meal in MealType.values) meal: <DiaryEntryDisplay>[]};
  for (final entry in entries) {
    grouped[entry.entry.mealType]!.add(entry);
  }
  return grouped;
}
