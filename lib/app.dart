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
      // Pastel/Green are single fixed palettes, not a light/dark pair, so
      // they're pinned to ThemeMode.light below rather than switching with
      // the system brightness.
      AppearanceMode.pastel || AppearanceMode.green => ThemeMode.light,
    };

// The fixed-palette skins (Pastel, Green) use the same ThemeData for both
// the light and dark slots so they never switch with system brightness;
// null means "not a fixed skin", falling back to the normal light/dark pair.
ThemeData? _fixedTheme(AppearanceMode mode) => switch (mode) {
      AppearanceMode.pastel => AppTheme.pastel,
      AppearanceMode.green => AppTheme.green,
      _ => null,
    };

class MacrosApp extends ConsumerWidget {
  const MacrosApp({super.key, required this.router});

  final GoRouter router;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appearanceMode =
        ref.watch(userProfileStreamProvider).valueOrNull?.appearanceMode ?? AppearanceMode.dark;
    final fixedTheme = _fixedTheme(appearanceMode);

    return MaterialApp.router(
      title: 'Kalibra',
      debugShowCheckedModeBanner: false,
      theme: fixedTheme ?? AppTheme.light,
      darkTheme: fixedTheme ?? AppTheme.dark,
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
