import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  final week = DateTime(2026, 9, 14);

  test('a week with no stored mode defaults to automatic (not manual)', () async {
    expect(await db.shoppingListDao.watchMode(week).first, isFalse);
  });

  test('setMode persists per week and does not affect other weeks', () async {
    await db.shoppingListDao.setMode(week, manual: true);
    expect(await db.shoppingListDao.watchMode(week).first, isTrue);
    expect(await db.shoppingListDao.watchMode(week.add(const Duration(days: 7))).first, isFalse);

    await db.shoppingListDao.setMode(week, manual: false);
    expect(await db.shoppingListDao.watchMode(week).first, isFalse);
  });

  test('addManualItem/updateManualItem/deleteManualItem manage a week\'s free-text list', () async {
    final id1 = await db.shoppingListDao.addManualItem(week, 'Pan de molde');
    final id2 = await db.shoppingListDao.addManualItem(week, 'Tomates');

    var items = await db.shoppingListDao.watchManualItems(week).first;
    expect(items.map((i) => i.name), ['Pan de molde', 'Tomates']);
    expect(items.every((i) => !i.checked), isTrue);

    await db.shoppingListDao.updateManualItem(id1, checked: true);
    items = await db.shoppingListDao.watchManualItems(week).first;
    expect(items.firstWhere((i) => i.id == id1).checked, isTrue);
    expect(items.firstWhere((i) => i.id == id2).checked, isFalse);

    await db.shoppingListDao.deleteManualItem(id2);
    items = await db.shoppingListDao.watchManualItems(week).first;
    expect(items.map((i) => i.name), ['Pan de molde']);
  });

  test('manual items are scoped to their own week', () async {
    final otherWeek = week.add(const Duration(days: 7));
    await db.shoppingListDao.addManualItem(week, 'Esta semana');
    await db.shoppingListDao.addManualItem(otherWeek, 'La próxima');

    expect((await db.shoppingListDao.watchManualItems(week).first).map((i) => i.name),
        ['Esta semana']);
    expect((await db.shoppingListDao.watchManualItems(otherWeek).first).map((i) => i.name),
        ['La próxima']);
  });

  test('resetAllData wipes manual items and week modes', () async {
    await db.shoppingListDao.setMode(week, manual: true);
    await db.shoppingListDao.addManualItem(week, 'Pan');

    await db.resetAllData();

    expect(await db.shoppingListDao.watchMode(week).first, isFalse);
    expect(await db.shoppingListDao.watchManualItems(week).first, isEmpty);
  });
}
