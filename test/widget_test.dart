import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/router/app_router.dart';

void main() {
  testWidgets('App boots to Diario with 4-tab bottom nav', (WidgetTester tester) async {
    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();

    // A manually-owned ProviderContainer (not ProviderScope's ambient one)
    // so it can be disposed explicitly inside tester.runAsync() below —
    // disposing drift's watched streams schedules a real Timer.zero, and
    // running that outside the fake_async zone lets it actually fire
    // instead of tripping flutter_test's "pending timer at teardown" check.
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    final router = buildAppRouter(initialLocation: '/diario');
    await tester.pumpWidget(UncontrolledProviderScope(
      container: container,
      child: MacrosApp(router: router),
    ));
    // Bounded pumps instead of pumpAndSettle(): the Diario screen briefly
    // shows an indeterminate CircularProgressIndicator while its streams'
    // first values are pending, and that animation never "settles" on its
    // own within fake_async.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.text('Diario'), findsWidgets);
    expect(find.byType(NavigationBar), findsOneWidget);
    expect(find.text('Recetas'), findsWidgets);
    expect(find.text('Progreso'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
