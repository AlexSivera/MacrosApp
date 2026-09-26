import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_motion.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/theme/app_theme.dart';
import '../providers/diary_providers.dart';
import '../../../core/utils/dates.dart';
import '../../../core/widgets/app_date_picker.dart';

class DateSelectorBar extends ConsumerWidget {
  const DateSelectorBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final selected = ref.watch(selectedDiaryDateProvider);
    final today = ref.watch(todayProvider);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
      decoration: BoxDecoration(
        color: theme.cardTheme.color,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: theme.colorScheme.outline),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _NavButton(
            icon: Icons.chevron_left_rounded,
            onPressed: () => ref.read(selectedDiaryDateProvider.notifier).state =
                addDays(selected, -1),
          ),
          Expanded(
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.pill),
              onTap: () async {
                final picked = await showAppDatePicker(
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
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.md),
                child: AnimatedSwitcher(
                  duration: AppMotion.of(context, AppMotion.fast),
                  child: Text(
                    _label(selected, today),
                    key: ValueKey(selected),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleMedium,
                  ),
                ),
              ),
            ),
          ),
          _NavButton(
            icon: Icons.chevron_right_rounded,
            onPressed: () => ref.read(selectedDiaryDateProvider.notifier).state =
                addDays(selected, 1),
          ),
        ],
      ),
    );
  }

  static String _label(DateTime date, DateTime today) {
    final diff = daysBetween(today, date);
    if (diff == 0) return 'Hoy';
    if (diff == -1) return 'Ayer';
    if (diff == 1) return 'Mañana';
    return capitalize(DateFormat('EEEE d MMM', 'es').format(date));
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({required this.icon, required this.onPressed});

  final IconData icon;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return IconButton(
      icon: Icon(icon),
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: theme.colorScheme.surfaceContainerHighest,
        foregroundColor: theme.colorScheme.onSurface,
        shape: const CircleBorder(),
      ),
    );
  }
}
