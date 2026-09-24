import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/enums.dart';
import 'package:macrosapp/services/nutrition_engine/goal_weight.dart';

void main() {
  group('goalWeightError', () {
    test('maintaining needs no goal weight', () {
      expect(goalWeightError(GoalType.maintain, '', 80), isNull);
    });

    test('losing or gaining requires one', () {
      expect(goalWeightError(GoalType.lose, '  ', 80), isNotNull);
      expect(goalWeightError(GoalType.gain, '', 80), isNotNull);
    });

    test('rejects unparseable or implausible values', () {
      expect(goalWeightError(GoalType.lose, 'abc', 80), 'El peso objetivo no parece válido.');
      expect(goalWeightError(GoalType.lose, '20', 80), 'El peso objetivo no parece válido.');
    });

    test('the goal has to point the way the goal type does', () {
      expect(goalWeightError(GoalType.lose, '75', 80), isNull);
      expect(goalWeightError(GoalType.lose, '80', 80), contains('menor que 80,0 kg'));
      expect(goalWeightError(GoalType.gain, '85,5', 80), isNull);
      expect(goalWeightError(GoalType.gain, '79', 80), contains('mayor que 80,0 kg'));
    });

    test('skips the direction check when no current weight is known', () {
      expect(goalWeightError(GoalType.lose, '90', null), isNull);
    });
  });

  group('goalWeightFitsGoal', () {
    test('flags goals saved before the goal weight was required', () {
      // Onboarding used to store the starting weight as the goal.
      expect(goalWeightFitsGoal(GoalType.lose, 80.5, 80.5), isFalse);
      expect(goalWeightFitsGoal(GoalType.gain, null, 70), isFalse);
    });

    test('accepts a goal on the right side, and any maintain goal', () {
      expect(goalWeightFitsGoal(GoalType.lose, 75, 80.5), isTrue);
      expect(goalWeightFitsGoal(GoalType.gain, 75, 70), isTrue);
      expect(goalWeightFitsGoal(GoalType.maintain, null, null), isTrue);
    });
  });
}
