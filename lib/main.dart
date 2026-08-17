import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'data/database/app_database.dart';
import 'data/database/database_provider.dart';
import 'data/seed/food_seeder.dart';
import 'router/app_router.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es');

  final db = AppDatabase();
  final skippedDeletions = await syncSeedFoods(db);
  await db.userProfileDao.ensureDefaultRow();
  final onboardingDone = await db.userProfileDao.isOnboardingCompleted();

  final router = buildAppRouter(initialLocation: onboardingDone ? '/diario' : '/onboarding');

  runApp(ProviderScope(
    overrides: [appDatabaseProvider.overrideWithValue(db)],
    child: MacrosApp(router: router, skippedSeedDeletions: skippedDeletions),
  ));
}
