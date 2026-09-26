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
  testWidgets('Plan semanal opens on the week agenda and tapping today opens its day screen',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/plan'));

    expect(find.text('Plan semanal'), findsOneWidget);
    // One agenda row per day, all empty.
    expect(find.text('LUN'), findsOneWidget);
    expect(find.text('DOM'), findsOneWidget);
    expect(find.text('Sin planificar'), findsNWidgets(7));

    final today = normalizeDate(DateTime.now());
    await tester.tap(find.text('${today.day}'));
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

  testWidgets('in Mes, the week of the picked day shows under the grid; tapping it again opens it',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final today = normalizeDate(DateTime.now());
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    for (var i = 0; i < 2; i++) {
      await db.mealPlanDao.addFood(
        date: today,
        mealType: MealType.dinner,
        foodId: foodId,
        quantityGrams: 150,
        orderIndex: i,
      );
    }
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/plan'));
    await tester.tap(find.text('Mes'));
    await tester.pump();
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await tester.pump();

    // The grid's weekday header, and today's week under it with the
    // repeated food collapsed.
    expect(find.text('L'), findsOneWidget);
    expect(find.text('D'), findsOneWidget);
    expect(find.text('Pechuga de pollo ×2'), findsOneWidget);

    // Today starts out selected, so this tap opens it.
    await tester.tap(find.byKey(ValueKey(today)));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.text('CENA'), findsOneWidget);

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

    router.go('/listas/compra');
    await tester.pump();
    // The shopping list's aggregation is a cold Drift stream subscription
    // the moment this screen mounts (it used to share a Navigator stack
    // with PlanDayScreen, which happened to already be subscribed to the
    // same table and kept this passing by coincidence — now that it's its
    // own bottom-nav branch, that's no longer true). Resolving the same
    // query for real inside runAsync warms Drift's stream cache so the
    // widget's own subscription settles under plain pump()s afterwards
    // instead of racing the real Timer a cold subscription needs (see
    // meal_plan_providers.dart's note on this exact failure mode).
    await tester.runAsync(() async {
      final monday = mondayOf(DateTime.now());
      await db.mealPlanDao.watchEntriesInRange(monday, monday.add(const Duration(days: 6))).first;
    });
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Lista de la compra'), findsOneWidget);
    expect(find.textContaining('Pechuga de pollo'), findsOneWidget);
    expect(find.text('200 g'), findsOneWidget);

    await _teardown(tester, container, db);
  });
}
