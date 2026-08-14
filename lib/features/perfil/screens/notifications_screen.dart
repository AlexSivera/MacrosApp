import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class NotificationsScreen extends ConsumerWidget {
  const NotificationsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Notificaciones')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          return Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('Recordatorios'),
              subtitle: const Text('Avisos para registrar tus comidas y tu peso'),
              value: profile.remindersEnabled,
              onChanged: (value) => ref.read(appDatabaseProvider).userProfileDao.updateProfile(
                    UserProfileCompanion(remindersEnabled: Value(value)),
                  ),
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
