import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/celebration_overlay.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/health_connect/health_connect_service.dart';
import '../../plan_semanal/providers/meal_plan_providers.dart';
import '../../plan_semanal/widgets/plan_meal_section_card.dart';
import '../providers/diary_providers.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/detalles_sheet.dart';

class DiarioScreen extends ConsumerStatefulWidget {
  const DiarioScreen({super.key});

  @override
  ConsumerState<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends ConsumerState<DiarioScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 900));
  DateTime? _celebratedForDate;
  bool _syncingHealthConnect = false;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
  }

  void _maybeCelebrate(DateTime date, bool goalReached) {
    if (!goalReached) return;
    if (_celebratedForDate == date) return;
    _celebratedForDate = date;
    _confetti.play();
  }

  // Pulls "calorías quemadas" for the selected day from Health Connect (e.g.
  // a Xiaomi Smart Band synced there via Mi Fitness) and stores it as a
  // device-sourced BurnedCalories row — see upsertDeviceEntryForDate.
  Future<void> _syncHealthConnect() async {
    final messenger = ScaffoldMessenger.of(context);
    final date = ref.read(selectedDiaryDateProvider);
    setState(() => _syncingHealthConnect = true);
    try {
      final availability = await checkHealthConnectAvailability();
      if (availability == HealthConnectAvailability.needsInstall) {
        await openHealthConnectInstall();
        return;
      }

      final granted = await requestBurnedCaloriesPermission();
      if (!granted) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Permiso de Health Connect denegado.')),
        );
        return;
      }

      final kcal = await fetchBurnedKcalForDate(date);
      if (kcal == null) {
        messenger.showSnackBar(
          const SnackBar(content: Text('Health Connect no tiene datos de calorías quemadas para este día.')),
        );
        return;
      }

      await ref.read(appDatabaseProvider).burnedCaloriesDao.upsertDeviceEntryForDate(
            date,
            kcal,
            label: 'Health Connect',
          );
      messenger.showSnackBar(
        SnackBar(content: Text('Sincronizado: ${kcal.round()} kcal quemadas.')),
      );
    } finally {
      if (mounted) setState(() => _syncingHealthConnect = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDiaryDateProvider);
    final entriesAsync = ref.watch(diaryEntriesForSelectedDateProvider);
    final summary = ref.watch(diarySummaryProvider);

    // "Goal reached" = within a tight band of the target, not just barely
    // over 0% — reaching 95-105% of target reads as "on plan today" without
    // requiring the user to hit the number exactly.
    final goalReached = summary.calorieTarget > 0 &&
        summary.consumedKcal >= summary.calorieTarget * 0.95 &&
        !summary.isOverTarget;
    WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate(selectedDate, goalReached));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Diario'),
        actions: [
          if (!kIsWeb)
            IconButton(
              tooltip: 'Sincronizar calorías quemadas con Health Connect',
              icon: _syncingHealthConnect
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.watch_outlined),
              onPressed: _syncingHealthConnect ? null : _syncHealthConnect,
            ),
          TextButton(
            onPressed: () => DetallesSheet.show(context, summary),
            child: const Text('Detalles'),
          ),
        ],
      ),
      body: Stack(
        children: [
          RefreshIndicator(
            onRefresh: () async {},
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const DateSelectorBar(),
                const SizedBox(height: AppSpacing.lg),
                FadeSlideIn(child: CalorieSummaryCard(summary: summary)),
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
                  loading: () => const _MealSectionsSkeleton(),
                  error: (err, _) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xxl),
                    child: Center(child: Text('Error al cargar el diario: $err')),
                  ),
                ),
              ],
            ),
          ),
          CelebrationOverlay(controller: _confetti),
        ],
      ),
    );
  }
}

class _MealSectionsSkeleton extends StatelessWidget {
  const _MealSectionsSkeleton();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (var i = 0; i < mealSectionOrder.length; i++)
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: Theme.of(context).cardTheme.color,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: Theme.of(context).colorScheme.outline),
              ),
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
