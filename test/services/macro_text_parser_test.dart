import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/services/nutrition_engine/macro_text_parser.dart';

void main() {
  test('reads the one-line format the copied prompt asks for', () {
    final m = parseMacrosFromText('Calorías: 650 kcal; Proteínas: 35 g; Carbohidratos: 60 g; Grasas: 25 g');
    expect(m.kcal, 650);
    expect(m.proteinG, 35);
    expect(m.carbsG, 60);
    expect(m.fatG, 25);
  });

  test('takes the total after a per-ingredient breakdown, ranges as midpoints', () {
    const answer = '''
**Estimación por ingredientes**
- Lentejas: 300 kcal, proteínas 18 g
- Chorizo: 200 kcal, proteínas 9 g

**Total aproximado**
- Calorías: ~600–700 kcal
- Proteínas: 30-34 g
- Hidratos de carbono: 55 g
- Grasas: 28 g
- Grasas saturadas: 9 g
''';
    final m = parseMacrosFromText(answer);
    expect(m.kcal, 650);
    expect(m.proteinG, 32);
    expect(m.carbsG, 55);
    expect(m.fatG, 28);
  });

  test('accepts "35 g de proteína", decimals with a comma and English labels', () {
    final es = parseMacrosFromText('Unas 520 kcal, 32,5 g de proteína, 40 g de carbohidratos y 22 g de grasa.');
    expect(es.kcal, 520);
    expect(es.proteinG, 32.5);
    expect(es.carbsG, 40);
    expect(es.fatG, 22);

    final en = parseMacrosFromText('Calories: 480\nProtein: 30g\nCarbs: 45g\nFat: 18g');
    expect(en.kcal, 480);
    expect(en.proteinG, 30);
    expect(en.carbsG, 45);
    expect(en.fatG, 18);
  });

  test('text without macros parses as empty', () {
    expect(parseMacrosFromText('¡Qué buena pinta! No sabría decirte.').isEmpty, isTrue);
  });

  test('kcalFromMacros uses 4/4/9', () {
    expect(kcalFromMacros(proteinG: 10, carbsG: 10, fatG: 10), 170);
  });
}
