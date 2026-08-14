import 'package:drift/drift.dart' hide isNull;
import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/router/app_router.dart';

Future<void> _pumpAt(
  WidgetTester tester,
  ProviderContainer container,
  GoRouter router,
  Size size,
) async {
  tester.view.physicalSize = size;
  tester.view.devicePixelRatio = 1.0;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);

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
  // A small/old phone width (iPhone SE class) — the narrowest realistic
  // target — and a tablet width, both well outside the default test
  // viewport, to catch RenderFlex overflow that only shows up at the edges.
  const narrowPhone = Size(320, 640);
  const tablet = Size(1024, 1366);

  for (final size in [narrowPhone, tablet]) {
    testWidgets('Diario with logged data has no overflow at ${size.width}x${size.height}',
        (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.userProfileDao.ensureDefaultRow();
      await db.userProfileDao.updateProfile(const UserProfileCompanion(
        heightCm: Value(180),
        startingWeightKg: Value(80),
        onboardingCompleted: Value(true),
      ));
      final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
        name: 'Pechuga de pollo con una etiqueta bastante larga para forzar el ancho',
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

      await _pumpAt(tester, container, buildAppRouter(initialLocation: '/diario'), size);

      expect(tester.takeException(), isNull);
      await _teardown(tester, container, db);
    });

    testWidgets('Recetas grid has no overflow at ${size.width}x${size.height}', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      final foodId = await db.foodsDao.insert(FoodsCompanion.insert(
        name: 'Arroz',
        kcalPer100g: 130,
        proteinPer100g: 2.7,
        carbsPer100g: 28,
        fatPer100g: 0.3,
      ));
      final recipeId = await db.recipesDao.insert(RecipesCompanion.insert(
        name: 'Una receta con un nombre bastante largo para forzar el diseño',
        prepTimeMinutes: const Value(25),
      ));
      await db.recipeIngredientsDao.replaceIngredients(recipeId, [
        RecipeIngredientsCompanion.insert(
            recipeId: recipeId, foodId: foodId, grams: 200, orderIndex: 0),
      ]);
      final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

      await _pumpAt(tester, container, buildAppRouter(initialLocation: '/recetas'), size);

      expect(tester.takeException(), isNull);
      await _teardown(tester, container, db);
    });

    testWidgets('Progreso has no overflow at ${size.width}x${size.height}', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.userProfileDao.ensureDefaultRow();
      await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
        date: DateTime.now(),
        weightKg: 82.4,
      ));
      final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

      await _pumpAt(tester, container, buildAppRouter(initialLocation: '/progreso'), size);

      expect(tester.takeException(), isNull);
      await _teardown(tester, container, db);
    });

    testWidgets('Perfil has no overflow at ${size.width}x${size.height}', (tester) async {
      final db = AppDatabase.forTesting(NativeDatabase.memory());
      await db.userProfileDao.ensureDefaultRow();
      final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

      await _pumpAt(tester, container, buildAppRouter(initialLocation: '/perfil'), size);

      expect(tester.takeException(), isNull);
      await _teardown(tester, container, db);
    });
  }
}
