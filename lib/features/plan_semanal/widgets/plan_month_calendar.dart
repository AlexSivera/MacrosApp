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
        // Expanded, not shrink-wrapped: the grid fills the rest of the
        // screen instead of sizing to its content and leaving empty space
        // below it. Each week is itself an Expanded Row so the available
        // height is shared out row by row — weeks with more planned meals
        // get proportionally more of it, rather than every week getting an
        // identical slice regardless of content.
        Expanded(
          child: Column(
            children: [
              for (var weekStart = 0; weekStart < days.length; weekStart += 7)
                Expanded(
                  flex: _weekFlex(days.skip(weekStart).take(7), entriesByDay),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
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
                ),
            ],
          ),
        ),
      ],
    );
  }

  // Baseline of 3 (just the day number) plus 3 per meal planned in that
  // week's busiest day — a meal preview is a label line plus its food name
  // wrapped over up to 2 lines (see _DayCell), not a single truncated
  // line, so it needs 3x the room a one-liner would.
  static int _weekFlex(
    Iterable<DateTime> weekDays,
    Map<DateTime, List<MealPlanEntryDisplay>> entriesByDay,
  ) {
    var maxMealLines = 0;
    for (final day in weekDays) {
      final mealsPlanned =
          groupPlanEntriesByMeal(entriesByDay[day] ?? const []).values.where((v) => v.isNotEmpty).length;
      if (mealsPlanned > maxMealLines) maxMealLines = mealsPlanned;
    }
    return 3 + maxMealLines * 3;
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
            padding: const EdgeInsets.symmetric(horizontal: 2, vertical: 4),
            // mainAxisSize.max: the cell fills the full height the parent
            // Row's flex handed it (see PlanMonthGrid._weekFlex), instead
            // of shrinking to its own content and leaving the rest of that
            // row's height empty.
            child: Column(
              mainAxisSize: MainAxisSize.max,
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
                  // A non-scrolling ListView rather than a plain Column of
                  // preview lines: if a day ever has more meals than its
                  // week's tallest day did when computing _weekFlex, this
                  // clips the overflow instead of overflowing the row.
                  Expanded(
                    child: ListView(
                      padding: EdgeInsets.zero,
                      physics: const NeverScrollableScrollPhysics(),
                      children: [for (final preview in previews) _MealPreviewLine(preview: preview, dimmed: dimmed)],
                    ),
                  ),
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
    final labelColor = dimmed
        ? theme.colorScheme.primary.withValues(alpha: 0.4)
        : theme.colorScheme.primary;
    final nameColor = dimmed
        ? theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.4)
        : theme.colorScheme.onSurfaceVariant;

    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            preview.label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              height: 1.1,
              color: labelColor,
            ),
          ),
          Text(
            preview.names,
            // Wraps onto a 2nd line instead of truncating with "…" — a
            // name that still doesn't fit in 2 lines is the rare
            // exception where an ellipsis is the least-bad fallback.
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelSmall?.copyWith(
              fontSize: 10,
              height: 1.1,
              color: nameColor,
            ),
          ),
        ],
      ),
    );
  }
}
