// Reads kcal/protein/carbs/fat out of a free-text answer — typically what
// ChatGPT (or any assistant) replies after being sent a photo of a dish:
// "Calorías: ~650 kcal · Proteínas: 35 g · Carbohidratos: 60-70 g ...".
//
// Lenient on purpose: Spanish or English labels, "label: 35 g" or
// "35 g de proteína", ranges ("60-70", "60 a 70") become their midpoint, and
// when a label appears more than once (a per-ingredient breakdown followed
// by a total) the last one wins, since that's where answers put the total.
class ParsedMacros {
  const ParsedMacros({this.kcal, this.proteinG, this.carbsG, this.fatG});

  final double? kcal;
  final double? proteinG;
  final double? carbsG;
  final double? fatG;

  bool get isEmpty => kcal == null && proteinG == null && carbsG == null && fatG == null;
}

const _number = r'(\d+(?:[.,]\d+)?)(?:\s*(?:-|–|a|to)\s*(\d+(?:[.,]\d+)?))?';

// Between a label and its number: anything on the same line short of a
// separator, so "Proteínas (aprox.): 35 g" works but "650 kcal, proteína"
// never hands kcal's label the protein figure.
const _gap = r'[^\d\n,;]{0,30}?';

const _kcalLabels = r'calor[ií]as|energ[ií]a|calories|energy';
const _proteinLabels = r'prote[ií]nas?|protein';
const _carbsLabels = r'carbohidratos|hidratos(?:\s+de\s+carbono)?|carbos?|carbs?|carbohydrates';
// "Grasas saturadas: 8 g" is a breakdown line, not the fat total.
const _fatLabels = r'(?:grasas?|l[ií]pidos|fats?)(?![a-z]|[ \t]+saturad)';

double? _value(RegExpMatch m, int first) {
  final a = double.tryParse(m.group(first)!.replaceAll(',', '.'));
  final bText = m.group(first + 1);
  if (a == null) return null;
  final b = bText == null ? null : double.tryParse(bText.replaceAll(',', '.'));
  return b == null ? a : (a + b) / 2;
}

// Last match of either "label … number" or "number [unit] [de] label" (the
// latter kept to one line, so "60 g\nProteínas: 35 g" never reads as 60 g
// of protein).
double? _find(String text, String labels, {required String unit, String? trailingLabels}) {
  final labelFirst = RegExp('(?:$labels)$_gap$_number', caseSensitive: false);
  final numberFirst = RegExp(
    '$_number[ \\t]*(?:$unit)?[ \\t]*(?:de[ \\t]+|of[ \\t]+)?(?:${trailingLabels ?? labels})',
    caseSensitive: false,
  );
  (int, double)? best;
  final trailing = numberFirst.allMatches(text).toList();
  for (final m in trailing) {
    final v = _value(m, 1);
    if (v != null && (best == null || m.start >= best.$1)) best = (m.start, v);
  }
  for (final m in labelFirst.allMatches(text)) {
    // A label that already closes "40 g de carbohidratos" isn't also a
    // label for whatever number comes next ("… y 22 g de grasa").
    if (trailing.any((t) => m.start > t.start && m.start < t.end)) continue;
    final v = _value(m, 1);
    if (v != null && (best == null || m.start >= best.$1)) best = (m.start, v);
  }
  return best?.$2;
}

ParsedMacros parseMacrosFromText(String text) {
  return ParsedMacros(
    // "650 kcal" on its own also counts — kcal is only ever a unit, never
    // a label to read forward from (see _gap).
    kcal: _find(text, _kcalLabels, unit: r'kcal', trailingLabels: '$_kcalLabels|kcal'),
    proteinG: _find(text, _proteinLabels, unit: r'g|gr|gramos|grams'),
    carbsG: _find(text, _carbsLabels, unit: r'g|gr|gramos|grams'),
    fatG: _find(text, _fatLabels, unit: r'g|gr|gramos|grams'),
  );
}

// Atwater estimate, for when only the macros are known.
double kcalFromMacros({required double proteinG, required double carbsG, required double fatG}) =>
    proteinG * 4 + carbsG * 4 + fatG * 9;

// Copied to the clipboard from the quick-entry sheet so the answer comes
// back in a shape parseMacrosFromText reads reliably.
const chatGptMacrosPrompt =
    'Te paso una foto de un plato. Estima las calorías y macros de la ración que se ve. '
    'Al final responde con una sola línea exactamente así: '
    'Calorías: X kcal; Proteínas: X g; Carbohidratos: X g; Grasas: X g';
