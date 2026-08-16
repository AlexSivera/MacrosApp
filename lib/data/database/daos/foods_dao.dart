import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/foods_table.dart';

part 'foods_dao.g.dart';

@DriftAccessor(tables: [Foods])
class FoodsDao extends DatabaseAccessor<AppDatabase> with _$FoodsDaoMixin {
  FoodsDao(super.db);

  // Used to diff the bundled seed list against what's already in the DB —
  // food name is the only stable identity the seed rows have.
  Future<Map<String, Food>> allByName() async {
    final rows = await select(foods).get();
    return {for (final row in rows) row.name: row};
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

  // query filters by name (SQL LIKE, only applied — and result-capped — when
  // non-empty); category filters exactly when given. Either, both, or
  // neither can be active at once, matching the search sheet's text field +
  // category chips.
  Stream<List<Food>> watchFiltered({String query = '', FoodCategory? category}) {
    final statement = select(foods)..orderBy([(f) => OrderingTerm.asc(f.name)]);
    final trimmed = query.trim();
    if (trimmed.isNotEmpty) {
      final likeQuery = '%$trimmed%';
      statement
        ..where((f) => f.name.like(likeQuery))
        ..limit(50);
    }
    if (category != null) {
      statement.where((f) => f.category.equalsValue(category));
    }
    return statement.watch();
  }
}
