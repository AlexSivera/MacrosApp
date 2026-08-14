import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

// The Diario's centerpiece — a ring showing consumed/target calories, with
// the "Restantes" figure as the number inside it. fraction is always
// pre-clamped to [0,1] by the caller (see DiarySummary.ringFraction) so the
// ring itself never needs to reason about over-target state.
class CircularCalorieRing extends StatelessWidget {
  const CircularCalorieRing({
    super.key,
    required this.fraction,
    required this.centerValue,
    required this.centerLabel,
    this.isOverTarget = false,
    this.size = 168,
    this.strokeWidth = 14,
  });

  final double fraction;
  final String centerValue;
  final String centerLabel;
  final bool isOverTarget;
  final double size;
  final double strokeWidth;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = isOverTarget ? AppTheme.statusOverTarget : AppTheme.accent;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          SizedBox(
            width: size,
            height: size,
            child: CircularProgressIndicator(
              value: 1,
              strokeWidth: strokeWidth,
              color: AppTheme.statusEmpty,
            ),
          ),
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: AppMotion.slow,
            curve: AppMotion.curve,
            builder: (context, value, _) => SizedBox(
              width: size,
              height: size,
              child: CircularProgressIndicator(
                value: value,
                strokeWidth: strokeWidth,
                color: ringColor,
                strokeCap: StrokeCap.round,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: isOverTarget ? AppTheme.statusOverTarget : null,
                  fontSize: 28,
                ),
              ),
              Text(centerLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}
