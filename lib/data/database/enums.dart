enum BiologicalSex { male, female }

enum ActivityLevel { sedentary, light, moderate, active, veryActive }

enum GoalType { lose, maintain, gain }

enum CalorieTargetMode { automatic, manual }

enum WeightUnit { kg, lb }

enum FoodMassUnit { g, oz }

enum AppearanceMode { dark, light, system }

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

// Fixed 5-slot day. `snackMerienda` is the traditional Spanish afternoon
// snack shown in the Diario's meal sections; `snack` is a second, optional
// slot offered only from the "Añadir al Diario" meal picker so both of the
// brief's two meal-list mockups (4 sections vs. 5 picker options) are
// satisfied without ambiguity.
enum MealType { breakfast, lunch, snackMerienda, dinner, snack }

// `device`/`api` are unused today but keep the column meaningful once a
// wearable/health-API integration is added later, per the brief's request
// to leave that door open without building it now.
enum BurnedCalorieSource { manual, device, api }
