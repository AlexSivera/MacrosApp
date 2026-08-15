import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import '../theme/app_theme.dart';

// Shared rounded, padded card used across every stat/section surface. Built
// on a plain Container (not Card) so it can carry a soft directional shadow
// alongside its border — that combination is what makes surfaces read as
// raised, tactile panels instead of the flat bordered boxes a bare
// CardTheme produces.
class AppCard extends StatelessWidget {
  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.color,
    this.borderColor,
  });

  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? color;

  // Overrides the theme's default grey border — used sparingly to give a
  // card more visual weight (e.g. the Diario summary card) without
  // introducing a one-off shape everywhere it's needed.
  final Color? borderColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cardShape = theme.cardTheme.shape as RoundedRectangleBorder?;
    final radius = cardShape?.borderRadius as BorderRadius? ??
        BorderRadius.circular(AppRadius.md);

    return Container(
      padding: padding ?? const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: color ?? theme.cardTheme.color,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ?? theme.colorScheme.outline,
          width: borderColor == null ? 1 : 1.5,
        ),
        boxShadow: AppTheme.softShadow(context),
      ),
      child: child,
    );
  }
}
