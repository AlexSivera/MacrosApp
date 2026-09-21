import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/router/app_router.dart';

void main() {
  testWidgets('deleting a recipe asks for confirmation and only deletes when confirmed',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(name: 'Tarta de queso'));
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    final router = buildAppRouter(initialLocation: '/recetas/$recipeId');

    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MacrosApp(router: router),
    ));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Tarta de queso'), findsWidgets);

    // Open the overflow menu and tap Eliminar.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    // The confirmation dialog should be showing, and cancelling it must
    // leave the recipe untouched.
    expect(find.text('Cancelar'), findsOneWidget);
    await tester.tap(find.text('Cancelar'));
    await tester.pumpAndSettle();
    expect(await db.recipesDao.getById(recipeId), isNotNull);
    expect(find.text('Tarta de queso'), findsWidgets);

    // Deleting again and confirming this time actually removes it.
    await tester.tap(find.byType(PopupMenuButton<String>));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Eliminar'));
    await tester.pumpAndSettle();

    expect(await db.recipesDao.getById(recipeId), isNull);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
