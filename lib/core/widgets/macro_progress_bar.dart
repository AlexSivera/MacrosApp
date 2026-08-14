import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';

// One macro's row: label, "consumed / target g", a progress bar tinted with
// the macro's own color, and a percentage — reused by the Diario summary,
// Detalles modal, and recipe cards so a macro is identifiable by color alone
// everywhere in the app.
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
    final percent = (fraction * 100).round();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelLarge,
              ),
            ),
            Text('$percent%', style: theme.textTheme.bodySmall),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
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
        const SizedBox(height: AppSpacing.xs),
        Text(
          '${consumedG.round()} / ${targetG.round()} g',
          style: theme.textTheme.bodySmall,
        ),
      ],
    );
  }
}
