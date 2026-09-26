import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
import '../../../services/nutrition_engine/goal_weight.dart';
import '../../diario/providers/diary_providers.dart';
import '../providers/progress_providers.dart';
import '../widgets/avg_macros_card.dart';
import '../widgets/current_goal_card.dart';
import '../widgets/range_selector.dart';
import '../widgets/weight_chart.dart';
import '../widgets/weight_stats_row.dart';
import 'log_weight_sheet.dart';

class ProgressScreen extends ConsumerWidget {
  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final range = ref.watch(progressRangeProvider);
    final historyAsync = ref.watch(weightHistoryForRangeProvider);
    final earliestAsync = ref.watch(earliestWeightProvider);
    final avgMacrosAsync = ref.watch(averageMacrosForRangeProvider);
    final profileAsync = ref.watch(userProfileStreamProvider);
    final targets = ref.watch(resolvedTargetsProvider);
    final latestWeight = ref.watch(latestWeightKgProvider);
    final profile = profileAsync.valueOrNull;
    final goalType = profile?.goalType ?? GoalType.maintain;
    final startingKg = earliestAsync.valueOrNull?.weightKg ?? profile?.startingWeightKg;
    // Judged against where the goal started from, not today's weight, so
    // reaching (or passing) the goal doesn't read as a broken goal. Profiles
    // saved before the goal weight was required can have none, or one equal
    // to the starting weight.
    final goalIsSet = goalWeightFitsGoal(goalType, profile?.goalWeightKg, startingKg);
    final goalKg = goalType != GoalType.maintain && goalIsSet ? profile?.goalWeightKg : null;

    return Scaffold(
      appBar: AppBar(title: const Text('Progreso')),
      // Labelled rather than a bare "+" in the app bar, which didn't say
      // what it added.
      floatingActionButton: FloatingActionButton.extended(
        icon: const Icon(Icons.monitor_weight_outlined),
        label: const Text('Registrar peso'),
        onPressed: () => LogWeightSheet.show(context),
      ),
      body: ListView(
        // Bottom room so the last card can scroll clear of the button.
        padding: const EdgeInsets.fromLTRB(AppSpacing.lg, AppSpacing.lg, AppSpacing.lg, 96),
        children: [
          if (profile != null && !goalIsSet) ...[
            _SetGoalWeightCard(onTap: () => context.push('/perfil/objetivo')),
            const SizedBox(height: AppSpacing.lg),
          ],
          WeightStatsRow(
            currentKg: latestWeight,
            startingKg: startingKg,
            goalKg: goalIsSet ? profile?.goalWeightKg : null,
            goalType: goalType,
          ),
          const SizedBox(height: AppSpacing.lg),
          const RangeSelector(),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: SizedBox(
              height: 220,
              child: historyAsync.when(
                skipLoadingOnReload: true,
                data: (logs) => WeightChart(logs: logs, goalKg: goalKg),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          avgMacrosAsync.when(
            skipLoadingOnReload: true,
            data: (avg) => AvgMacrosCard(average: avg, rangeLabel: range.label),
            // Holds the card's height while loading so the goal card below
            // doesn't jump up and back down.
            loading: () => const SizedBox(height: 118),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: AppSpacing.lg),
          CurrentGoalCard(goalType: goalType, targets: targets),
        ],
      ),
    );
  }
}

class _SetGoalWeightCard extends StatelessWidget {
  const _SetGoalWeightCard({required this.onTap});

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return AppCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppSpacing.lg),
      child: Row(
        children: [
          Icon(Icons.flag_outlined, color: theme.colorScheme.primary),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Define tu peso objetivo', style: theme.textTheme.titleMedium),
                const SizedBox(height: 2),
                Text('Para ver cuánto te queda y marcarlo en el gráfico.', style: theme.textTheme.bodySmall),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
        ],
      ),
    );
  }
}
