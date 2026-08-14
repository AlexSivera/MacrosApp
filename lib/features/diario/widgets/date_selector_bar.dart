import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_spacing.dart';
import '../providers/diary_providers.dart';

class DateSelectorBar extends ConsumerWidget {
  const DateSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(selectedDiaryDateProvider);
    final today = _today();
    final isToday = selected == today;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          IconButton(
            icon: const Icon(Icons.chevron_left),
            onPressed: () => ref.read(selectedDiaryDateProvider.notifier).state =
                selected.subtract(const Duration(days: 1)),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppSpacing.sm),
              onTap: () async {
                final picked = await showDatePicker(
                  context: context,
                  initialDate: selected,
                  firstDate: DateTime(2020),
                  lastDate: today.add(const Duration(days: 365)),
                );
                if (picked != null) {
                  ref.read(selectedDiaryDateProvider.notifier).state =
                      DateTime(picked.year, picked.month, picked.day);
                }
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                child: Text(
                  isToday ? 'Hoy' : _label(selected),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.chevron_right),
            onPressed: () => ref.read(selectedDiaryDateProvider.notifier).state =
                selected.add(const Duration(days: 1)),
          ),
        ],
      ),
    );
  }

  static DateTime _today() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  static String _label(DateTime date) => DateFormat('EEEE d MMM', 'es').format(date);
}
