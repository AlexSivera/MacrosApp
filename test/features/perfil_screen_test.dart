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
  testWidgets('Perfil renders the header and all settings sections', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    await db.userProfileDao.updateProfile(const UserProfileCompanion(name: Value('Alex')));
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/perfil'));

    expect(find.text('Alex'), findsOneWidget);
    expect(find.text('Mi objetivo'), findsOneWidget);
    expect(find.text('Mis datos'), findsOneWidget);
    expect(find.text('Objetivos nutricionales'), findsOneWidget);
    expect(find.text('Unidades'), findsOneWidget);
    expect(find.text('Notificaciones'), findsOneWidget);
    expect(find.text('Apariencia'), findsOneWidget);

    // The last section is below the fold in the test viewport.
    await tester.drag(find.byType(Scrollable).first, const Offset(0, -600));
    await tester.pump();

    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('Sobre la aplicación'), findsOneWidget);

    await _teardown(tester, container, db);
  });

  testWidgets('Tapping Mi objetivo navigates to the goal editor', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/perfil'));
    await tester.tap(find.text('Mi objetivo'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(find.text('Perder'), findsOneWidget);
    expect(find.text('Mantener'), findsOneWidget);
    expect(find.text('Ganar'), findsOneWidget);

    await _teardown(tester, container, db);
  });

  testWidgets('Saving a goal change in GoalScreen persists to the database', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/perfil/objetivo'));

    await tester.tap(find.text('Perder'));
    await tester.pump();
    await tester.enterText(find.byType(TextField).first, '75');
    await tester.pump();
    await tester.tap(find.text('Guardar'));
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    final profile = await db.userProfileDao.getProfile();
    expect(profile!.goalType.name, 'lose');
    expect(profile.goalWeightKg, 75);
    expect(profile.weeklyWeightChangeKg, lessThan(0)); // negative for a lose goal

    await _teardown(tester, container, db);
  });
}
