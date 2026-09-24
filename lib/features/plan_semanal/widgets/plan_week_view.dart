import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../providers/meal_plan_providers.dart';
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

// A full-width list of the week's 7 days — the month grid's cells are too
// narrow to read comfortably, so this trades the "whole month at a glance"
// view for "this week, in enough detail to actually plan it".
class PlanWeekView extends ConsumerWidget {
  const PlanWeekView({super.key, required this.onDayTap});

  final ValueChanged<DateTime> onDayTap;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(planWeekDaysProvider);
    final entries = ref.watch(mealPlanEntriesForWeekViewProvider).valueOrNull ?? [];
    final entriesByDay = groupPlanEntriesByDay(entries);
    final today = normalizeDate(DateTime.now());

    return ListView.separated(
      itemCount: days.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
      itemBuilder: (context, index) {
        final day = days[index];
        return _WeekDayCard(
          day: day,
          isToday: day == today,
          entries: entriesByDay[day] ?? const [],
          onTap: () => onDayTap(day),
        );
      },
    );
  }
}

class _WeekDayCard extends StatelessWidget {
  const _WeekDayCard({required this.day, required this.isToday, required this.entries, required this.onTap});

  final DateTime day;
  final bool isToday;
  final List<MealPlanEntryDisplay> entries;
  final VoidCallback onTap;

  static const _weekdayNames = ['Lunes', 'Martes', 'Miércoles', 'Jueves', 'Viernes', 'Sábado', 'Domingo'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final entriesByMeal = groupPlanEntriesByMeal(entries);
    final previews = [
      for (final meal in mealSectionOrder)
        if (entriesByMeal[meal]!.isNotEmpty)
          (label: meal.label, names: entriesByMeal[meal]!.map((e) => e.label).join(', ')),
    ];

    return AppCard(
      onTap: onTap,
      borderColor: isToday ? theme.colorScheme.primary : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                '${_weekdayNames[day.weekday - 1]} ${day.day}',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: isToday ? theme.colorScheme.primary : null,
                  fontWeight: isToday ? FontWeight.bold : null,
                ),
              ),
              if (isToday) ...[
                const SizedBox(width: AppSpacing.sm),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: 2),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  child: Text(
                    'Hoy',
                    style: theme.textTheme.labelSmall?.copyWith(color: theme.colorScheme.onPrimary),
                  ),
                ),
              ],
            ],
          ),
          if (previews.isEmpty) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Nada planificado',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
          ] else ...[
            const SizedBox(height: AppSpacing.sm),
            for (final preview in previews)
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.xs),
                child: RichText(
                  text: TextSpan(
                    style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurface),
                    children: [
                      TextSpan(
                        text: '${preview.label}: ',
                        style: const TextStyle(fontWeight: FontWeight.w700),
                      ),
                      TextSpan(text: preview.names),
                    ],
                  ),
                ),
              ),
          ],
        ],
      ),
    );
  }
}
