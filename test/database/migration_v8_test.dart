import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/meal_plan_macros_calculator.dart';
import 'package:sqlite3/sqlite3.dart';

// Upgrading a real v7 database (before the planned/eaten split): entries up
// to today become eaten and get snapshotted, future ones stay planned.
void main() {
  test('v7 → v8 backfills eaten + snapshot for past days only', () async {
    final dir = await Directory.systemTemp.createTemp('kalibra_mig');
    final file = File('${dir.path}/db.sqlite');

    // Build today's schema, then strip it back to v7's shape.
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    await fresh.customSelect('SELECT 1').get(); // forces onCreate
    await fresh.close();

    final raw = sqlite3.open(file.path);
    for (final column in ['is_eaten', 'kcal', 'protein_g', 'carbs_g', 'fat_g', 'label_snapshot']) {
      raw.execute('ALTER TABLE meal_plan_entries DROP COLUMN $column');
    }
    raw.execute('ALTER TABLE user_profile DROP COLUMN last_backup_at');
    raw.execute(
      "INSERT INTO foods (name, kcal_per100g, protein_per100g, carbs_per100g, fat_per100g, is_custom, category) "
      "VALUES ('Arroz', 130, 2.7, 28, 0.3, 1, 0)",
    );
    final now = DateTime.now();
    int epoch(DateTime d) => DateTime(d.year, d.month, d.day).millisecondsSinceEpoch ~/ 1000;
    raw.execute(
      'INSERT INTO meal_plan_entries (date, meal_type, food_id, quantity_grams, order_index) '
      'VALUES (${epoch(now.subtract(const Duration(days: 3)))}, 1, 1, 200, 0)',
    );
    raw.execute(
      'INSERT INTO meal_plan_entries (date, meal_type, food_id, quantity_grams, order_index) '
      'VALUES (${epoch(now.add(const Duration(days: 3)))}, 1, 1, 100, 0)',
    );
    raw.execute('PRAGMA user_version = 7');
    raw.dispose();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    final rows = await db.select(db.mealPlanEntries).get();
    rows.sort((a, b) => a.date.compareTo(b.date));

    expect(rows[0].isEaten, isTrue);
    expect(rows[0].kcal, closeTo(260, 0.01));
    expect(rows[0].labelSnapshot, 'Arroz');
    expect(rows[1].isEaten, isFalse);
    expect(rows[1].kcal, isNull);
    expect((await resolveEntryMacros(db, rows[1])).kcal, closeTo(130, 0.01));
    expect((await db.userProfileDao.getProfile())?.lastBackupAt, isNull);

    await db.close();
    await dir.delete(recursive: true);
  });
}
