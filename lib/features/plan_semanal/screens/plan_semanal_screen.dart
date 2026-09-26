import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/meal_plan_providers.dart';
import '../widgets/plan_month_calendar.dart';
import '../widgets/plan_week_view.dart';

// The Plan semanal tab's landing screen: the week as a compact agenda by
// default (what's eaten each day, all seven at a glance), or a month grid
// for navigating further out, with the picked week's agenda under it.
// Tapping a day in the agenda pushes PlanDayScreen for that date.
class PlanSemanalScreen extends ConsumerWidget {
  const PlanSemanalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final viewMode = ref.watch(planViewModeProvider);
    void onDayTap(DateTime day) => context.push('/plan/dia/${planDayPathSegment(day)}');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan semanal'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Compra'),
            onPressed: () => context.push('/listas/compra'),
          ),
        ],
      ),
      // A Column with the grid/list Expanded, not a ListView wrapping
      // everything, so the month view still fills the whole screen instead
      // of shrink-wrapping to its content and leaving empty space below it.
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          children: [
            Center(
              child: SegmentedButton<PlanViewMode>(
                segments: const [
                  ButtonSegment(value: PlanViewMode.month, label: Text('Mes'), icon: Icon(Icons.calendar_month_outlined)),
                  ButtonSegment(value: PlanViewMode.week, label: Text('Semana'), icon: Icon(Icons.view_week_outlined)),
                ],
                selected: {viewMode},
                onSelectionChanged: (selection) =>
                    ref.read(planViewModeProvider.notifier).state = selection.first,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),
            if (viewMode == PlanViewMode.month) ...[
              const PlanMonthHeader(),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: PlanMonthGrid(onDayTap: onDayTap)),
            ] else ...[
              const PlanWeekHeader(),
              const SizedBox(height: AppSpacing.lg),
              Expanded(child: PlanWeekView(onDayTap: onDayTap)),
            ],
          ],
        ),
      ),
    );
  }
}
