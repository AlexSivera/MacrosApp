import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/meal_plan_macros_calculator.dart';
import '../../../core/utils/dates.dart';

enum ProgressRange { sevenDays, thirtyDays, threeMonths, sixMonths, oneYear }

extension ProgressRangeLabel on ProgressRange {
  String get label => switch (this) {
        ProgressRange.sevenDays => '7 días',
        ProgressRange.thirtyDays => '30 días',
        ProgressRange.threeMonths => '3 meses',
        ProgressRange.sixMonths => '6 meses',
        ProgressRange.oneYear => '1 año',
      };

  int get days => switch (this) {
        ProgressRange.sevenDays => 7,
        ProgressRange.thirtyDays => 30,
        ProgressRange.threeMonths => 90,
        ProgressRange.sixMonths => 180,
        ProgressRange.oneYear => 365,
      };
}

final progressRangeProvider = StateProvider<ProgressRange>((ref) => ProgressRange.thirtyDays);

DateTime _startOfRange(ProgressRange range) {
  final now = DateTime.now();
  final today = DateTime(now.year, now.month, now.day);
  return addDays(today, 1 - range.days);
}

final weightHistoryForRangeProvider = StreamProvider.autoDispose<List<BodyWeightLog>>((ref) {
  final range = ref.watch(progressRangeProvider);
  final db = ref.watch(appDatabaseProvider);
  return db.bodyWeightDao.watchInRange(_startOfRange(range), DateTime.now());
});

final earliestWeightProvider = FutureProvider.autoDispose<BodyWeightLog?>((ref) {
  return ref.watch(appDatabaseProvider).bodyWeightDao.earliest();
});

class AverageMacros {
  const AverageMacros({required this.perDay, required this.dayCount});

  final FoodMacros perDay;
  final int dayCount;
}

// Averages what was actually eaten over the days in the range that have
// anything logged — dividing by the range's full length instead made a
// brand-new user's first day read as "11 kcal/día" on the 30-day view.
// Planned-but-not-eaten entries never count.
final averageMacrosForRangeProvider = StreamProvider.autoDispose<AverageMacros>((ref) {
  final range = ref.watch(progressRangeProvider);
  final db = ref.watch(appDatabaseProvider);
  final start = _startOfRange(range);
  return db.mealPlanDao
      .watchEntriesInRange(start, DateTime.now(), eatenOnly: true)
      .asyncMap((displays) async {
    final macros = await Future.wait(displays.map((d) => resolveEntryMacros(db, d.entry)));
    final total = macros.fold(FoodMacros.zero, (sum, m) => sum + m);
    final dayCount = {for (final d in displays) d.entry.date}.length;
    return AverageMacros(
      perDay: dayCount == 0 ? FoodMacros.zero : total / dayCount.toDouble(),
      dayCount: dayCount,
    );
  });
});
