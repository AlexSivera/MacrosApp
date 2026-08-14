import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';

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
  return today.subtract(Duration(days: range.days - 1));
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

// Averages the diary's logged macros over the selected range — divides by
// the range's full day count (not just days with entries logged), so a
// mostly-untracked range correctly shows a low average instead of an
// inflated one.
final averageMacrosForRangeProvider = StreamProvider.autoDispose<AverageMacros>((ref) {
  final range = ref.watch(progressRangeProvider);
  final db = ref.watch(appDatabaseProvider);
  final start = _startOfRange(range);
  return db.diaryDao.watchEntriesInRange(start, DateTime.now()).map((entries) {
    final total = entries.fold(
      FoodMacros.zero,
      (sum, e) => sum + FoodMacros(kcal: e.kcal, proteinG: e.proteinG, carbsG: e.carbsG, fatG: e.fatG),
    );
    final dayCount = range.days;
    return AverageMacros(perDay: total / dayCount.toDouble(), dayCount: dayCount);
  });
});
