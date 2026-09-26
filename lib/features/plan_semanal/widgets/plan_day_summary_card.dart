import 'package:flutter/material.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';
import '../../diario/widgets/macro_progress_bars.dart';

// A Plan day's header: how much of the daily goal is planned, as a bar.
// Deliberately not the Diario's calorie ring — the two screens share their
// meal cards, and the ring made a Plan day read as the Diario itself. No
// "Quemadas" either: planning is about what you'll eat.
class PlanDaySummaryCard extends StatelessWidget {
  const PlanDaySummaryCard({super.key, required this.summary});

  final DiarySummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final planned = summary.consumed.kcal.round();
    final target = summary.calorieTarget;
    final left = target - planned;
    final over = target > 0 && left < 0;
    final fraction = target > 0 ? (planned / target).clamp(0.0, 1.0) : 0.0;

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Text('PLANIFICADO', style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.6)),
              const Spacer(),
              Text('$planned', style: theme.textTheme.headlineMedium),
              Text(' / $target kcal', style: theme.textTheme.bodyMedium),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.pill),
            child: TweenAnimationBuilder<double>(
              tween: Tween(end: fraction),
              duration: AppMotion.of(context, AppMotion.counter),
              curve: AppMotion.curve,
              builder: (context, value, _) => LinearProgressIndicator(
                value: value,
                minHeight: 8,
                color: over ? AppTheme.statusOverTarget : theme.colorScheme.primary,
                backgroundColor: theme.colorScheme.surfaceContainerHighest,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xs),
          Text(
            over ? '${-left} kcal por encima del objetivo' : 'Quedan $left kcal por planificar',
            style: theme.textTheme.bodySmall?.copyWith(color: over ? AppTheme.statusOverTarget : null),
          ),
          const SizedBox(height: AppSpacing.lg),
          MacroProgressBars(summary: summary),
        ],
      ),
    );
  }
}
