import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/enums.dart';

class WeightStatsRow extends StatelessWidget {
  const WeightStatsRow({
    super.key,
    required this.currentKg,
    required this.startingKg,
    required this.goalKg,
    required this.goalType,
  });

  final double? currentKg;
  final double? startingKg;
  final double? goalKg;
  final GoalType goalType;

  // Green when the change goes the way the goal wants (down to lose, up to
  // gain, within ±1 kg to maintain), red when it goes the other way.
  Color? _changeColor(double change) {
    if (change.abs() < 0.05) return null;
    final onTrack = switch (goalType) {
      GoalType.lose => change < 0,
      GoalType.gain => change > 0,
      GoalType.maintain => change.abs() <= 1,
    };
    return onTrack ? AppTheme.statusOnTrack : AppTheme.statusOverTarget;
  }

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
              change == null ? '—' : '${change > 0 ? '+' : ''}${formatKg(change)}',
              color: change == null ? null : _changeColor(change),
            ),
          ),
        ],
      ),
    );
  }

  static String _fmt(double? v) => v == null ? '—' : formatKg(v);
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
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(value, maxLines: 1, style: theme.textTheme.titleMedium?.copyWith(color: color)),
        ),
        const SizedBox(height: AppSpacing.xs),
        Text(label, style: theme.textTheme.labelMedium),
      ],
    );
  }
}
