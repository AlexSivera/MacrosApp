import 'package:flutter/widgets.dart';

// Consistent animation timings so every card/state transition in the app
// feels like the same product instead of default per-widget durations.
class AppMotion {
  AppMotion._();

  static const Duration fast = Duration(milliseconds: 150);
  static const Duration normal = Duration(milliseconds: 220);
  static const Duration slow = Duration(milliseconds: 320);

  // Numbers counting up/down and the calorie ring filling — long enough to
  // read as "the total changed by this much", short enough not to lag input.
  static const Duration counter = Duration(milliseconds: 450);

  static const Curve curve = Curves.easeOutCubic;

  // Honors the OS "reduce motion" setting (prefers-reduced-motion on web):
  // every animation in the app goes through this, so turning it on makes
  // state changes instant instead of animated.
  static bool reduced(BuildContext context) => MediaQuery.maybeDisableAnimationsOf(context) ?? false;

  static Duration of(BuildContext context, Duration duration) =>
      reduced(context) ? Duration.zero : duration;
}
