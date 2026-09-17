import 'package:drift/drift.dart';

import 'custom_lists_table.dart';

class CustomListItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get listId => integer().references(CustomLists, #id, onDelete: KeyAction.cascade)();
  TextColumn get name => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer()();
}
