import 'package:flutter/material.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/legacy_recipe_image.dart';
import '../providers/recipes_providers.dart';

class RecipeCard extends StatelessWidget {
  const RecipeCard({super.key, required this.data, required this.onTap});

  final RecipeCardData data;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final recipe = data.recipe;
    final image = recipe.imageBytes != null
        ? Image.memory(recipe.imageBytes!, fit: BoxFit.cover)
        : (recipe.imagePath != null ? legacyFileImage(recipe.imagePath!) : null);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadius.md),
      onTap: onTap,
      child: AppCard(
        padding: EdgeInsets.zero,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            AspectRatio(
              aspectRatio: 16 / 10,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(AppRadius.md)),
                child: image != null
                    ? SizedBox.expand(child: image)
                    : Container(
                        color: theme.colorScheme.surfaceContainerHighest,
                        child: Icon(
                          Icons.restaurant_menu,
                          size: 36,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.md),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          recipe.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleMedium,
                        ),
                      ),
                      if (recipe.isFavorite)
                        const Icon(Icons.favorite, size: 16, color: AppTheme.accent),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    '${data.perServing.kcal.round()} kcal · '
                    'P${data.perServing.proteinG.round()} '
                    'C${data.perServing.carbsG.round()} '
                    'G${data.perServing.fatG.round()}',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.bodySmall,
                  ),
                  if (recipe.prepTimeMinutes != null) ...[
                    const SizedBox(height: AppSpacing.xs),
                    Row(
                      children: [
                        Icon(Icons.schedule, size: 14, color: theme.colorScheme.onSurfaceVariant),
                        const SizedBox(width: AppSpacing.xs),
                        Text('${recipe.prepTimeMinutes} min', style: theme.textTheme.bodySmall),
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
