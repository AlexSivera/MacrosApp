import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../providers/meal_plan_providers.dart';

// Month header: name + year, with prev/next-month arrows and a jump-to-date
// shortcut — navigating by month here, unlike the Diario's day-by-day bar.
class PlanMonthHeader extends ConsumerWidget {
  const PlanMonthHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = ref.watch(selectedPlanMonthProvider);

    return Row(
      children: [
        Expanded(
          child: Text(
            _capitalize(DateFormat('MMMM yyyy', 'es').format(month)),
            style: theme.textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: 'Mes anterior',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => ref.read(selectedPlanMonthProvider.notifier).state =
              DateTime(month.year, month.month - 1, 1),
        ),
        IconButton(
          tooltip: 'Ir a una fecha',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: month,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) {
              ref.read(selectedPlanMonthProvider.notifier).state =
                  DateTime(picked.year, picked.month, 1);
            }
          },
        ),
        IconButton(
          tooltip: 'Mes siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => ref.read(selectedPlanMonthProvider.notifier).state =
              DateTime(month.year, month.month + 1, 1),
        ),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// A Google-Calendar-style month grid: 7 columns (L a D), full weeks only, so
// days from the adjacent month fill out the first/last row rather than
// leaving it ragged. Tapping a day is the sole way in: there's no separate
// "selected day" state here, each tap just navigates straight to that day's
// PlanDayScreen.
class PlanMonthGrid extends ConsumerWidget {
  const PlanMonthGrid({super.key, required this.onDayTap});

  final ValueChanged<DateTime> onDayTap;

  static const _weekdayLabels = ['L', 'M', 'X', 'J', 'V', 'S', 'D'];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final month = ref.watch(selectedPlanMonthProvider);
    final days = ref.watch(monthGridDaysProvider);
    final entries = ref.watch(mealPlanEntriesForMonthGridProvider).valueOrNull ?? [];
    final entriesByDay = groupPlanEntriesByDay(entries);
    final today = normalizeDate(DateTime.now());

    return Column(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(
                  child: Text(label, style: theme.textTheme.labelSmall),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // A Column of weekly Rows, rather than a GridView, so each week's
        // row height auto-sizes to its own tallest day cell — the reference
        // design has visibly taller rows for weeks with more planned meals,
        // which a GridView's SliverGridDelegateWithFixedCrossAxisCount can't
        // do (it forces one uniform cell size across the whole grid).
        for (var weekStart = 0; weekStart < days.length; weekStart += 7)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              for (final day in days.skip(weekStart).take(7))
                Expanded(
                  child: _DayCell(
                    day: day,
                    isCurrentMonth: day.month == month.month,
                    isToday: day == today,
                    entries: entriesByDay[day] ?? const [],
                    onTap: () => onDayTap(day),
                  ),
                ),
            ],
          ),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.entries,
    required this.onTap,
  });

  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final List<MealPlanEntryDisplay> entries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimmed = !isCurrentMonth;
    final foreground = dimmed
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
        : theme.colorScheme.onSurface;

    final entriesByMeal = groupPlanEntriesByMeal(entries);
    // One row per meal that has something planned that day: its icon (a
    // word like "Desayuno" would eat the whole column width on its own,
    // leaving nothing for the food name) plus its food/recipe names.
    final previews = [
      for (final meal in mealSectionOrder)
        if (entriesByMeal[meal]!.isNotEmpty)
          (icon: meal.icon, names: entriesByMeal[meal]!.map((e) => e.label).join(', ')),
    ];

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 3),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 20,
                  height: 20,
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)
                      : null,
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: isToday ? theme.colorScheme.onPrimary : foreground,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
                if (previews.isNotEmpty) const SizedBox(height: 2),
                for (final preview in previews)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 1),
                    // Fills the cell's full width regardless of the parent
                    // Column being center-aligned (for the day-number
                    // circle) — a loose constraint here would otherwise
                    // shrink-wrap the Row to its content instead.
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          Icon(
                            preview.icon,
                            size: 8,
                            color: dimmed
                                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                : theme.colorScheme.primary,
                          ),
                          const SizedBox(width: 1),
                          Expanded(
                            child: Text(
                              preview.names,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.labelSmall?.copyWith(
                                fontSize: 7.5,
                                height: 1.2,
                                color: dimmed
                                    ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
                                    : theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
