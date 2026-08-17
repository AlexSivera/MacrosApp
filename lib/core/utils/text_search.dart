const _accentFolds = {
  'á': 'a', 'à': 'a', 'ä': 'a', 'â': 'a',
  'é': 'e', 'è': 'e', 'ë': 'e', 'ê': 'e',
  'í': 'i', 'ì': 'i', 'ï': 'i', 'î': 'i',
  'ó': 'o', 'ò': 'o', 'ö': 'o', 'ô': 'o',
  'ú': 'u', 'ù': 'u', 'ü': 'u', 'û': 'u',
  'ñ': 'n',
  'ç': 'c',
};

// Lowercases and strips Spanish accents/diacritics so search matches
// regardless of whether the user typed them — 'atun' finds 'Atún', 'brocoli'
// finds 'Brócoli'. Apply to both the query and the candidate text.
String normalizeForSearch(String input) {
  final buffer = StringBuffer();
  for (final rune in input.toLowerCase().runes) {
    final ch = String.fromCharCode(rune);
    buffer.write(_accentFolds[ch] ?? ch);
  }
  return buffer.toString();
}
