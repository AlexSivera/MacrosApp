import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../diario/providers/diary_providers.dart';
import '../providers/meal_plan_providers.dart';
import '../providers/plan_day_summary_provider.dart';
import '../widgets/plan_day_summary_card.dart';
import '../widgets/plan_meal_section_card.dart';

// Reached by tapping a day in the Plan semanal month grid — the 6 meal
// sections (Desayuno/Almuerzo/Comida/Merienda/Cena/Extra) for that one date.
// Shares its meal cards with the Diario, so its header is what tells them
// apart: a "planned vs goal" bar instead of the Diario's ring, a line on
// what planning means, and — for today or past days — a jump to the Diario.
class PlanDayScreen extends ConsumerWidget {
  const PlanDayScreen({super.key, required this.date});

  final DateTime date;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final entriesAsync = ref.watch(mealPlanEntriesForDateProvider(date));
    final summary = ref.watch(planDaySummaryProvider(date));
    final theme = Theme.of(context);
    final canOpenDiario = !date.isAfter(ref.watch(todayProvider));

    return Scaffold(
      appBar: AppBar(
        title: Text(_capitalize(DateFormat('EEEE d MMMM', 'es').format(date))),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          PlanDaySummaryCard(summary: summary),
          Padding(
            padding: const EdgeInsets.fromLTRB(AppSpacing.xs, AppSpacing.sm, AppSpacing.xs, AppSpacing.md),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Lo que añadas aquí queda planificado. Toca el círculo de cada alimento cuando te lo comas.',
                  style: theme.textTheme.bodySmall,
                ),
                // In the body rather than the app bar, where it cut the
                // date title short.
                if (canOpenDiario)
                  TextButton.icon(
                    style: TextButton.styleFrom(padding: EdgeInsets.zero, visualDensity: VisualDensity.compact),
                    icon: const Icon(Icons.arrow_forward_rounded, size: 18),
                    label: const Text('Ver este día en el Diario'),
                    onPressed: () {
                      ref.read(selectedDiaryDateProvider.notifier).state = date;
                      context.go('/diario');
                    },
                  ),
              ],
            ),
          ),
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
