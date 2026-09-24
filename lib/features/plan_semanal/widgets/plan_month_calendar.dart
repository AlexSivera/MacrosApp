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
          onPressed: () =>
              ref.read(selectedPlanMonthProvider.notifier).state = DateTime(month.year, month.month - 1, 1),
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
                child: Center(child: Text(label, style: theme.textTheme.labelSmall)),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        // Expanded + scrollable: each week's Row sizes to its own tallest
        // day cell (full food names can wrap over several lines — see
        // _DayCell — so a week's height isn't predictable up front), and
        // the whole grid scrolls on months where that adds up to more than
        // the screen's height instead of forcing a size that would either
        // clip a long name or leave empty space on lighter months.
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
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
            ),
          ),
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
    // A block per meal that has something planned that day: its label
    // ("Comida") on its own line, then the food/recipe name(s) wrapped
    // onto their own line(s) below — never truncated with "…", so a name
    // that doesn't fit ("macarrones con tomate") just breaks onto a
    // second line ("macarrones" / "con tomate") instead.
    final previews = [
      for (final meal in mealSectionOrder)
        if (entriesByMeal[meal]!.isNotEmpty)
          (label: meal.label, names: entriesByMeal[meal]!.map((e) => e.label).join(', ')),
    ];

    return Padding(
      padding: const EdgeInsets.all(1),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 1, vertical: 4),
            // mainAxisSize.min: the cell (and the week Row it sits in)
            // sizes to fit however many lines the food names actually
            // need, instead of being handed a fixed height that would
            // force truncating them.
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: isToday
                      ? BoxDecoration(color: theme.colorScheme.primary, shape: BoxShape.circle)
                      : null,
                  child: Text(
                    '${day.day}',
                    style: theme.textTheme.titleSmall?.copyWith(
                      color: isToday ? theme.colorScheme.onPrimary : foreground,
                      fontWeight: isToday ? FontWeight.bold : null,
                    ),
                  ),
                ),
                if (previews.isNotEmpty) ...[
                  const SizedBox(height: 3),
                  for (final preview in previews) _MealPreviewLine(preview: preview, dimmed: dimmed),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _MealPreviewLine extends StatelessWidget {
  const _MealPreviewLine({required this.preview, required this.dimmed});

  final ({String label, String names}) preview;
  final bool dimmed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labelColor = dimmed ? theme.colorScheme.primary.withValues(alpha: 0.4) : theme.colorScheme.primary;
    final nameColor = dimmed
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Scaled down rather than cut to "Desayu…" in a narrow cell.
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              preview.label,
              maxLines: 1,
              style: theme.textTheme.labelSmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.w700,
                height: 1.1,
                color: labelColor,
              ),
            ),
          ),
          Text(
            // No maxLines/ellipsis: the full name always shows, wrapping
            // over as many lines as it needs rather than ever truncating.
            // 9 px keeps a typical long word ("Jamoncitos") on one line in a
            // ~45 px cell instead of breaking it mid-word.
            preview.names,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 9,
              letterSpacing: -0.1,
              fontWeight: FontWeight.w500,
              height: 1.1,
              color: nameColor,
            ),
          ),
        ],
      ),
    );
  }
}
