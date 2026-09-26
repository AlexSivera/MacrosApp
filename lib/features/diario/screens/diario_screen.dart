import 'package:confetti/confetti.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/celebration_overlay.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/health_connect/health_connect_service.dart';
import '../../plan_semanal/providers/meal_plan_providers.dart';
import '../../plan_semanal/widgets/plan_meal_section_card.dart';
import '../providers/diary_providers.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/detalles_sheet.dart';
import '../widgets/weigh_in_reminder.dart';
import '../../../core/utils/dates.dart';

class DiarioScreen extends ConsumerStatefulWidget {
  const DiarioScreen({super.key});

  @override
  ConsumerState<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends ConsumerState<DiarioScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 900));
  final _goalReachedByDate = <DateTime, bool>{};
  bool _slideFromRight = true;
  bool _syncingHealthConnect = false;

  @override
  void dispose() {
    _confetti.dispose();
    super.dispose();
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

  // Celebrates only when the goal flips from "not reached" to "reached"
  // while watching today — not when opening a day that already met it, nor
  // when browsing past days.
  void _maybeCelebrate(DateTime date, bool goalReached) {
    final previous = _goalReachedByDate[date];
    _goalReachedByDate[date] = goalReached;
    if (previous == false &&
        goalReached &&
        date == ref.read(todayProvider) &&
        mounted &&
        !AppMotion.reduced(context)) {
      _confetti.play();
    }
  }

  void _shiftDay(int days) {
    final notifier = ref.read(selectedDiaryDateProvider.notifier);
    notifier.state = addDays(notifier.state, days);
  }

  @override
  Widget build(BuildContext context) {
    final selectedDate = ref.watch(selectedDiaryDateProvider);
    final entriesAsync = ref.watch(diaryEntriesForSelectedDateProvider);
    final previousDayEntries = ref.watch(diaryPreviousDayEntriesProvider).valueOrNull ?? const [];
    final summary = ref.watch(diarySummaryProvider);

    // Slide direction for the day change: newer days come in from the right.
    ref.listen(selectedDiaryDateProvider, (previous, next) {
      if (previous != null) _slideFromRight = next.isAfter(previous);
    });

    // "Goal reached" = within a tight band of the target, not just barely
    // over 0% — reaching 95-105% of target reads as "on plan today" without
    // requiring the user to hit the number exactly. Only judged once the
    // day's entries have actually loaded, so the empty loading state never
    // counts as "not reached yet".
    final loaded = entriesAsync.hasValue && !entriesAsync.isLoading;
    if (loaded) {
      final goalReached = summary.calorieTarget > 0 &&
          summary.consumedKcal >= summary.calorieTarget * 0.95 &&
          !summary.isOverTarget;
      WidgetsBinding.instance.addPostFrameCallback((_) => _maybeCelebrate(selectedDate, goalReached));
    }
    final repeatableMeals = {for (final e in previousDayEntries) e.entry.mealType};

    final dayContent = Column(
      key: ValueKey(selectedDate),
      children: [
        CalorieSummaryCard(summary: summary),
        if (selectedDate == ref.watch(todayProvider)) const WeighInReminder(),
        const SizedBox(height: AppSpacing.xl),
        entriesAsync.when(
          data: (entries) {
            final grouped = groupPlanEntriesByMeal(entries);
            return Column(
              children: [
                for (final meal in mealSectionOrder) ...[
                  PlanMealSectionCard(
                    date: selectedDate,
                    mealType: meal,
                    entries: grouped[meal]!,
                    diaryMode: true,
                    canRepeatFromYesterday: repeatableMeals.contains(meal),
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
    );

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
          // A horizontal fling anywhere on the page moves one day back or
          // forward (entry rows keep their own swipe-to-delete, which wins
          // the gesture when the drag starts on them).
          GestureDetector(
            behavior: HitTestBehavior.translucent,
            onHorizontalDragEnd: (details) {
              final velocity = details.primaryVelocity ?? 0;
              if (velocity < -300) _shiftDay(1);
              if (velocity > 300) _shiftDay(-1);
            },
            child: ListView(
              padding: const EdgeInsets.all(AppSpacing.lg),
              children: [
                const DateSelectorBar(),
                const SizedBox(height: AppSpacing.lg),
                AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.normal),
                  switchInCurve: AppMotion.curve,
                  switchOutCurve: Curves.easeInCubic,
                  layoutBuilder: (current, previous) => Stack(
                    alignment: Alignment.topCenter,
                    children: [...previous, ?current],
                  ),
                  transitionBuilder: (child, animation) {
                    final incoming = child.key == ValueKey(selectedDate);
                    final dx = (_slideFromRight ? 1 : -1) * (incoming ? 0.12 : -0.12);
                    return FadeTransition(
                      opacity: animation,
                      child: SlideTransition(
                        position: Tween(begin: Offset(dx, 0), end: Offset.zero).animate(animation),
                        child: child,
                      ),
                    );
                  },
                  child: dayContent,
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
