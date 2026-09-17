import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  test('createList assigns increasing orderIndex, watchLists returns them in order', () async {
    final id1 = await db.customListsDao.createList('Tappers');
    final id2 = await db.customListsDao.createList('Congelador');

    final lists = await db.customListsDao.watchLists().first;
    expect(lists.map((l) => l.name), ['Tappers', 'Congelador']);
    expect(lists.map((l) => l.id), [id1, id2]);
  });

  test('renameList updates the name in place', () async {
    final id = await db.customListsDao.createList('Tappers');
    await db.customListsDao.renameList(id, 'Tappers de la semana');

    final lists = await db.customListsDao.watchLists().first;
    expect(lists.single.name, 'Tappers de la semana');
  });

  test('addItem/updateItem/deleteItem manage a list\'s items independently of other lists', () async {
    final listId = await db.customListsDao.createList('Congelador');
    final otherListId = await db.customListsDao.createList('Tappers');
    final itemId1 = await db.customListsDao.addItem(listId, 'Pollo');
    final itemId2 = await db.customListsDao.addItem(listId, 'Guisantes');
    await db.customListsDao.addItem(otherListId, 'Lentejas');

    var items = await db.customListsDao.watchItems(listId).first;
    expect(items.map((i) => i.name), ['Pollo', 'Guisantes']);
    expect(items.every((i) => !i.checked), isTrue);

    await db.customListsDao.updateItem(itemId1, checked: true);
    items = await db.customListsDao.watchItems(listId).first;
    expect(items.firstWhere((i) => i.id == itemId1).checked, isTrue);

    await db.customListsDao.deleteItem(itemId2);
    items = await db.customListsDao.watchItems(listId).first;
    expect(items.map((i) => i.name), ['Pollo']);
  });

  test('deleteList cascades to its own items but leaves other lists untouched', () async {
    final listId = await db.customListsDao.createList('Congelador');
    final otherListId = await db.customListsDao.createList('Tappers');
    await db.customListsDao.addItem(listId, 'Pollo');
    await db.customListsDao.addItem(otherListId, 'Lentejas');

    await db.customListsDao.deleteList(listId);

    final lists = await db.customListsDao.watchLists().first;
    expect(lists.map((l) => l.name), ['Tappers']);
    final orphanedItems = await db.customListsDao.watchItems(listId).first;
    expect(orphanedItems, isEmpty);
    final otherItems = await db.customListsDao.watchItems(otherListId).first;
    expect(otherItems.map((i) => i.name), ['Lentejas']);
  });

  test('resetAllData wipes every custom list and its items', () async {
    final listId = await db.customListsDao.createList('Congelador');
    await db.customListsDao.addItem(listId, 'Pollo');

    await db.resetAllData();

    expect(await db.customListsDao.watchLists().first, isEmpty);
    expect(await db.customListsDao.watchItems(listId).first, isEmpty);
  });
}
