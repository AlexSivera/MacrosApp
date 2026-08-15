import '../database/enums.dart';

// Curated starter set of common whole foods and staples, in Spanish, all
// values per 100g of the raw/typical form unless noted in the name. Synced
// into the local database on every launch by food_seeder.dart (only entries
// missing by name are inserted) — the app never depends on this list, or on
// any network call, at runtime otherwise. Users extend it freely via
// "Crear alimento personalizado" (isCustom = true on those rows).
class FoodSeed {
  const FoodSeed({
    required this.category,
    required this.name,
    required this.kcalPer100g,
    required this.proteinPer100g,
    required this.carbsPer100g,
    required this.fatPer100g,
    this.fiberPer100g,
    this.defaultServingGrams,
    this.servingLabel,
  });

  final FoodCategory category;
  final String name;
  final double kcalPer100g;
  final double proteinPer100g;
  final double carbsPer100g;
  final double fatPer100g;
  final double? fiberPer100g;
  final double? defaultServingGrams;
  final String? servingLabel;
}

const foodSeedData = <FoodSeed>[
  // Frutas
  FoodSeed(category: FoodCategory.fruta, name: 'Manzana', kcalPer100g: 52, proteinPer100g: 0.3, carbsPer100g: 14, fatPer100g: 0.2, fiberPer100g: 2.4, defaultServingGrams: 150, servingLabel: '1 manzana ≈ 150g'),
  FoodSeed(category: FoodCategory.fruta, name: 'Plátano', kcalPer100g: 89, proteinPer100g: 1.1, carbsPer100g: 23, fatPer100g: 0.3, fiberPer100g: 2.6, defaultServingGrams: 120, servingLabel: '1 plátano ≈ 120g'),
  FoodSeed(category: FoodCategory.fruta, name: 'Naranja', kcalPer100g: 47, proteinPer100g: 0.9, carbsPer100g: 12, fatPer100g: 0.1, fiberPer100g: 2.4, defaultServingGrams: 150, servingLabel: '1 naranja ≈ 150g'),
  FoodSeed(category: FoodCategory.fruta, name: 'Pera', kcalPer100g: 57, proteinPer100g: 0.4, carbsPer100g: 15, fatPer100g: 0.1, fiberPer100g: 3.1),
  FoodSeed(category: FoodCategory.fruta, name: 'Fresas', kcalPer100g: 32, proteinPer100g: 0.7, carbsPer100g: 7.7, fatPer100g: 0.3, fiberPer100g: 2.0),
  FoodSeed(category: FoodCategory.fruta, name: 'Uvas', kcalPer100g: 69, proteinPer100g: 0.7, carbsPer100g: 18, fatPer100g: 0.2, fiberPer100g: 0.9),
  FoodSeed(category: FoodCategory.fruta, name: 'Sandía', kcalPer100g: 30, proteinPer100g: 0.6, carbsPer100g: 7.6, fatPer100g: 0.2, fiberPer100g: 0.4),
  FoodSeed(category: FoodCategory.fruta, name: 'Melón', kcalPer100g: 34, proteinPer100g: 0.8, carbsPer100g: 8.2, fatPer100g: 0.2, fiberPer100g: 0.9),
  FoodSeed(category: FoodCategory.fruta, name: 'Piña', kcalPer100g: 50, proteinPer100g: 0.5, carbsPer100g: 13, fatPer100g: 0.1, fiberPer100g: 1.4),
  FoodSeed(category: FoodCategory.fruta, name: 'Mango', kcalPer100g: 60, proteinPer100g: 0.8, carbsPer100g: 15, fatPer100g: 0.4, fiberPer100g: 1.6),
  FoodSeed(category: FoodCategory.fruta, name: 'Kiwi', kcalPer100g: 61, proteinPer100g: 1.1, carbsPer100g: 15, fatPer100g: 0.5, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.fruta, name: 'Melocotón', kcalPer100g: 39, proteinPer100g: 0.9, carbsPer100g: 10, fatPer100g: 0.3, fiberPer100g: 1.5),
  FoodSeed(category: FoodCategory.fruta, name: 'Ciruela', kcalPer100g: 46, proteinPer100g: 0.7, carbsPer100g: 11, fatPer100g: 0.3, fiberPer100g: 1.4),
  FoodSeed(category: FoodCategory.fruta, name: 'Aguacate', kcalPer100g: 160, proteinPer100g: 2.0, carbsPer100g: 8.5, fatPer100g: 15, fiberPer100g: 6.7),
  FoodSeed(category: FoodCategory.fruta, name: 'Limón', kcalPer100g: 29, proteinPer100g: 1.1, carbsPer100g: 9.3, fatPer100g: 0.3, fiberPer100g: 2.8),
  FoodSeed(category: FoodCategory.fruta, name: 'Papaya', kcalPer100g: 43, proteinPer100g: 0.5, carbsPer100g: 11, fatPer100g: 0.3, fiberPer100g: 1.7),
  FoodSeed(category: FoodCategory.fruta, name: 'Frambuesas', kcalPer100g: 52, proteinPer100g: 1.2, carbsPer100g: 12, fatPer100g: 0.7, fiberPer100g: 6.5),
  FoodSeed(category: FoodCategory.fruta, name: 'Arándanos', kcalPer100g: 57, proteinPer100g: 0.7, carbsPer100g: 14, fatPer100g: 0.3, fiberPer100g: 2.4),
  FoodSeed(category: FoodCategory.fruta, name: 'Higos', kcalPer100g: 74, proteinPer100g: 0.8, carbsPer100g: 19, fatPer100g: 0.3, fiberPer100g: 2.9),
  FoodSeed(category: FoodCategory.fruta, name: 'Dátiles', kcalPer100g: 282, proteinPer100g: 2.5, carbsPer100g: 75, fatPer100g: 0.4, fiberPer100g: 8.0),
  FoodSeed(category: FoodCategory.fruta, name: 'Granada', kcalPer100g: 83, proteinPer100g: 1.7, carbsPer100g: 19, fatPer100g: 1.2, fiberPer100g: 4.0),

  // Verduras
  FoodSeed(category: FoodCategory.verdura, name: 'Tomate', kcalPer100g: 18, proteinPer100g: 0.9, carbsPer100g: 3.9, fatPer100g: 0.2, fiberPer100g: 1.2),
  FoodSeed(category: FoodCategory.verdura, name: 'Lechuga', kcalPer100g: 15, proteinPer100g: 1.4, carbsPer100g: 2.9, fatPer100g: 0.2, fiberPer100g: 1.3),
  FoodSeed(category: FoodCategory.verdura, name: 'Pepino', kcalPer100g: 15, proteinPer100g: 0.7, carbsPer100g: 3.6, fatPer100g: 0.1, fiberPer100g: 0.5),
  FoodSeed(category: FoodCategory.verdura, name: 'Zanahoria', kcalPer100g: 41, proteinPer100g: 0.9, carbsPer100g: 9.6, fatPer100g: 0.2, fiberPer100g: 2.8),
  FoodSeed(category: FoodCategory.verdura, name: 'Cebolla', kcalPer100g: 40, proteinPer100g: 1.1, carbsPer100g: 9.3, fatPer100g: 0.1, fiberPer100g: 1.7),
  FoodSeed(category: FoodCategory.verdura, name: 'Pimiento rojo', kcalPer100g: 31, proteinPer100g: 1.0, carbsPer100g: 6.0, fatPer100g: 0.3, fiberPer100g: 2.1),
  FoodSeed(category: FoodCategory.verdura, name: 'Brócoli', kcalPer100g: 34, proteinPer100g: 2.8, carbsPer100g: 6.6, fatPer100g: 0.4, fiberPer100g: 2.6),
  FoodSeed(category: FoodCategory.verdura, name: 'Espinacas', kcalPer100g: 23, proteinPer100g: 2.9, carbsPer100g: 3.6, fatPer100g: 0.4, fiberPer100g: 2.2),
  FoodSeed(category: FoodCategory.verdura, name: 'Calabacín', kcalPer100g: 17, proteinPer100g: 1.2, carbsPer100g: 3.1, fatPer100g: 0.3, fiberPer100g: 1.0),
  FoodSeed(category: FoodCategory.verdura, name: 'Berenjena', kcalPer100g: 25, proteinPer100g: 1.0, carbsPer100g: 5.9, fatPer100g: 0.2, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.verdura, name: 'Champiñones', kcalPer100g: 22, proteinPer100g: 3.1, carbsPer100g: 3.3, fatPer100g: 0.3, fiberPer100g: 1.0),
  FoodSeed(category: FoodCategory.verdura, name: 'Patata', kcalPer100g: 77, proteinPer100g: 2.0, carbsPer100g: 17, fatPer100g: 0.1, fiberPer100g: 2.2),
  FoodSeed(category: FoodCategory.verdura, name: 'Boniato', kcalPer100g: 86, proteinPer100g: 1.6, carbsPer100g: 20, fatPer100g: 0.1, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.verdura, name: 'Calabaza', kcalPer100g: 26, proteinPer100g: 1.0, carbsPer100g: 6.5, fatPer100g: 0.1, fiberPer100g: 0.5),
  FoodSeed(category: FoodCategory.verdura, name: 'Judías verdes', kcalPer100g: 31, proteinPer100g: 1.8, carbsPer100g: 7.0, fatPer100g: 0.2, fiberPer100g: 3.4),
  FoodSeed(category: FoodCategory.verdura, name: 'Guisantes', kcalPer100g: 81, proteinPer100g: 5.4, carbsPer100g: 14, fatPer100g: 0.4, fiberPer100g: 5.7),
  FoodSeed(category: FoodCategory.verdura, name: 'Espárragos', kcalPer100g: 20, proteinPer100g: 2.2, carbsPer100g: 3.9, fatPer100g: 0.1, fiberPer100g: 2.1),
  FoodSeed(category: FoodCategory.verdura, name: 'Apio', kcalPer100g: 16, proteinPer100g: 0.7, carbsPer100g: 3.0, fatPer100g: 0.2, fiberPer100g: 1.6),
  FoodSeed(category: FoodCategory.verdura, name: 'Col rizada (kale)', kcalPer100g: 49, proteinPer100g: 4.3, carbsPer100g: 9.0, fatPer100g: 0.9, fiberPer100g: 3.6),
  FoodSeed(category: FoodCategory.verdura, name: 'Repollo', kcalPer100g: 25, proteinPer100g: 1.3, carbsPer100g: 5.8, fatPer100g: 0.1, fiberPer100g: 2.5),
  FoodSeed(category: FoodCategory.verdura, name: 'Alcachofa', kcalPer100g: 47, proteinPer100g: 3.3, carbsPer100g: 10, fatPer100g: 0.2, fiberPer100g: 5.4),

  // Cereales y legumbres
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Arroz blanco (crudo)', kcalPer100g: 365, proteinPer100g: 7.1, carbsPer100g: 80, fatPer100g: 0.7, fiberPer100g: 1.3),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Arroz integral (crudo)', kcalPer100g: 362, proteinPer100g: 7.5, carbsPer100g: 76, fatPer100g: 2.7, fiberPer100g: 3.5),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Arroz basmati (crudo)', kcalPer100g: 350, proteinPer100g: 7.5, carbsPer100g: 78, fatPer100g: 0.6, fiberPer100g: 1.3),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Pasta (cruda)', kcalPer100g: 371, proteinPer100g: 13, carbsPer100g: 75, fatPer100g: 1.5, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Avena', kcalPer100g: 389, proteinPer100g: 17, carbsPer100g: 66, fatPer100g: 7.0, fiberPer100g: 10),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Pan blanco', kcalPer100g: 265, proteinPer100g: 9.0, carbsPer100g: 49, fatPer100g: 3.2, fiberPer100g: 2.7, defaultServingGrams: 30, servingLabel: '1 rebanada ≈ 30g'),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Pan integral', kcalPer100g: 247, proteinPer100g: 13, carbsPer100g: 41, fatPer100g: 3.4, fiberPer100g: 7.0, defaultServingGrams: 30, servingLabel: '1 rebanada ≈ 30g'),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Quinoa (cruda)', kcalPer100g: 368, proteinPer100g: 14, carbsPer100g: 64, fatPer100g: 6.1, fiberPer100g: 7.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Lentejas (crudas)', kcalPer100g: 353, proteinPer100g: 25, carbsPer100g: 60, fatPer100g: 1.1, fiberPer100g: 11),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Garbanzos (crudos)', kcalPer100g: 364, proteinPer100g: 19, carbsPer100g: 61, fatPer100g: 6.0, fiberPer100g: 17),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Judías pintas (crudas)', kcalPer100g: 347, proteinPer100g: 21, carbsPer100g: 62, fatPer100g: 1.2, fiberPer100g: 15),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Judías blancas (cocidas)', kcalPer100g: 127, proteinPer100g: 8.7, carbsPer100g: 23, fatPer100g: 0.5, fiberPer100g: 6.3),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Maíz', kcalPer100g: 86, proteinPer100g: 3.3, carbsPer100g: 19, fatPer100g: 1.4, fiberPer100g: 2.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Cuscús (crudo)', kcalPer100g: 376, proteinPer100g: 13, carbsPer100g: 77, fatPer100g: 0.6, fiberPer100g: 5.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Tortitas de maíz', kcalPer100g: 387, proteinPer100g: 8.2, carbsPer100g: 83, fatPer100g: 3.5, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Harina de trigo', kcalPer100g: 364, proteinPer100g: 10, carbsPer100g: 76, fatPer100g: 1.0, fiberPer100g: 2.7),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Copos de maíz (cereal)', kcalPer100g: 357, proteinPer100g: 7.5, carbsPer100g: 84, fatPer100g: 0.9, fiberPer100g: 3.0),
  FoodSeed(category: FoodCategory.cerealLegumbre, name: 'Muesli', kcalPer100g: 362, proteinPer100g: 10, carbsPer100g: 66, fatPer100g: 6.0, fiberPer100g: 8.0),

  // Lácteos
  FoodSeed(category: FoodCategory.lacteo, name: 'Leche entera', kcalPer100g: 61, proteinPer100g: 3.2, carbsPer100g: 4.8, fatPer100g: 3.3, defaultServingGrams: 200, servingLabel: '1 vaso ≈ 200ml'),
  FoodSeed(category: FoodCategory.lacteo, name: 'Leche desnatada', kcalPer100g: 34, proteinPer100g: 3.4, carbsPer100g: 5.0, fatPer100g: 0.1, defaultServingGrams: 200, servingLabel: '1 vaso ≈ 200ml'),
  FoodSeed(category: FoodCategory.lacteo, name: 'Yogur natural', kcalPer100g: 61, proteinPer100g: 3.5, carbsPer100g: 4.7, fatPer100g: 3.3, defaultServingGrams: 125, servingLabel: '1 yogur ≈ 125g'),
  FoodSeed(category: FoodCategory.lacteo, name: 'Yogur griego', kcalPer100g: 97, proteinPer100g: 9.0, carbsPer100g: 3.9, fatPer100g: 5.0, defaultServingGrams: 125, servingLabel: '1 yogur ≈ 125g'),
  FoodSeed(category: FoodCategory.lacteo, name: 'Queso fresco batido', kcalPer100g: 74, proteinPer100g: 9.0, carbsPer100g: 4.0, fatPer100g: 2.0),
  FoodSeed(category: FoodCategory.lacteo, name: 'Queso cheddar', kcalPer100g: 402, proteinPer100g: 25, carbsPer100g: 1.3, fatPer100g: 33),
  FoodSeed(category: FoodCategory.lacteo, name: 'Queso mozzarella', kcalPer100g: 280, proteinPer100g: 22, carbsPer100g: 2.2, fatPer100g: 21),
  FoodSeed(category: FoodCategory.lacteo, name: 'Queso parmesano', kcalPer100g: 392, proteinPer100g: 35, carbsPer100g: 3.2, fatPer100g: 26),
  FoodSeed(category: FoodCategory.lacteo, name: 'Requesón', kcalPer100g: 98, proteinPer100g: 11, carbsPer100g: 3.4, fatPer100g: 4.3),
  FoodSeed(category: FoodCategory.lacteo, name: 'Nata para cocinar', kcalPer100g: 292, proteinPer100g: 2.2, carbsPer100g: 3.0, fatPer100g: 30),
  FoodSeed(category: FoodCategory.lacteo, name: 'Mantequilla', kcalPer100g: 717, proteinPer100g: 0.9, carbsPer100g: 0.1, fatPer100g: 81),
  FoodSeed(category: FoodCategory.lacteo, name: 'Leche de almendras', kcalPer100g: 24, proteinPer100g: 0.6, carbsPer100g: 2.5, fatPer100g: 1.5),
  FoodSeed(category: FoodCategory.lacteo, name: 'Leche de soja', kcalPer100g: 33, proteinPer100g: 3.3, carbsPer100g: 1.8, fatPer100g: 1.8),
  FoodSeed(category: FoodCategory.lacteo, name: 'Leche de avena', kcalPer100g: 47, proteinPer100g: 1.0, carbsPer100g: 6.7, fatPer100g: 1.5),

  // Carnes y pescados
  FoodSeed(category: FoodCategory.carnePescado, name: 'Pechuga de pollo', kcalPer100g: 165, proteinPer100g: 31, carbsPer100g: 0, fatPer100g: 3.6),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Muslo de pollo', kcalPer100g: 209, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 11),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Pechuga de pavo', kcalPer100g: 135, proteinPer100g: 30, carbsPer100g: 0, fatPer100g: 1.0),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Ternera magra', kcalPer100g: 172, proteinPer100g: 27, carbsPer100g: 0, fatPer100g: 6.5),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Solomillo de cerdo', kcalPer100g: 143, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 3.5),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Salmón', kcalPer100g: 208, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 13),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Atún fresco', kcalPer100g: 144, proteinPer100g: 23, carbsPer100g: 0, fatPer100g: 4.9),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Atún en lata (al natural)', kcalPer100g: 116, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 1.0),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Merluza', kcalPer100g: 86, proteinPer100g: 18, carbsPer100g: 0, fatPer100g: 1.3),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Gambas', kcalPer100g: 99, proteinPer100g: 24, carbsPer100g: 0.2, fatPer100g: 0.3),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Bacalao', kcalPer100g: 82, proteinPer100g: 18, carbsPer100g: 0, fatPer100g: 0.7),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Sardinas', kcalPer100g: 208, proteinPer100g: 25, carbsPer100g: 0, fatPer100g: 11),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Jamón cocido', kcalPer100g: 113, proteinPer100g: 18, carbsPer100g: 1.5, fatPer100g: 4.0),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Jamón serrano', kcalPer100g: 241, proteinPer100g: 31, carbsPer100g: 0.4, fatPer100g: 13),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Lomo embutido', kcalPer100g: 242, proteinPer100g: 30, carbsPer100g: 1.0, fatPer100g: 13),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Chorizo', kcalPer100g: 455, proteinPer100g: 24, carbsPer100g: 1.9, fatPer100g: 38),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Carne picada de ternera', kcalPer100g: 250, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 16),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Carne picada de pollo', kcalPer100g: 143, proteinPer100g: 20, carbsPer100g: 0, fatPer100g: 7.0),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Panceta', kcalPer100g: 541, proteinPer100g: 9.3, carbsPer100g: 1.4, fatPer100g: 55),
  FoodSeed(category: FoodCategory.carnePescado, name: 'Conejo', kcalPer100g: 173, proteinPer100g: 33, carbsPer100g: 0, fatPer100g: 3.5),

  // Huevos
  FoodSeed(category: FoodCategory.huevo, name: 'Huevo entero', kcalPer100g: 155, proteinPer100g: 13, carbsPer100g: 1.1, fatPer100g: 11, defaultServingGrams: 50, servingLabel: '1 huevo ≈ 50g'),
  FoodSeed(category: FoodCategory.huevo, name: 'Clara de huevo', kcalPer100g: 52, proteinPer100g: 11, carbsPer100g: 0.7, fatPer100g: 0.2, defaultServingGrams: 33, servingLabel: '1 clara ≈ 33g'),
  FoodSeed(category: FoodCategory.huevo, name: 'Yema de huevo', kcalPer100g: 322, proteinPer100g: 16, carbsPer100g: 3.6, fatPer100g: 27, defaultServingGrams: 17, servingLabel: '1 yema ≈ 17g'),

  // Frutos secos y semillas
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Almendras', kcalPer100g: 579, proteinPer100g: 21, carbsPer100g: 22, fatPer100g: 50, fiberPer100g: 12.5),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Nueces', kcalPer100g: 654, proteinPer100g: 15, carbsPer100g: 14, fatPer100g: 65, fiberPer100g: 6.7),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Anacardos', kcalPer100g: 553, proteinPer100g: 18, carbsPer100g: 30, fatPer100g: 44, fiberPer100g: 3.3),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Cacahuetes', kcalPer100g: 567, proteinPer100g: 26, carbsPer100g: 16, fatPer100g: 49, fiberPer100g: 8.5),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Pistachos', kcalPer100g: 560, proteinPer100g: 20, carbsPer100g: 28, fatPer100g: 45, fiberPer100g: 10),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Avellanas', kcalPer100g: 628, proteinPer100g: 15, carbsPer100g: 17, fatPer100g: 61, fiberPer100g: 9.7),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Semillas de chía', kcalPer100g: 486, proteinPer100g: 17, carbsPer100g: 42, fatPer100g: 31, fiberPer100g: 34),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Semillas de lino', kcalPer100g: 534, proteinPer100g: 18, carbsPer100g: 29, fatPer100g: 42, fiberPer100g: 27),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Semillas de calabaza', kcalPer100g: 559, proteinPer100g: 30, carbsPer100g: 11, fatPer100g: 49, fiberPer100g: 6.0),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Semillas de girasol', kcalPer100g: 584, proteinPer100g: 21, carbsPer100g: 20, fatPer100g: 51, fiberPer100g: 8.6),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Crema de cacahuete', kcalPer100g: 588, proteinPer100g: 25, carbsPer100g: 20, fatPer100g: 50, fiberPer100g: 6.0),
  FoodSeed(category: FoodCategory.frutoSecoSemilla, name: 'Coco rallado', kcalPer100g: 660, proteinPer100g: 6.9, carbsPer100g: 24, fatPer100g: 65, fiberPer100g: 16),

  // Aceites y grasas
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Aceite de oliva', kcalPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, defaultServingGrams: 10, servingLabel: '1 cucharada ≈ 10g'),
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Aceite de girasol', kcalPer100g: 884, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, defaultServingGrams: 10, servingLabel: '1 cucharada ≈ 10g'),
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Aceite de coco', kcalPer100g: 862, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100, defaultServingGrams: 10, servingLabel: '1 cucharada ≈ 10g'),
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Margarina', kcalPer100g: 717, proteinPer100g: 0.2, carbsPer100g: 0.9, fatPer100g: 80),
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Manteca', kcalPer100g: 897, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 100),
  FoodSeed(category: FoodCategory.aceiteGrasa, name: 'Mayonesa', kcalPer100g: 680, proteinPer100g: 1.1, carbsPer100g: 1.6, fatPer100g: 75),

  // Panadería
  FoodSeed(category: FoodCategory.panaderia, name: 'Pan de hamburguesa', kcalPer100g: 280, proteinPer100g: 9.0, carbsPer100g: 50, fatPer100g: 5.0),
  FoodSeed(category: FoodCategory.panaderia, name: 'Pan de pita', kcalPer100g: 275, proteinPer100g: 9.0, carbsPer100g: 55, fatPer100g: 1.2),
  FoodSeed(category: FoodCategory.panaderia, name: 'Croissant', kcalPer100g: 406, proteinPer100g: 8.2, carbsPer100g: 46, fatPer100g: 21),
  FoodSeed(category: FoodCategory.panaderia, name: 'Bizcocho casero', kcalPer100g: 371, proteinPer100g: 6.0, carbsPer100g: 52, fatPer100g: 15),
  FoodSeed(category: FoodCategory.panaderia, name: 'Galletas María', kcalPer100g: 436, proteinPer100g: 7.5, carbsPer100g: 75, fatPer100g: 12),
  FoodSeed(category: FoodCategory.panaderia, name: 'Galletas de chocolate', kcalPer100g: 480, proteinPer100g: 5.5, carbsPer100g: 63, fatPer100g: 23),
  FoodSeed(category: FoodCategory.panaderia, name: 'Magdalenas', kcalPer100g: 396, proteinPer100g: 6.0, carbsPer100g: 52, fatPer100g: 18),
  FoodSeed(category: FoodCategory.panaderia, name: 'Tortita (crepe)', kcalPer100g: 227, proteinPer100g: 6.4, carbsPer100g: 28, fatPer100g: 9.7),
  FoodSeed(category: FoodCategory.panaderia, name: 'Pan baguette', kcalPer100g: 274, proteinPer100g: 9.0, carbsPer100g: 55, fatPer100g: 1.5),
  FoodSeed(category: FoodCategory.panaderia, name: 'Pan integral de centeno', kcalPer100g: 219, proteinPer100g: 8.5, carbsPer100g: 43, fatPer100g: 1.1, fiberPer100g: 5.8),

  // Bebidas
  FoodSeed(category: FoodCategory.bebida, name: 'Zumo de naranja', kcalPer100g: 45, proteinPer100g: 0.7, carbsPer100g: 10, fatPer100g: 0.2),
  FoodSeed(category: FoodCategory.bebida, name: 'Refresco de cola', kcalPer100g: 42, proteinPer100g: 0, carbsPer100g: 10.6, fatPer100g: 0),
  FoodSeed(category: FoodCategory.bebida, name: 'Cerveza', kcalPer100g: 43, proteinPer100g: 0.5, carbsPer100g: 3.6, fatPer100g: 0),
  FoodSeed(category: FoodCategory.bebida, name: 'Vino tinto', kcalPer100g: 85, proteinPer100g: 0.1, carbsPer100g: 2.6, fatPer100g: 0),
  FoodSeed(category: FoodCategory.bebida, name: 'Café solo', kcalPer100g: 1, proteinPer100g: 0.1, carbsPer100g: 0, fatPer100g: 0),
  FoodSeed(category: FoodCategory.bebida, name: 'Leche con cacao', kcalPer100g: 83, proteinPer100g: 3.3, carbsPer100g: 12, fatPer100g: 2.5),
  FoodSeed(category: FoodCategory.bebida, name: 'Bebida isotónica', kcalPer100g: 24, proteinPer100g: 0, carbsPer100g: 6.0, fatPer100g: 0),
  FoodSeed(category: FoodCategory.bebida, name: 'Batido de proteínas (polvo)', kcalPer100g: 380, proteinPer100g: 75, carbsPer100g: 8.0, fatPer100g: 6.0, defaultServingGrams: 30, servingLabel: '1 cacito ≈ 30g'),
  FoodSeed(category: FoodCategory.bebida, name: 'Agua de coco', kcalPer100g: 19, proteinPer100g: 0.7, carbsPer100g: 3.7, fatPer100g: 0.2),
  FoodSeed(category: FoodCategory.bebida, name: 'Zumo de manzana', kcalPer100g: 46, proteinPer100g: 0.1, carbsPer100g: 11, fatPer100g: 0.1),

  // Snacks y procesados básicos
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Patatas fritas (bolsa)', kcalPer100g: 536, proteinPer100g: 6.6, carbsPer100g: 53, fatPer100g: 34),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Palomitas', kcalPer100g: 375, proteinPer100g: 11, carbsPer100g: 74, fatPer100g: 4.3),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Chocolate negro 70%', kcalPer100g: 598, proteinPer100g: 7.8, carbsPer100g: 45, fatPer100g: 42),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Chocolate con leche', kcalPer100g: 535, proteinPer100g: 7.7, carbsPer100g: 59, fatPer100g: 30),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Barrita de cereales', kcalPer100g: 403, proteinPer100g: 6.0, carbsPer100g: 68, fatPer100g: 12),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Helado de vainilla', kcalPer100g: 207, proteinPer100g: 3.5, carbsPer100g: 24, fatPer100g: 11),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Pizza margarita', kcalPer100g: 266, proteinPer100g: 11, carbsPer100g: 33, fatPer100g: 10),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Hamburguesa (100% carne, sin pan)', kcalPer100g: 254, proteinPer100g: 26, carbsPer100g: 0, fatPer100g: 17),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Nuggets de pollo', kcalPer100g: 296, proteinPer100g: 15, carbsPer100g: 15, fatPer100g: 19),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Patatas fritas (caseras horneadas)', kcalPer100g: 167, proteinPer100g: 3.4, carbsPer100g: 27, fatPer100g: 5.0),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Hummus', kcalPer100g: 166, proteinPer100g: 8.0, carbsPer100g: 14, fatPer100g: 9.6),
  FoodSeed(category: FoodCategory.snackProcesado, name: 'Guacamole', kcalPer100g: 150, proteinPer100g: 2.0, carbsPer100g: 8.5, fatPer100g: 13),

  // Proteínas vegetales
  FoodSeed(category: FoodCategory.proteinaVegetal, name: 'Tofu', kcalPer100g: 76, proteinPer100g: 8.0, carbsPer100g: 1.9, fatPer100g: 4.8),
  FoodSeed(category: FoodCategory.proteinaVegetal, name: 'Tempeh', kcalPer100g: 193, proteinPer100g: 19, carbsPer100g: 9.4, fatPer100g: 11),
  FoodSeed(category: FoodCategory.proteinaVegetal, name: 'Seitán', kcalPer100g: 370, proteinPer100g: 75, carbsPer100g: 14, fatPer100g: 1.9),
  FoodSeed(category: FoodCategory.proteinaVegetal, name: 'Edamame', kcalPer100g: 122, proteinPer100g: 11, carbsPer100g: 9.9, fatPer100g: 5.2, fiberPer100g: 5.2),

  // Condimentos
  FoodSeed(category: FoodCategory.condimento, name: 'Salsa de tomate (ketchup)', kcalPer100g: 112, proteinPer100g: 1.7, carbsPer100g: 26, fatPer100g: 0.2),
  FoodSeed(category: FoodCategory.condimento, name: 'Mostaza', kcalPer100g: 66, proteinPer100g: 4.4, carbsPer100g: 5.8, fatPer100g: 3.3),
  FoodSeed(category: FoodCategory.condimento, name: 'Salsa de soja', kcalPer100g: 53, proteinPer100g: 8.1, carbsPer100g: 4.9, fatPer100g: 0.1),
  FoodSeed(category: FoodCategory.condimento, name: 'Vinagre', kcalPer100g: 18, proteinPer100g: 0, carbsPer100g: 0.4, fatPer100g: 0),
  FoodSeed(category: FoodCategory.condimento, name: 'Sal', kcalPer100g: 0, proteinPer100g: 0, carbsPer100g: 0, fatPer100g: 0),
  FoodSeed(category: FoodCategory.condimento, name: 'Azúcar blanco', kcalPer100g: 387, proteinPer100g: 0, carbsPer100g: 100, fatPer100g: 0),
  FoodSeed(category: FoodCategory.condimento, name: 'Miel', kcalPer100g: 304, proteinPer100g: 0.3, carbsPer100g: 82, fatPer100g: 0),
  FoodSeed(category: FoodCategory.condimento, name: 'Mermelada', kcalPer100g: 250, proteinPer100g: 0.4, carbsPer100g: 62, fatPer100g: 0.1),
];
