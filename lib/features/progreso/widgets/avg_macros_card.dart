import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../providers/progress_providers.dart';

class AvgMacrosCard extends StatelessWidget {
  const AvgMacrosCard({super.key, required this.average, required this.rangeLabel});

  final AverageMacros average;
  final String rangeLabel;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final days = average.dayCount;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Promedio diario · $rangeLabel', style: theme.textTheme.labelMedium),
          const SizedBox(height: 2),
          Text(
            days == 0
                ? 'Aún no hay comidas registradas en este periodo'
                : 'Sobre ${days == 1 ? '1 día registrado' : '$days días registrados'}',
            style: theme.textTheme.bodySmall,
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(child: _AvgStat('${average.perDay.kcal.round()}', 'kcal', theme.colorScheme.primary)),
              Expanded(
                child: _AvgStat('${average.perDay.proteinG.round()} g', 'Proteína', AppTheme.proteinColor),
              ),
              Expanded(child: _AvgStat('${average.perDay.carbsG.round()} g', 'Carbos', AppTheme.carbsColor)),
              Expanded(child: _AvgStat('${average.perDay.fatG.round()} g', 'Grasa', AppTheme.fatColor)),
            ],
          ),
        ],
      ),
    );
  }
}

class _AvgStat extends StatelessWidget {
  const _AvgStat(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}
