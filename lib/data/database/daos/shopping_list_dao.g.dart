// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shopping_list_dao.dart';

// ignore_for_file: type=lint
mixin _$ShoppingListDaoMixin on DatabaseAccessor<AppDatabase> {
  $ShoppingListManualItemsTable get shoppingListManualItems =>
      attachedDatabase.shoppingListManualItems;
  $ShoppingListWeekModesTable get shoppingListWeekModes =>
      attachedDatabase.shoppingListWeekModes;
  ShoppingListDaoManager get managers => ShoppingListDaoManager(this);
}

class ShoppingListDaoManager {
  final _$ShoppingListDaoMixin _db;
  ShoppingListDaoManager(this._db);
  $$ShoppingListManualItemsTableTableManager get shoppingListManualItems =>
      $$ShoppingListManualItemsTableTableManager(
        _db.attachedDatabase,
        _db.shoppingListManualItems,
      );
  $$ShoppingListWeekModesTableTableManager get shoppingListWeekModes =>
      $$ShoppingListWeekModesTableTableManager(
        _db.attachedDatabase,
        _db.shoppingListWeekModes,
      );
}
