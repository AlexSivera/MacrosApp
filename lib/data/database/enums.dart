enum BiologicalSex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum GoalType { lose, maintain, gain }

enum CalorieTargetMode { automatic, manual }

enum WeightUnit { kg, lb }

enum FoodMassUnit { g, oz }

// New modes are appended last, not alphabetically, so a mode's stored index
// never collides with the indices already saved for existing users.
enum AppearanceMode { dark, light, system, pastel, green }

enum RecipeCategory { breakfast, lunch, dinner, snack }

// Mirrors the section headers already used to organize food_seed_data.dart,
// so seeding just tags each existing group instead of inventing a new taxonomy.
enum FoodCategory {
  fruta,
  verdura,
  cerealLegumbre,
  lacteo,
  carnePescado,
  huevo,
  frutoSecoSemilla,
  aceiteGrasa,
  panaderia,
  bebida,
  snackProcesado,
  proteinaVegetal,
  condimento,
  otros,
}

// Fixed 6-slot day, shown as Desayuno/Almuerzo/Comida/Merienda/Cena/Extra
// (see mealSectionOrder in core/constants/meal_types.dart for that display
// order). `snackMerienda` is the traditional Spanish afternoon snack;
// `snack` is the catch-all "Extra" slot for anything outside those five.
// `almuerzo` was appended last (not inserted alphabetically/by day order)
// so its stored index never collides with the indices already saved for
// existing users' diary/plan entries.
enum MealType { breakfast, lunch, snackMerienda, dinner, snack, almuerzo }

// `device`/`api` are unused today but keep the column meaningful once a
// wearable/health-API integration is added later, per the brief's request
// to leave that door open without building it now.
enum BurnedCalorieSource { manual, device, api }
