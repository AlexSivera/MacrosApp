import 'package:drift/drift.dart';

// A free-text shopping list line for a given week, used only when that
// week's mode is manual (see ShoppingListWeekModes) — no foodId/grams, since
// the whole point of manual mode is buying only what you actually need
// without the plan's full ingredient breakdown getting in the way.
class ShoppingListManualItems extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get weekStart => dateTime()();
  TextColumn get name => text()();
  BoolColumn get checked => boolean().withDefault(const Constant(false))();
  IntColumn get orderIndex => integer()();
}

// One row per week that has ever been switched to manual mode; a week with
// no row here is automatic (the default). Keeps whether each week is
// automatic/manual independent of whatever manual items it holds, so
// toggling back and forth never loses either the automatic aggregation or
// the manually-typed list.
class ShoppingListWeekModes extends Table {
  DateTimeColumn get weekStart => dateTime()();
  BoolColumn get manual => boolean().withDefault(const Constant(false))();

  @override
  Set<Column> get primaryKey => {weekStart};
}
