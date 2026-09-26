import 'package:intl/intl.dart';

import '../../services/nutrition_engine/food_macros_calculator.dart';

// Spanish number formatting everywhere a decimal is shown: "80,5 kg", never
// "80.5 kg". Integers stay integers ("80"), so input fields prefilled with
// a whole number don't grow a pointless ",0".
final _oneDecimal = NumberFormat('0.0', 'es');
final _upToOneDecimal = NumberFormat('0.#', 'es');
final _upToTwoDecimals = NumberFormat('0.##', 'es');

// Always one decimal — body weight, where "80,0" vs "80,5" should align.
String formatKg(double kg) => '${_oneDecimal.format(kg)} kg';

// "0,5", "1", "1,5" — kg/semana, raciones, units.
String formatDecimal(double value) => _upToOneDecimal.format(value);

// Prefill for numeric text fields (grams, servings): keeps precision the
// user typed, with a comma — parseDecimal() reads it back.
String formatInputNumber(double value) => _upToTwoDecimals.format(value);

// Accepts both "1,5" and "1.5".
double? parseDecimal(String text) => double.tryParse(text.trim().replaceAll(',', '.'));

// One compact line of macros, always in the app's P · C · G order:
// "330 kcal · P 62 · C 0 · G 7".
String macroLine(FoodMacros m) =>
    '${m.kcal.round()} kcal · P ${m.proteinG.round()} · C ${m.carbsG.round()} · G ${m.fatG.round()}';

// A calendar date in full, everywhere one is shown on its own: "1 ene 2001".
String formatLongDate(DateTime date) => DateFormat('d MMM y', 'es').format(date);

// Spanish dates are lowercase ("21 de septiembre"); only a leading word gets
// capitalized where it opens a title.
String capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);
