import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';

class ProfileHeaderCard extends StatelessWidget {
  const ProfileHeaderCard({super.key, required this.profile, required this.currentWeightKg});

  final UserProfileData profile;
  final double? currentWeightKg;

  String get _goalLabel => switch (profile.goalType) {
        GoalType.lose => 'Perder peso',
        GoalType.maintain => 'Mantener peso',
        GoalType.gain => 'Ganar peso',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final name = profile.name?.trim().isNotEmpty == true ? profile.name! : 'Tu perfil';
    final initial = name.substring(0, 1).toUpperCase();

    return AppCard(
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppTheme.accent.withValues(alpha: 0.18),
            child: Text(
              initial,
              style: theme.textTheme.titleLarge?.copyWith(color: AppTheme.accent),
            ),
          ),
          const SizedBox(width: AppSpacing.lg),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(name, style: theme.textTheme.titleMedium),
                const SizedBox(height: AppSpacing.xs),
                Text(_goalLabel, style: theme.textTheme.bodySmall),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  currentWeightKg != null
                      ? '${currentWeightKg!.toStringAsFixed(1)} kg'
                          '${profile.goalWeightKg != null ? ' → ${profile.goalWeightKg!.toStringAsFixed(1)} kg' : ''}'
                      : 'Sin peso registrado',
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
