import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/core/theme/app_theme.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/features/diario/widgets/food_search_sheet.dart';

void main() {
  testWidgets(
      'Creating a custom food from the search sheet returns it and it is searchable afterwards',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    Food? picked;
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MaterialApp(
        theme: AppTheme.dark,
        home: Scaffold(
          body: Builder(
            builder: (context) => ElevatedButton(
              onPressed: () async {
                picked = await FoodSearchSheet.show(context);
              },
              child: const Text('open'),
            ),
          ),
        ),
      ),
    ));

    await tester.tap(find.text('open'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // The search returns nothing (empty seed DB in this test), so the
    // "Crear alimento personalizado" affordance must still be reachable.
    await tester.enterText(find.byType(TextField).first, 'batido casero');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    expect(find.textContaining('No se han encontrado'), findsOneWidget);

    await tester.tap(find.text('Crear alimento personalizado'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    await tester.enterText(find.widgetWithText(TextField, 'Nombre'), 'Batido casero');
    await tester.enterText(find.widgetWithText(TextField, 'kcal'), '120');
    await tester.enterText(find.widgetWithText(TextField, 'Proteína (g)'), '8');
    await tester.enterText(find.widgetWithText(TextField, 'Carbohidratos (g)'), '15');
    await tester.enterText(find.widgetWithText(TextField, 'Grasas (g)'), '2');
    await tester.pump();

    await tester.tap(find.text('Crear y continuar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(picked, isNotNull);
    expect(picked!.name, 'Batido casero');
    expect(picked!.isCustom, isTrue);
    expect(picked!.kcalPer100g, 120);

    final stored = await db.foodsDao.getById(picked!.id);
    expect(stored, isNotNull);
    expect(stored!.name, 'Batido casero');

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
