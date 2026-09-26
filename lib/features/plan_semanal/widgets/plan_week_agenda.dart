import 'package:flutter/material.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/daos/meal_plan_dao.dart';
import '../providers/meal_plan_providers.dart';
import 'plan_day_kcal.dart';

// A whole week in one card, one compact row per day, so what's eaten that
// week reads at a glance: the day and its kcal on the left, one line per
// meal on the right (the meal's icon, then every food/recipe in it). Names
// are never truncated — they wrap — and repeats collapse to "×2". Shared by
// the Semana view and the week under the Mes grid; tapping a row opens
// that day.
class PlanWeekAgenda extends StatelessWidget {
  const PlanWeekAgenda({
    super.key,
    required this.days,
    required this.entriesByDay,
    required this.onDayTap,
    this.highlightedDay,
  });

  final List<DateTime> days;
  final Map<DateTime, List<MealPlanEntryDisplay>> entriesByDay;
  final ValueChanged<DateTime> onDayTap;

  // The day picked in the Mes grid, outlined here too.
  final DateTime? highlightedDay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final today = normalizeDate(DateTime.now());
    return AppCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          for (var i = 0; i < days.length; i++) ...[
            _DayRow(
              day: days[i],
              entries: entriesByDay[days[i]] ?? const [],
              isToday: days[i] == today,
              isPast: days[i].isBefore(today),
              isHighlighted: days[i] == highlightedDay,
              onTap: () => onDayTap(days[i]),
            ),
            if (i != days.length - 1)
              Divider(height: 1, indent: 64, color: theme.colorScheme.outline.withValues(alpha: 0.6)),
          ],
        ],
      ),
    );
  }
}

class _DayRow extends StatelessWidget {
  const _DayRow({
    required this.day,
    required this.entries,
    required this.isToday,
    required this.isPast,
    required this.isHighlighted,
    required this.onTap,
  });

  final DateTime day;
  final List<MealPlanEntryDisplay> entries;
  final bool isToday;
  final bool isPast;
  final bool isHighlighted;
  final VoidCallback onTap;

  static const _weekdays = ['LUN', 'MAR', 'MIÉ', 'JUE', 'VIE', 'SÁB', 'DOM'];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final scheme = theme.colorScheme;
    final byMeal = groupPlanEntriesByMeal(entries);
    final meals = [for (final meal in mealSectionOrder) if (byMeal[meal]!.isNotEmpty) meal];

    return Material(
      color: isHighlighted ? AppTheme.tint(context) : Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Opacity(
          // Days already gone stay readable but step back.
          opacity: isPast ? 0.6 : 1,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.sm, AppSpacing.sm, AppSpacing.md, AppSpacing.sm),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 44,
                  child: Column(
                    children: [
                      Text(
                        _weekdays[day.weekday - 1],
                        style: theme.textTheme.labelSmall?.copyWith(
                          letterSpacing: 0.4,
                          color: isToday ? scheme.primary : null,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 30,
                        height: 30,
                        alignment: Alignment.center,
                        decoration: isToday ? BoxDecoration(color: scheme.primary, shape: BoxShape.circle) : null,
                        child: Text(
                          '${day.day}',
                          style: theme.textTheme.titleMedium?.copyWith(
                            color: isToday ? scheme.onPrimary : null,
                            height: 1,
                          ),
                        ),
                      ),
                      const SizedBox(height: 2),
                      PlanDayKcal(entries: entries),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: meals.isEmpty
                        ? Padding(
                            padding: const EdgeInsets.only(top: AppSpacing.sm),
                            child: Text(
                              'Sin planificar',
                              style: theme.textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
                            ),
                          )
                        : Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              for (final meal in meals)
                                Padding(
                                  padding: const EdgeInsets.symmetric(vertical: 2),
                                  child: Row(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Tooltip(
                                          message: meal.label,
                                          child: Icon(meal.icon, size: 15, color: scheme.primary),
                                        ),
                                      ),
                                      const SizedBox(width: AppSpacing.sm),
                                      Expanded(
                                        child: Text(
                                          mealNamesSummary(byMeal[meal]!),
                                          style: theme.textTheme.bodyMedium?.copyWith(height: 1.3),
                                        ),
                                      ),
                                    ],
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

// "Yogur natural · Plátano", with repeats collapsed: "Pechuga de pavo ×2".
String mealNamesSummary(List<MealPlanEntryDisplay> entries) {
  final counts = <String, int>{};
  for (final e in entries) {
    counts.update(e.label, (n) => n + 1, ifAbsent: () => 1);
  }
  return [for (final MapEntry(:key, :value) in counts.entries) value > 1 ? '$key ×$value' : key].join(' · ');
}
