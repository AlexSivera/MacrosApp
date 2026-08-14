import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../theme/app_motion.dart';
import '../theme/app_theme.dart';

// The Diario's centerpiece — a ring showing consumed/target calories, with
// the "Restantes" figure as the number inside it. fraction is always
// pre-clamped to [0,1] by the caller (see DiarySummary.ringFraction) so the
// ring itself never needs to reason about over-target state.
//
// Drawn as an open gauge (270° sweep, gap centered at the bottom) rather
// than a closed circle — a full ring reads as "done"/a clock face, while
// the open gauge reads as a meter with headroom left in it.
class CircularCalorieRing extends StatelessWidget {
  const CircularCalorieRing({
    super.key,
    required this.fraction,
    required this.centerValue,
    required this.centerLabel,
    this.isOverTarget = false,
    this.size = 168,
    this.strokeWidth = 14,
  });

  final double fraction;
  final String centerValue;
  final String centerLabel;
  final bool isOverTarget;
  final double size;
  final double strokeWidth;

  static const double _startAngle = 0.75 * math.pi; // 135°, bottom-left
  static const double _sweepAngle = 1.5 * math.pi; // 270°

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ringColor = isOverTarget ? AppTheme.statusOverTarget : AppTheme.accent;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: fraction),
            duration: AppMotion.slow,
            curve: AppMotion.curve,
            builder: (context, value, _) => CustomPaint(
              size: Size(size, size),
              painter: _GaugePainter(
                trackColor: AppTheme.statusEmpty,
                progressColor: ringColor,
                strokeWidth: strokeWidth,
                fraction: value,
              ),
            ),
          ),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                centerValue,
                style: theme.textTheme.displaySmall?.copyWith(
                  color: isOverTarget ? AppTheme.statusOverTarget : null,
                  fontSize: 28,
                ),
              ),
              Text(centerLabel, style: theme.textTheme.bodySmall),
            ],
          ),
        ],
      ),
    );
  }
}

class _GaugePainter extends CustomPainter {
  _GaugePainter({
    required this.trackColor,
    required this.progressColor,
    required this.strokeWidth,
    required this.fraction,
  });

  final Color trackColor;
  final Color progressColor;
  final double strokeWidth;
  final double fraction;

  @override
  void paint(Canvas canvas, Size size) {
    final ringRect = (Offset.zero & size).deflate(strokeWidth / 2);

    final trackPaint = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(
      ringRect,
      CircularCalorieRing._startAngle,
      CircularCalorieRing._sweepAngle,
      false,
      trackPaint,
    );

    if (fraction > 0) {
      final progressPaint = Paint()
        ..color = progressColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;
      canvas.drawArc(
        ringRect,
        CircularCalorieRing._startAngle,
        CircularCalorieRing._sweepAngle * fraction.clamp(0, 1),
        false,
        progressPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _GaugePainter oldDelegate) {
    return oldDelegate.trackColor != trackColor ||
        oldDelegate.progressColor != progressColor ||
        oldDelegate.strokeWidth != strokeWidth ||
        oldDelegate.fraction != fraction;
  }
}
