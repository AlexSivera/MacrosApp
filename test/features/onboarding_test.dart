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

    // Missing sex/height/weight blocks the first step, each error under its field.
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Introduce tu altura'), findsOneWidget);
    expect(find.text('Introduce tu peso'), findsOneWidget);
    expect(find.textContaining('según el sexo'), findsOneWidget);

    await tester.tap(find.text('Hombre'));
    await _settle(tester);
    expect(find.textContaining('según el sexo'), findsNothing);

    await tester.enterText(find.widgetWithText(TextField, 'Altura'), '180');
    await tester.enterText(find.widgetWithText(TextField, 'Peso actual'), '80,5');
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Tu objetivo'), findsOneWidget);

    // Losing weight needs a goal weight, and one below the current weight.
    await tester.tap(find.text('Perder'));
    await _settle(tester);
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Tu objetivo'), findsOneWidget);
    expect(find.textContaining('quieres llegar a pesar'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Peso objetivo'), '85');
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.textContaining('menor que 80,5 kg'), findsOneWidget);

    await tester.enterText(find.widgetWithText(TextField, 'Peso objetivo'), '75');
    await tester.tap(find.text('Siguiente'));
    await _settle(tester);
    expect(find.text('Tu plan'), findsOneWidget);
    expect(find.text('kcal al día'), findsOneWidget);
    // The breakdown behind the number.
    expect(find.text('Gasto diario estimado'), findsOneWidget);
    expect(find.text('Déficit para perder 0,5 kg/semana'), findsOneWidget);
    expect(find.text('−550 kcal'), findsOneWidget);
    expect(find.textContaining('llegarías a 75,0 kg'), findsOneWidget);

    await tester.tap(find.text('Empezar'));
    await tester.runAsync(() => Future<void>.delayed(const Duration(milliseconds: 50)));
    await _settle(tester);

    final profile = await tester.runAsync(db.userProfileDao.getProfile);
    expect(profile!.onboardingCompleted, isTrue);
    expect(profile.heightCm, 180);
    expect(profile.startingWeightKg, 80.5);
    expect(profile.goalType, GoalType.lose);
    expect(profile.goalWeightKg, 75);

    await tester.runAsync(() async {
      container.dispose();
      await Future<void>.delayed(Duration.zero);
    });
    await db.close();
  });
}
