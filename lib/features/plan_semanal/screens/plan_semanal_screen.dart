import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/meal_plan_providers.dart';
import '../widgets/plan_month_calendar.dart';

// The Plan semanal tab's landing screen: a month calendar. Tapping a day
// pushes PlanDayScreen for that date — this screen carries no "selected
// day" state of its own beyond which month is on screen.
class PlanSemanalScreen extends StatelessWidget {
  const PlanSemanalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan semanal'),
        actions: [
          TextButton.icon(
            icon: const Icon(Icons.shopping_cart_outlined),
            label: const Text('Compra'),
            onPressed: () => context.push('/plan/compra'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          const PlanMonthHeader(),
          const SizedBox(height: AppSpacing.lg),
          PlanMonthGrid(
            onDayTap: (day) => context.push('/plan/dia/${planDayPathSegment(day)}'),
          ),
        ],
      ),
    );
  }
}
