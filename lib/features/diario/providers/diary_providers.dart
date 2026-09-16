import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/macro_targets_calculator.dart';
import '../../../services/nutrition_engine/tdee_calculator.dart';
import '../../plan_semanal/providers/meal_plan_providers.dart';

// The day currently shown in the Diario — normalized to midnight so it can
// be compared directly against MealPlanEntries.date. The Diario is just the
// Plan's entries for this one day (see meal_plan_entries_table.dart), so
// everything else (which entries, their macros) is read straight from
// meal_plan_providers.dart.
final selectedDiaryDateProvider = StateProvider<DateTime>((ref) {
  final now = DateTime.now();
  return DateTime(now.year, now.month, now.day);
});

final userProfileStreamProvider = StreamProvider<UserProfileData?>((ref) {
  return ref.watch(appDatabaseProvider).userProfileDao.watchProfile();
});

// Deliberately NOT meal_plan_providers.dart's mealPlanEntriesForDateProvider
// (a .family.autoDispose provider): that's fine for PlanDayScreen, whose
// date is fixed for the screen's whole lifetime (it's a route param), but
// the Diario keeps one screen mounted while selectedDiaryDateProvider
// changes underneath it every time the user taps a day arrow. Churning a
// family provider's instances like that — disposing today's, creating
// yesterday's, over and over — was observed to hang widget tests outright:
// something in cancelling one of Drift's watched-query subscriptions while
// an near-identical one spins up in the same frame never resolves under
// pump()'s virtual clock. A single non-family StreamProvider that just
// re-subscribes internally when the watched date changes (the pre-merge
// DiaryDao design) doesn't have that failure mode.
final diaryEntriesForSelectedDateProvider = StreamProvider<List<MealPlanEntryDisplay>>((ref) {
  final date = ref.watch(selectedDiaryDateProvider);
  return ref.watch(appDatabaseProvider).mealPlanDao.watchEntriesForDate(date);
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
  final consumed = sumEntryMacros(ref.watch, entries) ?? FoodMacros.zero;
  final burned = ref.watch(burnedCaloriesForSelectedDateProvider).valueOrNull ?? [];
  final targets = ref.watch(resolvedTargetsProvider);

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
