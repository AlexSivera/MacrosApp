import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';

class WeightStatsRow extends StatelessWidget {
  const WeightStatsRow({
    super.key,
    required this.currentKg,
    required this.startingKg,
    required this.goalKg,
  });

  final double? currentKg;
  final double? startingKg;
  final double? goalKg;

  @override
  Widget build(BuildContext context) {
    final change = (currentKg != null && startingKg != null) ? currentKg! - startingKg! : null;

    return AppCard(
      child: Row(
        children: [
          Expanded(child: _Stat('Actual', _fmt(currentKg))),
          Expanded(child: _Stat('Inicial', _fmt(startingKg))),
          Expanded(child: _Stat('Objetivo', _fmt(goalKg))),
          Expanded(
            child: _Stat(
              'Cambio',
              change == null ? '—' : '${change >= 0 ? '+' : ''}${change.toStringAsFixed(1)} kg',
              color: change == null
                  ? null
                  : (change <= 0 ? AppTheme.statusOnTrack : AppTheme.statusOverTarget),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double? v) => v == null ? '—' : '${v.toStringAsFixed(1)} kg';
}

class _Stat extends StatelessWidget {
  const _Stat(this.label, this.value, {this.color});

  final String label;
  final String value;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
