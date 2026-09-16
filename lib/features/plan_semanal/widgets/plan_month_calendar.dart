import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
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
    final plannedDates = datesWithPlanEntries(entries);
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
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: days.length,
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 7,
            childAspectRatio: 0.85,
          ),
          itemBuilder: (context, index) {
            final day = days[index];
            return _DayCell(
              day: day,
              isCurrentMonth: day.month == month.month,
              isToday: day == today,
              hasEntries: plannedDates.contains(day),
              onTap: () => onDayTap(day),
            );
          },
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
    required this.hasEntries,
    required this.onTap,
  });

  final DateTime day;
  final bool isCurrentMonth;
  final bool isToday;
  final bool hasEntries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dimmed = !isCurrentMonth;
    final foreground = dimmed
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
        : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.all(2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: isToday ? Border.all(color: theme.colorScheme.primary, width: 1.5) : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text('${day.day}', style: theme.textTheme.bodyLarge?.copyWith(color: foreground)),
                const SizedBox(height: 3),
                SizedBox(
                  height: 6,
                  width: 6,
                  child: hasEntries
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: dimmed
                                ? theme.colorScheme.primary.withValues(alpha: 0.4)
                                : theme.colorScheme.primary,
                          ),
                        )
                      : null,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
