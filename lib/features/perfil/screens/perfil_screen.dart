import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../diario/providers/diary_providers.dart';
import '../widgets/profile_header_card.dart';

class PerfilScreen extends ConsumerWidget {
  const PerfilScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileStreamProvider);
    final currentWeight = ref.watch(latestWeightKgProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) {
            return const Center(child: CircularProgressIndicator());
          }
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              ProfileHeaderCard(profile: profile, currentWeightKg: currentWeight),
              const SizedBox(height: AppSpacing.xl),
              _SettingsSection(items: [
                _SettingsItem(Icons.flag_outlined, 'Mi objetivo', '/perfil/objetivo'),
                _SettingsItem(Icons.badge_outlined, 'Mis datos', '/perfil/mis-datos'),
                _SettingsItem(
                  Icons.pie_chart_outline,
                  'Objetivos nutricionales',
                  '/perfil/objetivos-nutricionales',
                ),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(items: [
                _SettingsItem(Icons.straighten_outlined, 'Unidades', '/perfil/unidades'),
                _SettingsItem(Icons.notifications_outlined, 'Notificaciones', '/perfil/notificaciones'),
                _SettingsItem(Icons.palette_outlined, 'Apariencia', '/perfil/apariencia'),
              ]),
              const SizedBox(height: AppSpacing.lg),
              _SettingsSection(items: [
                _SettingsItem(Icons.settings_outlined, 'Configuración', '/perfil/configuracion'),
                _SettingsItem(Icons.info_outline, 'Sobre la aplicación', '/perfil/sobre'),
              ]),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}

class _SettingsItem {
  const _SettingsItem(this.icon, this.label, this.route);

  final IconData icon;
  final String label;
  final String route;
}

class _SettingsSection extends StatelessWidget {
  const _SettingsSection({required this.items});

  final List<_SettingsItem> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            InkWell(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              onTap: () => context.push(items[i].route),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.sm,
                  vertical: AppSpacing.sm,
                ),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: theme.colorScheme.primary.withValues(alpha: 0.12),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(items[i].icon, size: 18, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(child: Text(items[i].label, style: theme.textTheme.bodyLarge)),
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ],
                ),
              ),
            ),
            if (i != items.length - 1)
              Divider(height: AppSpacing.xs, color: theme.colorScheme.outline.withValues(alpha: 0.5)),
          ],
        ],
      ),
    );
  }
}
