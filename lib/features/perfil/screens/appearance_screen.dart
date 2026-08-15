import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class _AppearanceOption {
  const _AppearanceOption(this.label, this.icon, this.swatch);

  final String label;
  final IconData icon;
  final Color swatch;
}

const _options = {
  AppearanceMode.light: _AppearanceOption('Claro', Icons.wb_sunny_rounded, AppTheme.backgroundLight),
  AppearanceMode.dark: _AppearanceOption('Oscuro', Icons.nightlight_round, AppTheme.background),
  AppearanceMode.system: _AppearanceOption(
    'Sistema',
    Icons.smartphone_rounded,
    AppTheme.surfaceRaisedLight,
  ),
  AppearanceMode.pastel: _AppearanceOption('Pastel', Icons.favorite_rounded, AppTheme.pastelAccent),
};

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Apariencia')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          final selected = profile.appearanceMode;
          return ListView.separated(
            padding: const EdgeInsets.all(AppSpacing.lg),
            itemCount: _options.length,
            separatorBuilder: (_, _) => const SizedBox(height: AppSpacing.sm),
            itemBuilder: (context, index) {
              final entry = _options.entries.elementAt(index);
              final mode = entry.key;
              final option = entry.value;
              final isSelected = mode == selected;

              return InkWell(
                borderRadius: BorderRadius.circular(16),
                onTap: () => ref.read(appDatabaseProvider).userProfileDao.updateProfile(
                      UserProfileCompanion(appearanceMode: Value(mode)),
                    ),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? theme.colorScheme.primary.withValues(alpha: 0.10)
                        : theme.cardTheme.color,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(
                      color: isSelected ? theme.colorScheme.primary : theme.dividerColor,
                      width: isSelected ? 1.5 : 1,
                    ),
                    boxShadow: AppTheme.softShadow(context),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: option.swatch,
                          shape: BoxShape.circle,
                          border: Border.all(color: theme.dividerColor),
                        ),
                        child: Icon(
                          option.icon,
                          size: 18,
                          color: mode == AppearanceMode.pastel
                              ? AppTheme.pastelOnAccent
                              : (mode == AppearanceMode.dark
                                  ? Colors.white70
                                  : Colors.black54),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Text(option.label, style: theme.textTheme.titleMedium),
                      ),
                      if (isSelected)
                        Icon(Icons.check_circle_rounded, color: theme.colorScheme.primary)
                      else
                        Icon(Icons.circle_outlined, color: theme.dividerColor),
                    ],
                  ),
                ),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
