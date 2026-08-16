import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';

// Tonal pill for secondary "add" actions — visible against a dark
// background (unlike a plain OutlinedButton, whose default grey border
// nearly disappears) without competing with a screen's primary CTA. Shared
// by every "+ Añadir…" affordance: the Diario's meal sections and the
// recipe editor's ingredient list.
class AppAddButton extends StatelessWidget {
  const AppAddButton({super.key, required this.label, required this.onPressed});

  final String label;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Align(
      alignment: Alignment.centerLeft,
      child: Material(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: InkWell(
          borderRadius: BorderRadius.circular(AppRadius.pill),
          onTap: onPressed,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.add_rounded, size: 18, color: theme.colorScheme.primary),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
