import 'package:drift/drift.dart';
import 'package:drift/native.dart';
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
  // Bounded pumps instead of pumpAndSettle(): loading states briefly show an
  // indeterminate CircularProgressIndicator, whose animation never
  // "settles" on its own within fake_async.
  await tester.pump();
  await tester.pump(const Duration(milliseconds: 50));
  await tester.pump(const Duration(milliseconds: 50));
}

// Disposing drift's watched streams schedules a real Timer.zero; running
// that outside the fake_async zone (via runAsync) lets it actually fire
// instead of tripping flutter_test's "pending timer at teardown" check.
Future<void> _teardown(WidgetTester tester, ProviderContainer container, AppDatabase db) async {
  await tester.runAsync(() async {
    container.dispose();
    await Future<void>.delayed(Duration.zero);
  });
  await db.close();
}

void main() {
  testWidgets('Diario renders the summary card and 5 meal sections once a profile exists',
      (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    await db.userProfileDao.updateProfile(const UserProfileCompanion(
      heightCm: Value(180),
      startingWeightKg: Value(80),
      onboardingCompleted: Value(true),
    ));
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/diario'));

    expect(find.text('DESAYUNO'), findsOneWidget);
    expect(find.text('COMIDA'), findsOneWidget);
    expect(find.text('MERIENDA'), findsOneWidget);
    expect(find.text('CENA'), findsOneWidget);
    expect(find.text('SNACK'), findsOneWidget);
    expect(find.text('Consumidas'), findsOneWidget);
    expect(find.text('Restantes'), findsOneWidget);
    expect(find.text('Quemadas'), findsOneWidget);
    expect(find.textContaining('Sin registrar'), findsWidgets);

    await _teardown(tester, container, db);
  });

  testWidgets('logging a food updates the Consumidas figure', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    await db.userProfileDao.updateProfile(const UserProfileCompanion(
      heightCm: Value(180),
      startingWeightKg: Value(80),
      onboardingCompleted: Value(true),
    ));
    final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
      name: 'Pechuga de pollo',
      kcalPer100g: 165,
      proteinPer100g: 31,
      carbsPer100g: 0,
      fatPer100g: 3.6,
    ));
    final today = DateTime.now();
    await db.diaryDao.logFood(
      date: DateTime(today.year, today.month, today.day),
      mealType: MealType.lunch,
      foodId: foodId,
      quantityGrams: 200,
      orderIndex: 0,
      kcal: 330,
      proteinG: 62,
      carbsG: 0,
      fatG: 7.2,
    );
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/diario'));

    expect(find.text('330'), findsOneWidget); // Consumidas
    expect(find.textContaining('Pechuga de pollo'), findsOneWidget);
    expect(find.textContaining('200 g'), findsOneWidget);

    await _teardown(tester, container, db);
  });
}
