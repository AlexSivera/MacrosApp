import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../diario/providers/diary_providers.dart';
import 'meal_plan_providers.dart';

// A day-level macro summary for PlanDayScreen, so planning a day shows
// straight away whether it actually meets the user's targets — the same
// question CalorieSummaryCard already answers for "today" in the Diario.
// Reuses resolvedTargetsProvider as-is (targets aren't diary-specific) and
// has no "burned calories" term: that's a same-day activity concept the
// plan doesn't model, so it's always 0 here, distinct from an unlogged day.
//
// `.autoDispose.family` keyed by date is safe here (a plain synchronous
// Provider, not a Stream/Future one) — see mealPlanEntriesForDateProvider's
// own note on why that distinction matters for this app.
final planDaySummaryProvider = Provider.autoDispose.family<DiarySummary, DateTime>((ref, date) {
  final entries = ref.watch(mealPlanEntriesForDateProvider(date)).valueOrNull ?? [];
  final consumed = sumEntryMacros(ref.watch, entries) ?? FoodMacros.zero;
  final targets = ref.watch(resolvedTargetsProvider);

  return DiarySummary(
    calorieTarget: targets.calorieTarget,
    consumed: consumed,
    burnedKcal: 0,
    macroTargets: FoodMacros(
      kcal: 0,
      proteinG: targets.proteinG,
      carbsG: targets.carbsG,
      fatG: targets.fatG,
    ),
  );
});
