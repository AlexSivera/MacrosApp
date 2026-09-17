import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../diario/widgets/calorie_summary_card.dart';
import '../providers/meal_plan_providers.dart';
import '../providers/plan_day_summary_provider.dart';
import '../widgets/plan_meal_section_card.dart';

// Reached by tapping a day in the Plan semanal month grid — the 6 meal
// sections (Desayuno/Almuerzo/Comida/Merienda/Cena/Extra) for that one date.
class PlanDayScreen extends ConsumerWidget {
  const PlanDayScreen({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesForDateProvider(date));
    final summary = ref.watch(planDaySummaryProvider(date));

    return Scaffold(
      appBar: AppBar(
        title: Text(_capitalize(DateFormat('EEEE d MMMM', 'es').format(date))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          CalorieSummaryCard(summary: summary),
          const SizedBox(height: AppSpacing.md),
          entriesAsync.when(
            data: (entries) {
              final grouped = groupPlanEntriesByMeal(entries);
              return Column(
                children: [
                  for (final meal in mealSectionOrder) ...[
                    FadeSlideIn(
                      child: PlanMealSectionCard(
                        date: date,
                        mealType: meal,
                        entries: grouped[meal]!,
                      ),
                    ),
                    const SizedBox(height: AppSpacing.md),
                  ],
                ],
              );
            },
            loading: () => const _PlanSectionsSkeleton(),
            error: (err, _) => Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
              child: Center(child: Text('Error al cargar el plan: $err')),
            ),
          ),
        ],
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
}

class _PlanSectionsSkeleton extends StatelessWidget {
  const _PlanSectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 6; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ShimmerBox(width: 100, height: 12),
                  const SizedBox(height: AppSpacing.md),
                  ShimmerBox(width: double.infinity, height: 16),
                ],
              ),
            ),
          ),
      ],
    );
  }
}
