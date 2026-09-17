import 'package:drift/drift.dart';
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/core/theme/app_theme.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/daos/meal_plan_dao.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/features/plan_semanal/widgets/plan_food_quantity_sheet.dart';

Future<void> _openSheet(WidgetTester tester, ProviderContainer container, Food food, DateTime date) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MaterialApp(
      theme: AppTheme.dark,
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => PlanFoodQuantitySheet.showAdd(
              context,
              food: food,
              date: date,
              mealType: MealType.breakfast,
            ),
            child: const Text('open'),
          ),
        ),
      ),
    ),
  ));
  await tester.tap(find.text('open'));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 300));
}

void main() {
  testWidgets('a food with a serving size defaults to "1 unidad" and previews its macros',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 150,
      proteinPer100g: 12.5,
      carbsPer100g: 0.5,
      fatPer100g: 11.1,
      defaultServingGrams: const Value(50),
      servingLabel: const Value('1 huevo ≈ 50g'),
    ));
    final egg = (await db.foodsDao.getById(foodId))!;
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    await _openSheet(tester, container, egg, date);

    expect(find.text('Unidades'), findsWidgets);
    expect(find.text('1'), findsOneWidget);
    expect(find.textContaining('1 huevo ≈ 50g'), findsOneWidget);
    // 1 unit = 50g at 150kcal/100g = 75kcal.
    expect(find.text('75'), findsOneWidget);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });

  testWidgets('switching to gramos converts the entered unit count, and it saves as grams',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Huevo',
      kcalPer100g: 150,
      proteinPer100g: 12.5,
      carbsPer100g: 0.5,
      fatPer100g: 11.1,
      defaultServingGrams: const Value(50),
      servingLabel: const Value('1 huevo ≈ 50g'),
    ));
    final egg = (await db.foodsDao.getById(foodId))!;
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    await _openSheet(tester, container, egg, date);

    await tester.enterText(find.byType(TextField), '3');
    await tester.pump();

    await tester.tap(find.text('Gramos'));
    await tester.pump();

    // 3 units * 50g converted into the gramos field.
    expect(find.text('150'), findsOneWidget);

    await tester.tap(find.text('Añadir al plan'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    // Escapes the fake_async zone widget tests run in: Drift delivers a
    // fresh watchEntriesForDate subscription's first value via a real
    // Timer, which pump()'s virtual clock never advances on its own (see
    // meal_plan_providers.dart's note on this exact failure mode).
    late List<MealPlanEntryDisplay> entries;
    await tester.runAsync(() async {
      entries = await db.mealPlanDao.watchEntriesForDate(date).first;
    });
    expect(entries, hasLength(1));
    expect(entries.first.entry.quantityGrams, 150);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });

  testWidgets('a food without a serving size never shows the units toggle', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    final chicken = (await db.foodsDao.getById(foodId))!;
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    final today = DateTime.now();
    final date = DateTime(today.year, today.month, today.day);

    await _openSheet(tester, container, chicken, date);

    expect(find.text('Unidades'), findsNothing);
    expect(find.text('Gramos'), findsNothing);
    expect(find.text('100'), findsOneWidget); // falls back to the plain 100g default

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
