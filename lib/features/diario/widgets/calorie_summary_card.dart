import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/animated_number.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/circular_calorie_ring.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import 'macro_progress_bars.dart';

class CalorieSummaryCard extends StatelessWidget {
  const CalorieSummaryCard({super.key, required this.summary, this.consumedLabel = 'Consumidas'});

  final DiarySummary summary;

  // "Planificadas" on a Plan day, where nothing has been eaten yet.
  final String consumedLabel;

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
                child: _StatColumn(value: summary.consumedKcal.round(), label: consumedLabel),
              ),
              CircularCalorieRing(
                fraction: summary.ringFraction,
                isOverTarget: summary.isOverTarget,
                centerValue: summary.remainingKcal.round().abs(),
                centerLabel: summary.isOverTarget ? 'Excedidas' : 'Restantes',
              ),
              Expanded(
                child: _StatColumn(value: summary.burnedKcal.round(), label: 'Quemadas'),
              ),
            ],
          ),
          if (summary.plannedKcal > 0) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              '+${summary.plannedKcal.round()} kcal planeadas sin marcar',
              style: theme.textTheme.bodySmall,
            ),
          ],
          const SizedBox(height: AppSpacing.lg),
          MacroProgressBars(summary: summary),
        ],
      ),
    );
  }
}

class _StatColumn extends StatelessWidget {
  const _StatColumn({required this.value, required this.label});

  final int value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    // scaleDown instead of wrapping: at 360-390 px wide "Consumidas" used
    // to break mid-word next to the ring.
    return Column(
      children: [
        FittedBox(
          fit: BoxFit.scaleDown,
          child: AnimatedNumber(value: value, style: theme.textTheme.titleLarge),
        ),
        const SizedBox(height: AppSpacing.xs),
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(label, maxLines: 1, style: theme.textTheme.labelMedium),
        ),
      ],
    );
  }
}
