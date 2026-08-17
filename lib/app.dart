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

class MacrosApp extends ConsumerStatefulWidget {
  const MacrosApp({super.key, required this.router, this.skippedSeedDeletions = const []});

  final GoRouter router;

  // Foods the seed sync wanted to remove (no longer in the bundled catalog)
  // but kept because they're still used by a recipe — surfaced once on
  // launch so the user knows to clear them out of that recipe first.
  final List<String> skippedSeedDeletions;

  @override
  ConsumerState<MacrosApp> createState() => _MacrosAppState();
}

class _MacrosAppState extends ConsumerState<MacrosApp> {
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  @override
  void initState() {
    super.initState();
    if (widget.skippedSeedDeletions.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _scaffoldMessengerKey.currentState?.showSnackBar(SnackBar(
          duration: const Duration(seconds: 10),
          content: Text(
            'No se pudieron quitar del catálogo (están en una receta): '
            '${widget.skippedSeedDeletions.join(', ')}',
          ),
        ));
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final appearanceMode =
        ref.watch(userProfileStreamProvider).valueOrNull?.appearanceMode ?? AppearanceMode.dark;
    final fixedTheme = _fixedTheme(appearanceMode);

    return MaterialApp.router(
      title: 'Kalibra',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: fixedTheme ?? AppTheme.light,
      darkTheme: fixedTheme ?? AppTheme.dark,
      themeMode: _toThemeMode(appearanceMode),
      routerConfig: widget.router,
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
