import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

// One macro's column: label, a progress bar tinted with the macro's own
// color, and "consumed / target g" — reused by the Diario summary so a
// macro is identifiable by color alone everywhere in the app. Centered and
// stacked (rather than label+percent sharing a row) so the label always has
// the column's full width and never has to ellipsize.
class MacroProgressBar extends StatelessWidget {
  const MacroProgressBar({
    super.key,
    required this.label,
    required this.consumedG,
    required this.targetG,
    required this.color,
  });

  final String label;
  final double consumedG;
  final double targetG;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fraction = targetG <= 0 ? 0.0 : (consumedG / targetG).clamp(0, 1).toDouble();

    return Column(
      children: [
        Text(
          label,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.labelLarge,
        ),
        const SizedBox(height: AppSpacing.sm),
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: AppMotion.slow,
            curve: AppMotion.curve,
            builder: (context, value, _) => LinearProgressIndicator(
              value: value,
              minHeight: 8,
              backgroundColor: color.withValues(alpha: 0.16),
              color: color,
            ),
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Text(
          '${consumedG.round()} / ${targetG.round()} g',
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
