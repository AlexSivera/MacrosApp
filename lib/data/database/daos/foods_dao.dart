import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/foods_table.dart';

part 'foods_dao.g.dart';

@DriftAccessor(tables: [Foods])
class FoodsDao extends DatabaseAccessor<AppDatabase> with _$FoodsDaoMixin {
  FoodsDao(super.db);

  // Used to diff the bundled seed list against what's already in the DB —
  // food name is the only stable identity the seed rows have.
  Future<Set<String>> allNames() async {
    final rows = await select(foods).get();
    return rows.map((r) => r.name).toSet();
  }

  Future<void> insertAll(List<FoodsCompanion> entries) {
    return batch((b) => b.insertAll(foods, entries));
  }

  Future<int> insert(FoodsCompanion entry) => into(foods).insert(entry);

  Future<bool> updateFood(Food entry) => update(foods).replace(entry);

  Future<int> deleteFood(int id) => (delete(foods)..where((f) => f.id.equals(id))).go();

  Stream<Food?> watchById(int id) =>
      (select(foods)..where((f) => f.id.equals(id))).watchSingleOrNull();

  Future<Food?> getById(int id) =>
      (select(foods)..where((f) => f.id.equals(id))).getSingleOrNull();

  Stream<List<Food>> watchAll() =>
      (select(foods)..orderBy([(f) => OrderingTerm.asc(f.name)])).watch();

  Stream<List<Food>> watchSearch(String query) {
    final q = '%${query.trim()}%';
    return (select(foods)
          ..where((f) => f.name.like(q))
          ..orderBy([(f) => OrderingTerm.asc(f.name)])
          ..limit(50))
        .watch();
  }
}
