import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
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
  testWidgets("Changing the selected date reloads a different day's entries", (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Manzana',
      kcalPer100g: 52,
      proteinPer100g: 0.3,
      carbsPer100g: 14,
      fatPer100g: 0.2,
    ));
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    await db.diaryDao.logFood(
      date: DateTime(yesterday.year, yesterday.month, yesterday.day),
      mealType: MealType.snack,
      foodId: foodId,
      quantityGrams: 150,
      orderIndex: 0,
      kcal: 78,
      proteinG: 0.45,
      carbsG: 21,
      fatG: 0.3,
    );
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/diario'));
    // Today has nothing logged.
    expect(find.textContaining('Manzana'), findsNothing);

    await tester.tap(find.byIcon(Icons.chevron_left_rounded));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 200));

    expect(find.textContaining('Manzana'), findsOneWidget);
    expect(find.textContaining('150 g'), findsOneWidget);

    await _teardown(tester, container, db);
  });
}
