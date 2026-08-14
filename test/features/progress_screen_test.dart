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
  testWidgets('Progreso shows the empty-state chart message with no weight logged', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/progreso'));

    expect(find.textContaining('Registra tu peso'), findsOneWidget);

    await _teardown(tester, container, db);
  });

  testWidgets('Progreso shows current/starting weight stats once logs exist', (tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime.now().subtract(const Duration(days: 10)),
      weightKg: 82,
    ));
    await db.bodyWeightDao.insertLog(BodyWeightLogsCompanion.insert(
      date: DateTime.now(),
      weightKg: 79,
    ));
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await _pumpApp(tester, container, buildAppRouter(initialLocation: '/progreso'));

    expect(find.textContaining('79.0'), findsOneWidget); // current
    expect(find.textContaining('82.0'), findsWidgets); // starting

    await _teardown(tester, container, db);
  });
}
