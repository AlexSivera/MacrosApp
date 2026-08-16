import 'dart:io';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';
import '../widgets/add_ingredient_sheet.dart';
import '../widgets/ingredient_builder_list.dart';

// Handles both "+ Crear receta" (recipeId == null) and "Editar" (recipeId
// set) — the brief asks for both flows to share the same fast
// name→imagen→ingredientes→raciones→guardar shape, so one screen covers both.
class RecipeEditorScreen extends ConsumerStatefulWidget {
  const RecipeEditorScreen({super.key, this.recipeId});

  final int? recipeId;

  @override
  ConsumerState<RecipeEditorScreen> createState() => _RecipeEditorScreenState();
}

class _RecipeEditorScreenState extends ConsumerState<RecipeEditorScreen> {
  final _name = TextEditingController();
  final _servings = TextEditingController(text: '1');
  final _prepTime = TextEditingController();
  RecipeCategory _category = RecipeCategory.lunch;
  String? _imagePath;
  final List<IngredientDraft> _ingredients = [];
  bool _loading = true;
  bool _saving = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    if (widget.recipeId != null) {
      final db = ref.read(appDatabaseProvider);
      final recipe = await db.recipesDao.getById(widget.recipeId!);
      if (recipe != null) {
        _name.text = recipe.name;
        _servings.text = _formatNum(recipe.servings);
        _prepTime.text = recipe.prepTimeMinutes?.toString() ?? '';
        _category = recipe.category;
        _imagePath = recipe.imagePath;
        final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
        for (final ingredient in ingredients) {
          final food = await db.foodsDao.getById(ingredient.foodId);
          if (food != null) _ingredients.add(IngredientDraft(food: food, grams: ingredient.grams));
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  static String _formatNum(double v) => v == v.roundToDouble() ? v.round().toString() : v.toString();

  @override
  void dispose() {
    _name.dispose();
    _servings.dispose();
    _prepTime.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.photo_camera_outlined),
              title: const Text('Hacer foto'),
              onTap: () => Navigator.of(context).pop(ImageSource.camera),
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_outlined),
              title: const Text('Elegir de la galería'),
              onTap: () => Navigator.of(context).pop(ImageSource.gallery),
            ),
          ],
        ),
      ),
    );
    if (source == null) return;

    final picked = await ImagePicker().pickImage(source: source, imageQuality: 85);
    if (picked == null) return;
    final dir = await getApplicationDocumentsDirectory();
    final fileName = 'recipe_${DateTime.now().microsecondsSinceEpoch}${p.extension(picked.path)}';
    final saved = await File(picked.path).copy(p.join(dir.path, fileName));
    if (mounted) setState(() => _imagePath = saved.path);
  }

  Future<void> _submit() async {
    final name = _name.text.trim();
    final servings = double.tryParse(_servings.text.replaceAll(',', '.'));

    if (name.isEmpty) {
      setState(() => _error = 'Ponle un nombre a la receta.');
      return;
    }
    if (servings == null || servings <= 0) {
      setState(() => _error = 'El número de raciones debe ser mayor que 0.');
      return;
    }
    if (_ingredients.isEmpty) {
      setState(() => _error = 'Añade al menos un ingrediente.');
      return;
    }

    setState(() {
      _saving = true;
      _error = null;
    });

    final db = ref.read(appDatabaseProvider);
    final prepTime = int.tryParse(_prepTime.text);
    int recipeId;
    if (widget.recipeId != null) {
      recipeId = widget.recipeId!;
      final existing = await db.recipesDao.getById(recipeId);
      await db.recipesDao.updateRecipe((existing!.copyWith(
        name: name,
        imagePath: Value(_imagePath),
        category: _category,
        servings: servings,
        prepTimeMinutes: Value(prepTime),
      )));
    } else {
      recipeId = await db.recipesDao.insert(RecipesCompanion.insert(
        name: name,
        imagePath: Value(_imagePath),
        category: Value(_category),
        servings: Value(servings),
        prepTimeMinutes: Value(prepTime),
      ));
    }

    var orderIndex = 0;
    await db.recipeIngredientsDao.replaceIngredients(recipeId, [
      for (final ingredient in _ingredients)
        RecipeIngredientsCompanion.insert(
          recipeId: recipeId,
          foodId: ingredient.food.id,
          grams: ingredient.grams,
          orderIndex: orderIndex++,
        ),
    ]);

    if (mounted) context.pop();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final servings = double.tryParse(_servings.text.replaceAll(',', '.'));
    final totals = computeRecipeTotals([for (final i in _ingredients) (
          RecipeIngredient(id: 0, recipeId: 0, foodId: i.food.id, grams: i.grams, orderIndex: 0),
          i.food,
        )]);
    final perServing =
        servings != null && servings > 0 ? computePerServing(totals, servings) : FoodMacros.zero;

    return Scaffold(
      appBar: AppBar(title: Text(widget.recipeId != null ? 'Editar receta' : 'Nueva receta')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          GestureDetector(
            onTap: _pickImage,
            child: AspectRatio(
              aspectRatio: 16 / 9,
              child: Container(
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  image: _imagePath != null
                      ? DecorationImage(image: FileImage(File(_imagePath!)), fit: BoxFit.cover)
                      : null,
                ),
                child: _imagePath == null
                    ? Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.onSurfaceVariant),
                            const SizedBox(height: AppSpacing.xs),
                            Text('Añadir imagen', style: theme.textTheme.bodySmall),
                          ],
                        ),
                      )
                    : null,
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          TextField(
            controller: _name,
            decoration: const InputDecoration(labelText: 'Nombre'),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: DropdownButtonFormField<RecipeCategory>(
                  initialValue: _category,
                  decoration: const InputDecoration(labelText: 'Categoría'),
                  items: const [
                    DropdownMenuItem(value: RecipeCategory.breakfast, child: Text('Desayuno')),
                    DropdownMenuItem(value: RecipeCategory.lunch, child: Text('Comida')),
                    DropdownMenuItem(value: RecipeCategory.dinner, child: Text('Cena')),
                    DropdownMenuItem(value: RecipeCategory.snack, child: Text('Snack')),
                  ],
                  onChanged: (v) => setState(() => _category = v ?? _category),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: TextField(
                  controller: _prepTime,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Minutos'),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _servings,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(labelText: 'Raciones'),
            onChanged: (_) => setState(() {}),
          ),
          const SizedBox(height: AppSpacing.xl),
          IngredientBuilderList(
            ingredients: _ingredients,
            onAdd: (draft) => setState(() => _ingredients.add(draft)),
            onRemove: (index) => setState(() => _ingredients.removeAt(index)),
          ),
          if (_ingredients.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.xl),
            AppCard(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Receta completa', style: theme.textTheme.labelMedium),
                  Text(
                    '${totals.kcal.round()} kcal · P${totals.proteinG.round()} '
                    'C${totals.carbsG.round()} G${totals.fatG.round()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Por ración', style: theme.textTheme.labelMedium),
                  Text(
                    '${perServing.kcal.round()} kcal · P${perServing.proteinG.round()} '
                    'C${perServing.carbsG.round()} G${perServing.fatG.round()}',
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ],
          if (_error != null) ...[
            const SizedBox(height: AppSpacing.md),
            Text(_error!, style: TextStyle(color: theme.colorScheme.error)),
          ],
          const SizedBox(height: AppSpacing.xl),
          ElevatedButton(
            onPressed: _saving ? null : _submit,
            child: _saving
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2))
                : const Text('Guardar receta'),
          ),
        ],
      ),
    );
  }
}
