import 'package:flutter/material.dart';

import '../../services/nutrition_engine/food_macros_calculator.dart';
import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

// kcal + protein/carbs/fat in the app's fixed P · C · G order, each macro
// tagged with its identity color — shared by every quantity sheet and the
// recipe detail so a preview reads the same everywhere.
class MacroPreviewRow extends StatelessWidget {
  const MacroPreviewRow({super.key, required this.macros, this.filled = true, this.showKcal = true});

  final FoodMacros macros;

  // false when it already sits inside a card.
  final bool filled;

  // false when the kcal figure is already shown bigger right above.
  final bool showKcal;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final row = Row(
      children: [
        if (showKcal) Expanded(child: _Stat('${macros.kcal.round()}', 'kcal', theme.colorScheme.primary)),
        Expanded(child: _Stat('${macros.proteinG.round()} g', 'Proteína', AppTheme.proteinColor)),
        Expanded(child: _Stat('${macros.carbsG.round()} g', 'Carbos', AppTheme.carbsColor)),
        Expanded(child: _Stat('${macros.fatG.round()} g', 'Grasa', AppTheme.fatColor)),
      ],
    );
    if (!filled) return row;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: AppSpacing.md, horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: row,
    );
  }
}

class _Stat extends StatelessWidget {
  const _Stat(this.value, this.label, this.color);

  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Text(value, style: theme.textTheme.titleMedium),
        const SizedBox(height: 2),
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(color: color, shape: BoxShape.circle),
            ),
            const SizedBox(width: 4),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.bodySmall,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
