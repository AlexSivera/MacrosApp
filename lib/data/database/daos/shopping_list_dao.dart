import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/shopping_list_manual_items_table.dart';

part 'shopping_list_dao.g.dart';

@DriftAccessor(tables: [ShoppingListManualItems, ShoppingListWeekModes])
class ShoppingListDao extends DatabaseAccessor<AppDatabase> with _$ShoppingListDaoMixin {
  ShoppingListDao(super.db);

  static DateTime _normalize(DateTime date) => DateTime(date.year, date.month, date.day);

  // Defaults to automatic (false) for a week with no stored mode row yet.
  Stream<bool> watchMode(DateTime weekStart) {
    final week = _normalize(weekStart);
    final query = select(shoppingListWeekModes)..where((t) => t.weekStart.equals(week));
    return query.watchSingleOrNull().map((row) => row?.manual ?? false);
  }

  Future<void> setMode(DateTime weekStart, {required bool manual}) {
    return into(shoppingListWeekModes).insertOnConflictUpdate(
      ShoppingListWeekModesCompanion.insert(weekStart: _normalize(weekStart), manual: Value(manual)),
    );
  }

  Stream<List<ShoppingListManualItem>> watchManualItems(DateTime weekStart) {
    final week = _normalize(weekStart);
    final query = select(shoppingListManualItems)
      ..where((t) => t.weekStart.equals(week))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    return query.watch();
  }

  Future<int> addManualItem(DateTime weekStart, String name) async {
    final week = _normalize(weekStart);
    final rows = await (select(shoppingListManualItems)..where((t) => t.weekStart.equals(week))).get();
    final orderIndex = rows.isEmpty ? 0 : rows.map((r) => r.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
    return into(shoppingListManualItems).insert(
      ShoppingListManualItemsCompanion.insert(weekStart: week, name: name, orderIndex: orderIndex),
    );
  }

  Future<void> updateManualItem(int id, {String? name, bool? checked}) async {
    await (update(shoppingListManualItems)..where((t) => t.id.equals(id))).write(
      ShoppingListManualItemsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        checked: checked != null ? Value(checked) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteManualItem(int id) =>
      (delete(shoppingListManualItems)..where((t) => t.id.equals(id))).go();
}
