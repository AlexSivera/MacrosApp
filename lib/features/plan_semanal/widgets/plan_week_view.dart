import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_week_agenda.dart';
import '../../../core/utils/dates.dart';

// Week header: date range + prev/next-week arrows, mirroring
// PlanMonthHeader's shape but for a 7-day window instead of a month.
class PlanWeekHeader extends ConsumerWidget {
  const PlanWeekHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final monday = ref.watch(selectedPlanWeekStartProvider);
    final sunday = addDays(monday, 6);
    final sameMonth = monday.month == sunday.month;
    // Spanish month names stay lowercase mid-sentence ("21 - 27 de septiembre").
    final range = sameMonth
        ? '${monday.day} - ${sunday.day} de ${DateFormat('MMMM', 'es').format(sunday)}'
        : '${monday.day} ${DateFormat('MMM', 'es').format(monday)} - '
              '${sunday.day} ${DateFormat('MMM', 'es').format(sunday)}';

    return Row(
      children: [
        Expanded(child: Text(range, style: theme.textTheme.titleLarge)),
        IconButton(
          tooltip: 'Semana anterior',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => ref.read(selectedPlanWeekStartProvider.notifier).state = addDays(monday, -7),
        ),
        IconButton(
          tooltip: 'Semana siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => ref.read(selectedPlanWeekStartProvider.notifier).state = addDays(monday, 7),
        ),
      ],
    );
  }
}

// The week as one compact agenda (see PlanWeekAgenda) — sized so the whole
// week reads at a glance rather than a screenful per day.
class PlanWeekView extends ConsumerWidget {
  const PlanWeekView({super.key, required this.onDayTap});

  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(planWeekDaysProvider);
    final entries = ref.watch(mealPlanEntriesForWeekViewProvider).valueOrNull ?? [];

    return ListView(
      children: [
        PlanWeekAgenda(days: days, entriesByDay: groupPlanEntriesByDay(entries), onDayTap: onDayTap),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}
