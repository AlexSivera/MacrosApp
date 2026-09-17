import 'package:drift/drift.dart';

import '../app_database.dart';
import '../tables/custom_list_items_table.dart';
import '../tables/custom_lists_table.dart';

part 'custom_lists_dao.g.dart';

@DriftAccessor(tables: [CustomLists, CustomListItems])
class CustomListsDao extends DatabaseAccessor<AppDatabase> with _$CustomListsDaoMixin {
  CustomListsDao(super.db);

  Stream<List<CustomList>> watchLists() {
    final query = select(customLists)..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    return query.watch();
  }

  Future<int> createList(String name) async {
    final rows = await select(customLists).get();
    final orderIndex = rows.isEmpty ? 0 : rows.map((r) => r.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
    return into(customLists).insert(CustomListsCompanion.insert(name: name, orderIndex: orderIndex));
  }

  Future<void> renameList(int id, String name) async {
    await (update(customLists)..where((t) => t.id.equals(id)))
        .write(CustomListsCompanion(name: Value(name)));
  }

  // Cleans up the list's items in the same transaction rather than relying
  // on `onDelete: KeyAction.cascade` at the database level — this drift
  // version doesn't reliably emit that as an actual SQLite FK constraint
  // (same limitation documented on RecipesDao.deleteRecipe).
  Future<void> deleteList(int id) async {
    await transaction(() async {
      await (delete(customListItems)..where((t) => t.listId.equals(id))).go();
      await (delete(customLists)..where((t) => t.id.equals(id))).go();
    });
  }

  Stream<List<CustomListItem>> watchItems(int listId) {
    final query = select(customListItems)
      ..where((t) => t.listId.equals(listId))
      ..orderBy([(t) => OrderingTerm.asc(t.orderIndex)]);
    return query.watch();
  }

  Future<int> addItem(int listId, String name) async {
    final rows = await (select(customListItems)..where((t) => t.listId.equals(listId))).get();
    final orderIndex = rows.isEmpty ? 0 : rows.map((r) => r.orderIndex).reduce((a, b) => a > b ? a : b) + 1;
    return into(customListItems)
        .insert(CustomListItemsCompanion.insert(listId: listId, name: name, orderIndex: orderIndex));
  }

  Future<void> updateItem(int id, {String? name, bool? checked}) async {
    await (update(customListItems)..where((t) => t.id.equals(id))).write(
      CustomListItemsCompanion(
        name: name != null ? Value(name) : const Value.absent(),
        checked: checked != null ? Value(checked) : const Value.absent(),
      ),
    );
  }

  Future<void> deleteItem(int id) => (delete(customListItems)..where((t) => t.id.equals(id))).go();
}
