import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_week_agenda.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_date_picker.dart';

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
          onPressed: () =>
              ref.read(selectedPlanMonthProvider.notifier).state = DateTime(month.year, month.month - 1, 1),
        ),
        IconButton(
          tooltip: 'Ir a una fecha',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () async {
            final picked = await showAppDatePicker(
              context: context,
              initialDate: month,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) {
              ref.read(selectedPlanMonthProvider.notifier).state = DateTime(picked.year, picked.month, 1);
            }
          },
        ),
        IconButton(
          tooltip: 'Mes siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () =>
              ref.read(selectedPlanMonthProvider.notifier).state = DateTime(month.year, month.month + 1, 1),
        ),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// A Google-Calendar-style month grid: 7 columns (L a D), full weeks only, so
// days from the adjacent month fill out the first/last row rather than
// leaving it ragged. Cells stay small and even — the day number plus a dot
// per planned meal — and the food itself is read in the week agenda under
// the grid: tapping a day selects it (and so its week), tapping it again
// opens that day. Full names used to be squeezed into the cells, which
// broke words mid-way and made every row a different height.
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
    // The picked day if it's on this page of the calendar; otherwise today
    // (when this is the current month) or the 1st.
    final picked = ref.watch(selectedPlanDayProvider);
    final selected = days.contains(picked)
        ? picked
        : (today.year == month.year && today.month == month.month ? today : month);
    final weekStart = mondayOf(selected);
    final weekDays = [for (var i = 0; i < 7; i++) addDays(weekStart, i)];

    void onCellTap(DateTime day) {
      if (day == selected) {
        onDayTap(day);
      } else {
        ref.read(selectedPlanDayProvider.notifier).state = day;
      }
    }

    return ListView(
      children: [
        Row(
          children: [
            for (final label in _weekdayLabels)
              Expanded(
                child: Center(child: Text(label, style: theme.textTheme.labelSmall)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        for (var rowStart = 0; rowStart < days.length; rowStart += 7)
          Row(
            children: [
              for (final day in days.skip(rowStart).take(7))
                Expanded(
                  child: _DayCell(
                    key: ValueKey(day),
                    day: day,
                    isCurrentMonth: day.month == month.month,
                    isToday: day == today,
                    isSelected: day == selected,
                    entries: entriesByDay[day] ?? const [],
                    onTap: () => onCellTap(day),
                  ),
                ),
            ],
          ),
        const SizedBox(height: AppSpacing.lg),
        Padding(
          padding: const EdgeInsets.only(left: AppSpacing.xs, bottom: AppSpacing.sm),
          child: Text(
            'SEMANA DEL ${weekDays.first.day} AL ${weekDays.last.day} '
                    '${DateFormat('MMM', 'es').format(weekDays.last)}'
                .toUpperCase(),
            style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
          ),
        ),
        PlanWeekAgenda(
          days: weekDays,
          entriesByDay: entriesByDay,
          onDayTap: onDayTap,
          highlightedDay: selected,
        ),
        const SizedBox(height: AppSpacing.lg),
      ],
    );
  }
}

class _DayCell extends StatelessWidget {
  const _DayCell({
    super.key,
    required this.day,
    required this.isCurrentMonth,
    required this.isToday,
    required this.isSelected,
    required this.entries,
    required this.onTap,
  });

  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool isSelected;
  final List<MealPlanEntryDisplay> entries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final dimmed = !isCurrentMonth;
    final foreground = dimmed ? scheme.onSurfaceVariant.withValues(alpha: 0.4) : scheme.onSurface;
    final byMeal = groupPlanEntriesByMeal(entries);
    final plannedMeals = mealSectionOrder.where((meal) => byMeal[meal]!.isNotEmpty).length;

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: SizedBox(
            height: 48,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 30,
                  height: 30,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: isToday ? scheme.primary : null,
                    shape: BoxShape.circle,
                    border: isSelected && !isToday ? Border.all(color: scheme.primary, width: 1.5) : null,
                  ),
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isToday ? scheme.onPrimary : foreground,
                      fontWeight: isToday || isSelected ? FontWeight.bold : null,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                // One dot per meal with something planned.
                SizedBox(
                  height: 5,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      for (var i = 0; i < plannedMeals; i++)
                        Container(
                          width: 4,
                          height: 4,
                          margin: const EdgeInsets.symmetric(horizontal: 1),
                          decoration: BoxDecoration(
                            color: dimmed ? scheme.primary.withValues(alpha: 0.35) : scheme.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
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
