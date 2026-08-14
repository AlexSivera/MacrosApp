import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';

// Full breakdown behind the Diario's "Detalles" button — makes the
// consumidas-vs-quemadas distinction explicit instead of leaving it implicit
// in the summary ring, per the brief's insistence on never mixing the two.
class DetallesSheet extends StatelessWidget {
  const DetallesSheet({super.key, required this.summary});

  final DiarySummary summary;

  static Future<void> show(BuildContext context, DiarySummary summary) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => DetallesSheet(summary: summary),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Detalles', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.lg),
            _Row('Objetivo calórico', '${summary.calorieTarget} kcal'),
            _Row('Calorías consumidas', '${summary.consumedKcal.round()} kcal'),
            _Row('Calorías quemadas', '${summary.burnedKcal.round()} kcal'),
            _Row('Calorías netas', '${summary.netKcal.round()} kcal',
                hint: 'Consumidas − quemadas'),
            _Row(
              'Calorías restantes',
              '${summary.remainingKcal.round()} kcal',
              hint: 'Objetivo − consumidas + quemadas',
              isWarning: summary.isOverTarget,
            ),
            const Divider(height: AppSpacing.xxl),
            _Row('Proteínas consumidas', '${summary.consumed.proteinG.round()} g'),
            _Row('Proteínas restantes', '${summary.proteinRemainingG.round()} g'),
            const SizedBox(height: AppSpacing.md),
            _Row('Carbohidratos consumidos', '${summary.consumed.carbsG.round()} g'),
            _Row('Carbohidratos restantes', '${summary.carbsRemainingG.round()} g'),
            const SizedBox(height: AppSpacing.md),
            _Row('Grasas consumidas', '${summary.consumed.fatG.round()} g'),
            _Row('Grasas restantes', '${summary.fatRemainingG.round()} g'),
          ],
        ),
      ),
    );
  }
}

class _Row extends StatelessWidget {
  const _Row(this.label, this.value, {this.hint, this.isWarning = false});

  final String label;
  final String value;
  final String? hint;
  final bool isWarning;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: theme.textTheme.bodyMedium),
                if (hint != null)
                  Text(hint!, style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Text(
            value,
            style: theme.textTheme.titleMedium?.copyWith(
              color: isWarning ? Theme.of(context).colorScheme.error : null,
            ),
          ),
        ],
      ),
    );
  }
}
