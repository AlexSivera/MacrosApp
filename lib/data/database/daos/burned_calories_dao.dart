import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/burned_calories_table.dart';
import 'meal_plan_dao.dart' show MealPlanDao;

part 'burned_calories_dao.g.dart';

@DriftAccessor(tables: [BurnedCalories])
class BurnedCaloriesDao extends DatabaseAccessor<AppDatabase>
    with _$BurnedCaloriesDaoMixin {
  BurnedCaloriesDao(super.db);

  Stream<List<BurnedCalory>> watchForDate(DateTime date) {
    final day = MealPlanDao.normalizeDate(date);
    return (select(burnedCalories)..where((b) => b.date.equals(day))).watch();
  }

  Future<int> insertLog(BurnedCaloriesCompanion entry) => into(burnedCalories).insert(entry);

  Future<int> deleteLog(int id) => (delete(burnedCalories)..where((b) => b.id.equals(id))).go();

  // One device-sourced row per day: re-syncing (e.g. from Health Connect)
  // replaces that day's previous device entry instead of accumulating
  // duplicates, while leaving any manual entries for the same day untouched.
  Future<void> upsertDeviceEntryForDate(DateTime date, double kcal, {String? label}) async {
    final day = MealPlanDao.normalizeDate(date);
    await transaction(() async {
      await (delete(burnedCalories)
            ..where((b) => b.date.equals(day) & b.source.equalsValue(BurnedCalorieSource.device)))
          .go();
      if (kcal > 0) {
        await into(burnedCalories).insert(BurnedCaloriesCompanion.insert(
          date: day,
          kcal: kcal,
          label: Value(label),
          source: const Value(BurnedCalorieSource.device),
        ));
      }
    });
  }
}
