import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/theme/app_theme.dart';
import 'data/database/enums.dart';
import 'features/diario/providers/diary_providers.dart';

ThemeMode _toThemeMode(AppearanceMode mode) => switch (mode) {
      AppearanceMode.dark => ThemeMode.dark,
      AppearanceMode.light => ThemeMode.light,
      AppearanceMode.system => ThemeMode.system,
      // Pastel is a single fixed palette, not a light/dark pair, so it's
      // pinned to ThemeMode.light below rather than switching with the
      // system brightness.
      AppearanceMode.pastel => ThemeMode.light,
    };

class MacrosApp extends ConsumerWidget {
  const MacrosApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceMode =
        ref.watch(userProfileStreamProvider).valueOrNull?.appearanceMode ?? AppearanceMode.dark;
    final isPastel = appearanceMode == AppearanceMode.pastel;

    return MaterialApp.router(
      title: 'Kalibra',
      debugShowCheckedModeBanner: false,
      theme: isPastel ? AppTheme.pastel : AppTheme.light,
      darkTheme: isPastel ? AppTheme.pastel : AppTheme.dark,
      themeMode: _toThemeMode(appearanceMode),
      routerConfig: router,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
