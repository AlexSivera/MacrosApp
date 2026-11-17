import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:macrosapp/data/database/app_database.dart';
import 'package:macrosapp/services/nutrition_engine/food_macros_calculator.dart';
import 'package:macrosapp/services/nutrition_engine/meal_plan_macros_calculator.dart';

void main() {
  late AppDatabase db;

  setUp(() => db = AppDatabase.forTesting(NativeDatabase.memory()));
  tearDown(() => db.close());

  const macros = FoodMacros(kcal: 650, proteinG: 35, carbsG: 60, fatG: 25);
  final date = DateTime(2026, 11, 17);

  test('a quick entry counts its typed macros and shows its own name', () async {
    await db.mealPlanDao.addQuick(
      date: date,
      mealType: MealType.lunch,
      label: 'Lentejas de mamá',
      macros: macros,
      orderIndex: 0,
    );

    final entries = await db.mealPlanDao.watchEntriesForDate(date).first;
    expect(entries.single.label, 'Lentejas de mamá');
    final entry = entries.single.entry;
    expect(entry.isEaten, isTrue);
    expect(isQuickEntry(entry), isTrue);
    expect((await resolveEntryMacros(db, entry)).kcal, 650);
  });

  test('unticking and re-ticking a quick entry keeps its macros', () async {
    final id = await db.mealPlanDao.addQuick(
      date: date,
      mealType: MealType.lunch,
      label: 'Comida casera',
      macros: macros,
      orderIndex: 0,
    );

    await db.mealPlanDao.markPlanned(id);
    var entry = (await db.mealPlanDao.getById(id))!;
    expect(entry.isEaten, isFalse);
    expect((await resolveEntryMacros(db, entry)).proteinG, 35);

    await db.mealPlanDao.markEaten(id);
    entry = (await db.mealPlanDao.getById(id))!;
    expect(entry.isEaten, isTrue);
    expect(entry.kcal, 650);
  });

  test('updateQuick rewrites name and macros; "Repetir de ayer" copies it', () async {
    final id = await db.mealPlanDao.addQuick(
      date: date,
      mealType: MealType.dinner,
      label: 'Tortilla',
      macros: macros,
      orderIndex: 0,
    );
    await db.mealPlanDao.updateQuick(
      id,
      label: 'Tortilla de patatas',
      macros: const FoodMacros(kcal: 400, proteinG: 14, carbsG: 30, fatG: 24),
    );

    final next = date.add(const Duration(days: 1));
    final copied = await db.mealPlanDao.copyMeal(
      fromDate: date,
      toDate: next,
      mealType: MealType.dinner,
      eaten: true,
    );
    expect(copied, 1);
    final copy = (await db.mealPlanDao.watchEntriesForDate(next).first).single;
    expect(copy.label, 'Tortilla de patatas');
    expect(copy.entry.kcal, 400);
    expect(copy.entry.fatG, 24);
  });
}
