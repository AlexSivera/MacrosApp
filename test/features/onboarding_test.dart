import 'package:drift/native.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/app.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/data/database/database_provider.dart';
import 'package:macrosapp/router/app_router.dart';

Future<void> _settle(WidgetTester tester) async {
  for (var i = 0; i < 6; i++) {
    await tester.pump(const Duration(milliseconds: 100));
  }
}

void main() {
  testWidgets('onboarding walks three steps, shows the computed target and saves the profile', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390 * 3, 844 * 3);
    tester.view.devicePixelRatio = 3;
    addTearDown(tester.view.reset);

    final db = AppDatabase.forTesting(NativeDatabase.memory());
    await db.userProfileDao.ensureDefaultRow();
    final container = ProviderContainer(overrides: [appDatabaseProvider.overrideWithValue(db)]);

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MacrosApp(router: buildAppRouter(initialLocation: '/onboarding')),
      ),
    );
    await _settle(tester);

    expect(find.text('Sobre ti'), findsOneWidget);
    expect(find.text('Paso 1 de 3'), findsOneWidget);

    // Missing height/weight blocks the first step.
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.textContaining('altura'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Altura'), '180');
    await tester.enterText(find.widgetWithText(TextField, 'Peso actual'), '80,5');
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Tu objetivo'), findsOneWidget);

    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Tu plan'), findsOneWidget);
    expect(find.text('kcal al día'), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await _settle(tester);

    final profile = await tester.runAsync(db.userProfileDao.getProfile);
    expect(profile!.onboardingCompleted, isTrue);
    expect(profile.heightCm, 180);
    expect(profile.startingWeightKg, 80.5);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
