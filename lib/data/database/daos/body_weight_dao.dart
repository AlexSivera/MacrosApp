import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/body_weight_logs_table.dart';

part 'body_weight_dao.g.dart';

@DriftAccessor(tables: [BodyWeightLogs])
class BodyWeightDao extends DatabaseAccessor<AppDatabase> with _$BodyWeightDaoMixin {
  BodyWeightDao(super.db);

  Stream<BodyWeightLog?> watchLatest() {
    return (select(bodyWeightLogs)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(1))
        .watchSingleOrNull();
  }

  Stream<List<BodyWeightLog>> watchHistory({int limit = 400}) {
    return (select(bodyWeightLogs)
          ..orderBy([(w) => OrderingTerm.desc(w.date)])
          ..limit(limit))
        .watch();
  }

  Stream<List<BodyWeightLog>> watchInRange(DateTime start, DateTime end) {
    return (select(bodyWeightLogs)
          ..where((w) => w.date.isBiggerOrEqualValue(start) & w.date.isSmallerOrEqualValue(end))
          ..orderBy([(w) => OrderingTerm.asc(w.date)]))
        .watch();
  }

  Future<BodyWeightLog?> earliest() =>
      (select(bodyWeightLogs)
            ..orderBy([(w) => OrderingTerm.asc(w.date)])
            ..limit(1))
          .getSingleOrNull();

  Future<int> insertLog(BodyWeightLogsCompanion entry) {
    return into(bodyWeightLogs).insert(entry);
  }

  // One weight per calendar day: logging again on the same day corrects it
  // instead of adding a second point to the chart.
  Future<void> logForDay(DateTime day, double weightKg) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day + 1);
    await transaction(() async {
      await (delete(
        bodyWeightLogs,
      )..where((w) => w.date.isBiggerOrEqualValue(start) & w.date.isSmallerThanValue(end))).go();
      await into(bodyWeightLogs).insert(BodyWeightLogsCompanion.insert(date: start, weightKg: weightKg));
    });
  }

  Future<int> deleteLog(int id) {
    return (delete(bodyWeightLogs)..where((w) => w.id.equals(id))).go();
  }
}
