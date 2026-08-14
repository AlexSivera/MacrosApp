import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
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
    return Card(
      margin: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < items.length; i++) ...[
            ListTile(
              leading: Icon(items[i].icon),
              title: Text(items[i].label),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => context.push(items[i].route),
            ),
            if (i != items.length - 1) const Divider(height: 1, indent: AppSpacing.xxl),
          ],
        ],
      ),
    );
  }
}
