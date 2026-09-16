import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../providers/meal_plan_providers.dart';
import '../widgets/plan_meal_section_card.dart';
import '../widgets/plan_week_selector_bar.dart';

class PlanSemanalScreen extends ConsumerWidget {
  const PlanSemanalScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesForSelectedDateProvider);
    final selectedDate = ref.watch(selectedPlanDateProvider);

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
          const SizedBox(height: AppSpacing.md),
          const PlanDayChips(),
          const SizedBox(height: AppSpacing.xl),
          entriesAsync.when(
            data: (entries) {
              final grouped = groupPlanEntriesByMeal(entries);
              return Column(
                children: [
                  for (final meal in mealSectionOrder) ...[
                    FadeSlideIn(
                      child: PlanMealSectionCard(
                        date: selectedDate,
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
}

class _PlanSectionsSkeleton extends StatelessWidget {
  const _PlanSectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < 5; i++)
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
