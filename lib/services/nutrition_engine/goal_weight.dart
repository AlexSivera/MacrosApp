import '../../core/utils/formatters.dart';
import '../../data/database/enums.dart';

// A weight goal only means something when it points the way the goal type
// does — below the current weight to lose, above it to gain. Saving
// "Perder" with no goal weight (or one equal to today's) used to leave
// Progreso showing Objetivo = Actual and nothing to track.

// Whether a stored goal weight is usable for the goal type. Maintaining
// needs none; losing/gaining need one on the right side of currentKg.
bool goalWeightFitsGoal(GoalType goalType, double? goalKg, double? currentKg) {
  if (goalType == GoalType.maintain) return true;
  if (goalKg == null || currentKg == null) return false;
  return goalType == GoalType.lose ? goalKg < currentKg : goalKg > currentKg;
}

// The error to show for a goal weight typed into a form, or null if it's
// fine. currentKg is the weight it's compared against (null skips that
// check, e.g. before any weight is known).
String? goalWeightError(GoalType goalType, String input, double? currentKg) {
  if (goalType == GoalType.maintain) return null;
  if (input.trim().isEmpty) {
    return goalType == GoalType.lose
        ? 'Indica cuánto quieres llegar a pesar.'
        : 'Indica a qué peso quieres llegar.';
  }
  final goal = parseDecimal(input);
  if (goal == null || goal < 30 || goal > 300) return 'El peso objetivo no parece válido.';
  if (currentKg != null && !goalWeightFitsGoal(goalType, goal, currentKg)) {
    return goalType == GoalType.lose
        ? 'Para perder peso, el objetivo tiene que ser menor que ${formatKg(currentKg)}.'
        : 'Para ganar peso, el objetivo tiene que ser mayor que ${formatKg(currentKg)}.';
  }
  return null;
}
