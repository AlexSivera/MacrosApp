import 'package:flutter/material.dart';

import '../../data/database/enums.dart';

// Shared by onboarding and Mis datos, which used to word the same levels
// differently ("Moderada (3-5 días/semana)" vs plain "Moderada").
extension ActivityLevelLabel on ActivityLevel {
  String get label => switch (this) {
        ActivityLevel.sedentary => 'Sedentario (poco o nada de ejercicio)',
        ActivityLevel.light => 'Ligera (1-3 días/semana)',
        ActivityLevel.moderate => 'Moderada (3-5 días/semana)',
        ActivityLevel.active => 'Alta (6-7 días/semana)',
        ActivityLevel.veryActive => 'Muy alta (trabajo físico + deporte)',
      };
}

List<DropdownMenuItem<ActivityLevel>> activityLevelItems() => [
      for (final level in ActivityLevel.values) DropdownMenuItem(value: level, child: Text(level.label)),
    ];
