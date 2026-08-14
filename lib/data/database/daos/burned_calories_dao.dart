import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/burned_calories_table.dart';
import 'diary_dao.dart' show DiaryDao;

part 'burned_calories_dao.g.dart';

@DriftAccessor(tables: [BurnedCalories])
class BurnedCaloriesDao extends DatabaseAccessor<AppDatabase>
    with _$BurnedCaloriesDaoMixin {
  BurnedCaloriesDao(super.db);

  Stream<List<BurnedCalory>> watchForDate(DateTime date) {
    final day = DiaryDao.normalizeDate(date);
    return (select(burnedCalories)..where((b) => b.date.equals(day))).watch();
  }

  Future<int> insertLog(BurnedCaloriesCompanion entry) => into(burnedCalories).insert(entry);

  Future<int> deleteLog(int id) => (delete(burnedCalories)..where((b) => b.id.equals(id))).go();
}
