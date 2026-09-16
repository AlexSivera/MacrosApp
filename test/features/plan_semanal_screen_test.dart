import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/features/plan_semanal/providers/meal_plan_providers.dart';
import 'package:macrosapp/router/app_router.dart';

Future<void> _pumpApp(WidgetTester tester, ProviderContainer container, GoRouter router) async {
  await tester.pumpWidget(UncontrolledProviderScope(
    container: container,
    child: MacrosApp(router: router),
  ));
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

Future<void> _teardown(WidgetTester tester, ProviderContainer container, AppDatabase db) async {
  await tester.runAsync(() async {
    container.dispose();
    await Future<void>.delayed(Duration.zero);
  });
  await db.close();
}

void main() {
  testWidgets('Plan semanal shows the current month and tapping today opens its day screen',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/plan'));

    expect(find.text('Plan semanal'), findsOneWidget);
    // The month grid's weekday header row (L a D).
    expect(find.text('L'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);

    final today = normalizeDate(DateTime.now());
    final gridStart = mondayOf(DateTime(today.year, today.month, 1));
    final todayCellIndex = today.difference(gridStart).inDays;
    await tester.tap(find.byType(InkWell).at(todayCellIndex));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('DESAYUNO'), findsOneWidget);
    expect(find.text('ALMUERZO'), findsOneWidget);
    expect(find.text('COMIDA'), findsOneWidget);
    expect(find.text('MERIENDA'), findsOneWidget);
    expect(find.text('CENA'), findsOneWidget);
    expect(find.text('EXTRA'), findsOneWidget);

    await _teardown(tester, container, db);
  });

  testWidgets('a food planned for today shows up in its meal section and the shopping list',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    final today = DateTime.now();
    await db.mealPlanDao.addFood(
      date: DateTime(today.year, today.month, today.day),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 200,
      orderIndex: 0,
    );
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);
    final router = buildAppRouter(
      initialLocation: '/plan/dia/${planDayPathSegment(DateTime(today.year, today.month, today.day))}',
    );

    await _pumpApp(tester, container, router);

    expect(find.textContaining('Pechuga de pollo'), findsOneWidget);
    expect(find.textContaining('200 g'), findsOneWidget);

    router.go('/plan/compra');
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Lista de la compra'), findsOneWidget);
    expect(find.textContaining('Pechuga de pollo'), findsOneWidget);
    expect(find.text('200 g'), findsOneWidget);

    await _teardown(tester, container, db);
  });
}
