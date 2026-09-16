import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/meal_plan_providers.dart';

// Month header + week navigation. The month shown is always the selected
// day's month — when a week spans two months (e.g. 28 sept - 4 oct), the
// visible label follows whichever month the selected day itself falls in,
// same as flipping a physical wall calendar's page by day, not by week.
class PlanMonthHeader extends ConsumerWidget {
  const PlanMonthHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(selectedPlanDateProvider);

    return Row(
      children: [
        Expanded(
          child: Text(
            _capitalize(DateFormat('MMMM yyyy', 'es').format(selected)),
            style: theme.textTheme.titleLarge,
          ),
        ),
        IconButton(
          tooltip: 'Semana anterior',
          icon: const Icon(Icons.chevron_left_rounded),
          onPressed: () => ref.read(selectedPlanDateProvider.notifier).state =
              selected.subtract(const Duration(days: 7)),
        ),
        IconButton(
          tooltip: 'Ir a una fecha',
          icon: const Icon(Icons.calendar_month_outlined),
          onPressed: () async {
            final picked = await showDatePicker(
              context: context,
              initialDate: selected,
              firstDate: DateTime(2020),
              lastDate: DateTime.now().add(const Duration(days: 730)),
            );
            if (picked != null) {
              ref.read(selectedPlanDateProvider.notifier).state =
                  normalizeDate(picked);
            }
          },
        ),
        IconButton(
          tooltip: 'Semana siguiente',
          icon: const Icon(Icons.chevron_right_rounded),
          onPressed: () => ref.read(selectedPlanDateProvider.notifier).state =
              selected.add(const Duration(days: 7)),
        ),
      ],
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

// The week's 7 days as tappable chips — L a D, with a dot under any day that
// already has something planned, so the shape of the week is visible before
// drilling into a single day's sections below.
class PlanDayChips extends ConsumerWidget {
  const PlanDayChips({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final days = ref.watch(selectedWeekDaysProvider);
    final selected = ref.watch(selectedPlanDateProvider);
    final weekEntries = ref.watch(mealPlanEntriesForWeekProvider).valueOrNull ?? [];
    final plannedDates = datesWithPlanEntries(weekEntries);
    final today = normalizeDate(DateTime.now());

    return Row(
      children: [
        for (final day in days)
          Expanded(
            child: _DayChip(
              day: day,
              isSelected: day == selected,
              isToday: day == today,
              hasEntries: plannedDates.contains(day),
              onTap: () => ref.read(selectedPlanDateProvider.notifier).state = day,
            ),
          ),
      ],
    );
  }
}

class _DayChip extends StatelessWidget {
  const _DayChip({
    required this.day,
    required this.isSelected,
    required this.isToday,
    required this.hasEntries,
    required this.onTap,
  });

  final DateTime day;
  final bool isSelected;
  final bool isToday;
  final bool hasEntries;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final foreground = isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.onSurface;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 2),
      child: Material(
        color: isSelected ? theme.colorScheme.primary : theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.md),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.md),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(
                color: isToday && !isSelected ? theme.colorScheme.primary : theme.colorScheme.outline,
                width: isToday && !isSelected ? 1.5 : 1,
              ),
            ),
            child: Column(
              children: [
                Text(
                  DateFormat('EEE', 'es').format(day).replaceAll('.', ''),
                  style: theme.textTheme.labelSmall?.copyWith(color: foreground),
                ),
                const SizedBox(height: 2),
                Text(
                  '${day.day}',
                  style: theme.textTheme.titleMedium?.copyWith(color: foreground),
                ),
                const SizedBox(height: 2),
                SizedBox(
                  height: 6,
                  width: 6,
                  child: hasEntries
                      ? DecoratedBox(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: isSelected ? theme.colorScheme.onPrimary : theme.colorScheme.primary,
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
