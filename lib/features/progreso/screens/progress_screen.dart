import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
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

    return Scaffold(
      appBar: AppBar(
        title: const Text('Progreso'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            tooltip: 'Registrar peso',
            onPressed: () => LogWeightSheet.show(context),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          WeightStatsRow(
            currentKg: latestWeight,
            startingKg: earliestAsync.valueOrNull?.weightKg ??
                profileAsync.valueOrNull?.startingWeightKg,
            goalKg: profileAsync.valueOrNull?.goalWeightKg,
          ),
          const SizedBox(height: AppSpacing.lg),
          const RangeSelector(),
          const SizedBox(height: AppSpacing.lg),
          AppCard(
            child: SizedBox(
              height: 220,
              child: historyAsync.when(
                data: (logs) => WeightChart(logs: logs),
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (err, _) => Center(child: Text('Error: $err')),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          avgMacrosAsync.when(
            data: (avg) => AvgMacrosCard(average: avg, rangeLabel: range.label),
            loading: () => const SizedBox.shrink(),
            error: (err, _) => Text('Error: $err'),
          ),
          const SizedBox(height: AppSpacing.lg),
          CurrentGoalCard(
            goalType: profileAsync.valueOrNull?.goalType ?? GoalType.maintain,
            targets: targets,
          ),
        ],
      ),
    );
  }
}
