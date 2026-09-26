import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'core/platform/web_shell.dart';
import 'core/theme/app_theme.dart';
import 'data/database/enums.dart';
import 'features/diario/providers/diary_providers.dart';
import 'features/plan_semanal/providers/meal_plan_providers.dart';

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
  late final AppLifecycleListener _lifecycle;

  @override
  void initState() {
    super.initState();
    requestPersistentStorage();
    _lifecycle = AppLifecycleListener(onResume: _rollOverDay, onShow: _rollOverDay);
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
  void dispose() {
    _lifecycle.dispose();
    super.dispose();
  }

  // An installed PWA is often resumed days after it was opened. When the
  // calendar day changed while it was in the background, move every "current
  // period" view that was still showing the old today along to the new one —
  // but leave alone any view the user had deliberately navigated elsewhere.
  void _rollOverDay() {
    final oldToday = ref.read(todayProvider);
    final newToday = currentDay();
    if (oldToday == newToday) return;
    ref.read(todayProvider.notifier).state = newToday;

    void follow(StateProvider<DateTime> provider, DateTime oldValue, DateTime newValue) {
      if (ref.read(provider) == oldValue) ref.read(provider.notifier).state = newValue;
    }

    follow(selectedDiaryDateProvider, oldToday, newToday);
    follow(selectedPlanWeekStartProvider, mondayOf(oldToday), mondayOf(newToday));
    follow(shoppingListWeekStartProvider, mondayOf(oldToday), mondayOf(newToday));
    follow(
      selectedPlanMonthProvider,
      DateTime(oldToday.year, oldToday.month, 1),
      DateTime(newToday.year, newToday.month, 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final appearanceMode =
        ref.watch(userProfileStreamProvider).valueOrNull?.appearanceMode ?? AppearanceMode.system;
    final fixedTheme = _fixedTheme(appearanceMode);

    return MaterialApp.router(
      title: 'Kalibra',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: _scaffoldMessengerKey,
      theme: fixedTheme ?? AppTheme.light,
      darkTheme: fixedTheme ?? AppTheme.dark,
      themeMode: _toThemeMode(appearanceMode),
      // Lerping between two skins produced muddy grey frames with heavy
      // shadows mid-way; an instant switch reads cleaner.
      themeAnimationDuration: Duration.zero,
      routerConfig: widget.router,
      locale: const Locale('es'),
      supportedLocales: const [Locale('es')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      builder: (context, child) {
        // Keeps the browser's theme-color / page background in step with
        // whichever theme actually resolved (incl. "Sistema").
        applyWebShellColor(Theme.of(context).scaffoldBackgroundColor);
        return child!;
      },
    );
  }
}
