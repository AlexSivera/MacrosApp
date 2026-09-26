import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_theme.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../../diario/providers/diary_providers.dart';
import '../providers/meal_plan_providers.dart';

// A day's total kcal in the Plan's calendar views (planned and eaten alike),
// in the over-target red once it passes the daily goal — so a week can be
// balanced at a glance without opening each day. Compact is the month
// grid's bare number; otherwise "1850 / 2240 kcal".
class PlanDayKcal extends ConsumerWidget {
  const PlanDayKcal({super.key, required this.entries, this.compact = false, this.dimmed = false});

  final List<MealPlanEntryDisplay> entries;
  final bool compact;
  final bool dimmed;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final total = entries.isEmpty ? null : sumEntryMacros(ref.watch, entries);
    if (total == null) return const SizedBox.shrink();
    final theme = Theme.of(context);
    final kcal = total.kcal.round();
    final target = ref.watch(resolvedTargetsProvider).calorieTarget;
    final over = target > 0 && kcal > target;
    var color = over ? AppTheme.statusOverTarget : theme.colorScheme.onSurfaceVariant;
    if (dimmed) color = color.withValues(alpha: 0.4);

    if (compact) {
      return Text(
        '$kcal',
        maxLines: 1,
        style: theme.textTheme.labelSmall?.copyWith(fontSize: 10, height: 1.1, color: color),
      );
    }
    return Text(
      target > 0 ? '$kcal / $target kcal' : '$kcal kcal',
      style: theme.textTheme.labelLarge?.copyWith(color: color),
    );
  }
}
