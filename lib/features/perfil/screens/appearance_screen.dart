import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class AppearanceScreen extends ConsumerWidget {
  const AppearanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Apariencia')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              children: [
                for (final entry in const {
                  AppearanceMode.light: 'Claro',
                  AppearanceMode.dark: 'Oscuro',
                  AppearanceMode.system: 'Sistema',
                }.entries)
                  RadioListTile<AppearanceMode>(
                    contentPadding: EdgeInsets.zero,
                    title: Text(entry.value),
                    value: entry.key,
                    // ignore: deprecated_member_use
                    groupValue: profile.appearanceMode,
                    // ignore: deprecated_member_use
                    onChanged: (mode) {
                      if (mode == null) return;
                      ref.read(appDatabaseProvider).userProfileDao.updateProfile(
                            UserProfileCompanion(appearanceMode: Value(mode)),
                          );
                    },
                  ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
