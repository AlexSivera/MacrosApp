import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/macro_progress_bar.dart';
import '../../../services/nutrition_engine/diary_summary_calculator.dart';

class MacroProgressBars extends StatelessWidget {
  const MacroProgressBars({super.key, required this.summary});

  final DiarySummary summary;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: MacroProgressBar(
            label: 'Carbohidratos',
            consumedG: summary.consumed.carbsG,
            targetG: summary.macroTargets.carbsG,
            color: AppTheme.carbsColor,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: MacroProgressBar(
            label: 'Proteínas',
            consumedG: summary.consumed.proteinG,
            targetG: summary.macroTargets.proteinG,
            color: AppTheme.proteinColor,
          ),
        ),
        const SizedBox(width: AppSpacing.lg),
        Expanded(
          child: MacroProgressBar(
            label: 'Grasas',
            consumedG: summary.consumed.fatG,
            targetG: summary.macroTargets.fatG,
            color: AppTheme.fatColor,
          ),
        ),
      ],
    );
  }
}
