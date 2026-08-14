import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/celebration_overlay.dart';
import '../../../core/widgets/fade_slide_in.dart';
import '../../../core/widgets/shimmer_box.dart';
import '../providers/diary_providers.dart';
import '../widgets/calorie_summary_card.dart';
import '../widgets/date_selector_bar.dart';
import '../widgets/detalles_sheet.dart';
import '../widgets/meal_section_card.dart';

class DiarioScreen extends ConsumerStatefulWidget {
  const DiarioScreen({super.key});

  @override
  ConsumerState<DiarioScreen> createState() => _DiarioScreenState();
}

class _DiarioScreenState extends ConsumerState<DiarioScreen> {
  late final ConfettiController _confetti =
      ConfettiController(duration: const Duration(milliseconds: 900));
  DateTime? _celebratedForDate;

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

  @override
  Widget build(BuildContext context) {
    final entriesAsync = ref.watch(diaryEntriesForSelectedDateProvider);
    final summary = ref.watch(diarySummaryProvider);
    final selectedDate = ref.watch(selectedDiaryDateProvider);

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
                    final grouped = groupEntriesByMeal(entries);
                    return Column(
                      children: [
                        for (final meal in mealSectionOrder) ...[
                          FadeSlideIn(
                            child: MealSectionCard(mealType: meal, entries: grouped[meal]!),
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
        for (var i = 0; i < 5; i++)
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
