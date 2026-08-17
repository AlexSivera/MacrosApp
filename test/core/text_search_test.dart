import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/core/utils/text_search.dart';

void main() {
  test('strips Spanish accents and folds case', () {
    expect(normalizeForSearch('Atún'), 'atun');
    expect(normalizeForSearch('Brócoli'), 'brocoli');
    expect(normalizeForSearch('Jamón'), 'jamon');
    expect(normalizeForSearch('Piña'), 'pina');
    expect(normalizeForSearch('Plátano'), 'platano');
  });

  test('unaccented input matches its accented counterpart once normalized', () {
    expect(normalizeForSearch('atun'), normalizeForSearch('Atún'));
    expect(normalizeForSearch('brocoli'), normalizeForSearch('Brócoli'));
  });

  test('leaves plain ASCII text untouched apart from case', () {
    expect(normalizeForSearch('Pollo'), 'pollo');
  });
}
