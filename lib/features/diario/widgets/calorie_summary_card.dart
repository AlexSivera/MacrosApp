import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circular_calorie_ring.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import 'macro_progress_bars.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({super.key, required this.summary});

  final DiarySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AppCard(
      child: Column(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: _StatColumn(
                  value: summary.consumedKcal.round().toString(),
                  label: 'CONSUMIDAS',
                ),
              ),
              CircularCalorieRing(
                fraction: summary.ringFraction,
                isOverTarget: summary.isOverTarget,
                centerValue: summary.remainingKcal.round().abs().toString(),
                centerLabel: summary.isOverTarget ? 'EXCEDIDAS' : 'RESTANTES',
              ),
              Expanded(
                child: _StatColumn(
                  value: summary.burnedKcal.round().toString(),
                  label: 'QUEMADAS',
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),
          Text('Objetivo: ${summary.calorieTarget} kcal', style: theme.textTheme.bodySmall),
          const SizedBox(height: AppSpacing.lg),
          MacroProgressBars(summary: summary),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleLarge),
        const SizedBox(height: AppSpacing.xs),
        Text(
          label,
          textAlign: TextAlign.center,
          style: theme.textTheme.labelMedium,
        ),
      ],
    );
  }
}
