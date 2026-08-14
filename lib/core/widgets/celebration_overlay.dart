import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

// A brief confetti burst — used once per day when the calorie goal is first
// reached, per the brief's "al completar un objetivo: pequeña animación
// visual". Deliberately small and short-lived, not a full-screen takeover.
class CelebrationOverlay extends StatelessWidget {
  const CelebrationOverlay({super.key, required this.controller});

  final ConfettiController controller;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Align(
        alignment: Alignment.topCenter,
        child: ConfettiWidget(
          confettiController: controller,
          blastDirection: 1.5708, // straight down
          maxBlastForce: 8,
          minBlastForce: 3,
          numberOfParticles: 16,
          gravity: 0.3,
          emissionFrequency: 0.03,
          colors: const [
            AppTheme.accent,
            AppTheme.carbsColor,
            AppTheme.proteinColor,
            AppTheme.fatColor,
          ],
        ),
      ),
    );
  }
}
