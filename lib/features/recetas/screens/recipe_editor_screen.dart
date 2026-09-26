import 'dart:typed_data';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/legacy_recipe_image.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/recipe_macros_calculator.dart';
import '../widgets/add_ingredient_sheet.dart';
import '../widgets/ingredient_builder_list.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/unit_input_decoration.dart';
import '../providers/recipes_providers.dart';

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
  final _instructions = TextEditingController();
  RecipeCategory _category = RecipeCategory.lunch;
  Uint8List? _imageBytes;
  // Only set when editing a pre-web recipe whose photo is still a legacy
  // file path with no imageBytes yet — kept only to preview it and to leave
  // it untouched on save if the user doesn't replace the photo.
  String? _legacyImagePath;
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
        _instructions.text = recipe.instructions ?? '';
        _category = recipe.category;
        _imageBytes = recipe.imageBytes;
        if (_imageBytes == null) _legacyImagePath = recipe.imagePath;
        final ingredients = await db.recipeIngredientsDao.getForRecipe(recipe.id);
        for (final ingredient in ingredients) {
          final food = await db.foodsDao.getById(ingredient.foodId);
          if (food != null) {
            _ingredients.add(IngredientDraft(food: food, grams: ingredient.grams));
          }
        }
      }
    }
    if (mounted) setState(() => _loading = false);
  }

  static String _formatNum(double v) => formatInputNumber(v);

  @override
  void dispose() {
    _name.dispose();
    _servings.dispose();
    _prepTime.dispose();
    _instructions.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final source = await showModalBottomSheet<ImageSource>(
      context: context,
      useRootNavigator: true,
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
    final bytes = await picked.readAsBytes();
    if (mounted) {
      setState(() {
        _imageBytes = bytes;
        _legacyImagePath = null;
      });
    }
  }

  Future<void> _persistRecipe({
    required String name,
    required double servings,
    required int? prepTime,
  }) async {
    final db = ref.read(appDatabaseProvider);
    final instructions = _instructions.text.trim().isEmpty ? null : _instructions.text.trim();
    int recipeId;
    if (widget.recipeId != null) {
      recipeId = widget.recipeId!;
      final existing = await db.recipesDao.getById(recipeId);
      await db.recipesDao.updateRecipe(
        (existing!.copyWith(
          name: name,
          imageBytes: Value(_imageBytes),
          // Only ever non-null here if the user didn't replace a legacy
          // file-path photo this session — otherwise _pickImage cleared it,
          // so this correctly wipes the stale path once imageBytes takes over.
          imagePath: Value(_legacyImagePath),
          category: _category,
          servings: servings,
          prepTimeMinutes: Value(prepTime),
          instructions: Value(instructions),
        )),
      );
    } else {
      recipeId = await db.recipesDao.insert(
        RecipesCompanion.insert(
          name: name,
          imageBytes: Value(_imageBytes),
          category: Value(_category),
          servings: Value(servings),
          prepTimeMinutes: Value(prepTime),
          instructions: Value(instructions),
        ),
      );
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

    await _persistRecipe(name: name, servings: servings, prepTime: int.tryParse(_prepTime.text));

    if (mounted) context.pop();
  }

  // Backing out with ingredients already added shouldn't throw that work
  // away — falls back to a placeholder name/1 ración instead of blocking on
  // the same validation _submit enforces, since there's no error UI to show
  // mid-navigation. Only reachable when _ingredients is non-empty (see the
  // PopScope's canPop below), so there's always something worth keeping.
  Future<void> _saveDraftOnBack() async {
    final name = _name.text.trim().isEmpty ? 'Receta sin nombre' : _name.text.trim();
    final enteredServings = double.tryParse(_servings.text.replaceAll(',', '.'));
    final servings = (enteredServings != null && enteredServings > 0) ? enteredServings : 1.0;
    await _persistRecipe(name: name, servings: servings, prepTime: int.tryParse(_prepTime.text));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    if (_loading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final imagePreview = _imageBytes != null
        ? Image.memory(_imageBytes!, fit: BoxFit.cover)
        : (_legacyImagePath != null ? legacyFileImage(_legacyImagePath!) : null);

    final servings = double.tryParse(_servings.text.replaceAll(',', '.'));
    final totals = computeRecipeTotals([
      for (final i in _ingredients)
        (RecipeIngredient(id: 0, recipeId: 0, foodId: i.food.id, grams: i.grams, orderIndex: 0), i.food),
    ]);
    final perServing = servings != null && servings > 0
        ? computePerServing(totals, servings)
        : FoodMacros.zero;

    return PopScope(
      // While _saving is true this is the submit button's own pop already
      // going through — let it fall through untouched instead of racing a
      // second save against it. Otherwise, once there's at least one
      // ingredient, back (app bar arrow or system gesture) saves a draft
      // instead of silently discarding it.
      canPop: _ingredients.isEmpty || _saving,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;
        await _saveDraftOnBack();
        if (context.mounted) Navigator.of(context).pop();
      },
      child: Scaffold(
        appBar: AppBar(title: Text(widget.recipeId != null ? 'Editar receta' : 'Nueva receta')),
        body: ListView(
          padding: const EdgeInsets.all(AppSpacing.lg),
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: AspectRatio(
                aspectRatio: 16 / 9,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Container(
                    color: theme.colorScheme.surfaceContainerHighest,
                    child: imagePreview != null
                        ? SizedBox.expand(child: imagePreview)
                        : Center(
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.add_a_photo_outlined, color: theme.colorScheme.onSurfaceVariant),
                                const SizedBox(height: AppSpacing.xs),
                                Text('Añadir imagen', style: theme.textTheme.bodySmall),
                              ],
                            ),
                          ),
                  ),
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
                    items: [
                      for (final category in RecipeCategory.values)
                        DropdownMenuItem(value: category, child: Text(category.label)),
                    ],
                    onChanged: (v) => setState(() => _category = v ?? _category),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _prepTime,
                    keyboardType: TextInputType.number,
                    decoration: unitInputDecoration(label: 'Tiempo', unit: 'min'),
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
            const SizedBox(height: AppSpacing.xl),
            TextField(
              controller: _instructions,
              minLines: 4,
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
              keyboardType: TextInputType.multiline,
              decoration: const InputDecoration(
                labelText: 'Preparación (opcional)',
                hintText: 'Un paso por línea',
                alignLabelWithHint: true,
              ),
            ),
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
      ),
    );
  }
}
