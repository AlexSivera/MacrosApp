import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:sqlite3/sqlite3.dart';

// v9 adds Recipes.instructions (preparation steps): an existing v8 database
// keeps its recipes, with no steps until they're edited.
void main() {
  test('v8 → v9 adds recipe instructions without touching existing recipes', () async {
    final dir = await Directory.systemTemp.createTemp('kalibra_mig9');
    final file = File('${dir.path}/db.sqlite');

    // Build today's schema, then strip it back to v8's shape.
    final fresh = AppDatabase.forTesting(NativeDatabase(file));
    await fresh.customSelect('SELECT 1').get(); // forces onCreate
    await fresh.close();

    final raw = sqlite3.open(file.path);
    raw.execute('ALTER TABLE recipes DROP COLUMN instructions');
    raw.execute("INSERT INTO recipes (name, servings) VALUES ('Tortilla', 2)");
    raw.execute('PRAGMA user_version = 8');
    raw.dispose();

    final db = AppDatabase.forTesting(NativeDatabase(file));
    final recipe = (await db.select(db.recipes).get()).single;
    expect(recipe.name, 'Tortilla');
    expect(recipe.servings, 2);
    expect(recipe.instructions, isNull);

    await db.recipesDao.updateRecipe(recipe.copyWith(instructions: const Value('Batir\nCuajar')));
    expect((await db.recipesDao.getById(recipe.id))!.instructions, 'Batir\nCuajar');

    await db.close();
    await dir.delete(recursive: true);
  });
}
