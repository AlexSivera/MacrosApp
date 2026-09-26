import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../diario/providers/diary_providers.dart';
import '../providers/meal_plan_providers.dart';

// A day's total kcal in the Plan's week agenda (planned and eaten alike),
// in the over-target red once it passes the daily goal — so a week can be
// balanced at a glance without opening each day.
class PlanDayKcal extends ConsumerWidget {
  const PlanDayKcal({super.key, required this.entries});

  final List<MealPlanEntryDisplay> entries;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = entries.isEmpty ? null : sumEntryMacros(ref.watch, entries);
    if (total == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final kcal = total.kcal.round();
    final target = ref.watch(resolvedTargetsProvider).calorieTarget;
    final over = target > 0 && kcal > target;
    return Text(
      '$kcal',
      maxLines: 1,
      style: theme.textTheme.labelSmall?.copyWith(
        height: 1.1,
        color: over ? AppTheme.statusOverTarget : theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}
