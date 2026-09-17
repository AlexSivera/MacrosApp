import 'package:drift/drift.dart';

// A user-named checklist with no connection to the meal plan — "Tappers",
// "Congelador", or anything else someone wants to track outside of grocery
// shopping. Lives in "Listas" alongside the weekly shopping list, but is
// otherwise completely independent of it.
class CustomLists extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get orderIndex => integer()();
}
