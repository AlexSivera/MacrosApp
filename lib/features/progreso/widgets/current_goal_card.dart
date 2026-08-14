import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
import '../../diario/providers/diary_providers.dart';

class CurrentGoalCard extends StatelessWidget {
  const CurrentGoalCard({super.key, required this.goalType, required this.targets});

  final GoalType goalType;
  final ResolvedTargets targets;

  String get _goalLabel => switch (goalType) {
        GoalType.lose => 'Perder peso',
        GoalType.maintain => 'Mantener peso',
        GoalType.gain => 'Ganar peso',
      };

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Objetivo actual', style: theme.textTheme.labelMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(_goalLabel, style: theme.textTheme.titleMedium),
          const SizedBox(height: AppSpacing.md),
          Text(
            '${targets.calorieTarget} kcal · '
            'P${targets.proteinG.round()}g · '
            'C${targets.carbsG.round()}g · '
            'G${targets.fatG.round()}g',
            style: theme.textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }
}
