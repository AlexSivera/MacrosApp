import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_theme.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/widgets/app_card.dart';
import '../../../data/database/database_provider.dart';
import '../providers/custom_lists_providers.dart';
import '../widgets/list_name_dialog.dart';

// Landing screen for the "Listas" tab: the weekly shopping list (still
// entirely owned by Plan semanal's data) plus any number of the user's own
// free-form checklists — tappers to take to uni, what's in the freezer,
// anything that isn't about buying groceries.
class ListasScreen extends ConsumerWidget {
  const ListasScreen({super.key});

  Future<void> _createList(BuildContext context, WidgetRef ref) async {
    final name = await promptForListName(context, title: 'Nueva lista');
    if (name == null || name.isEmpty) return;
    final id = await ref.read(appDatabaseProvider).customListsDao.createList(name);
    if (context.mounted) context.push('/listas/$id');
  }

  Future<void> _deleteList(BuildContext context, WidgetRef ref, int id, String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Borrar lista'),
        content: Text('Se borrará "$name" y todos sus elementos.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Borrar'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(appDatabaseProvider).customListsDao.deleteList(id);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final listsAsync = ref.watch(customListsProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Listas')),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.lg),
        children: [
          AppCard(
            padding: EdgeInsets.zero,
            child: InkWell(
              borderRadius: BorderRadius.circular(AppRadius.md),
              onTap: () => context.push('/listas/compra'),
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppTheme.tint(context),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.shopping_cart_outlined, size: 18, color: theme.colorScheme.primary),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Text('Lista de la compra', style: theme.textTheme.bodyLarge),
                    ),
                    Icon(Icons.chevron_right_rounded, color: theme.colorScheme.onSurfaceVariant),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Row(
            children: [
              Text('Tus listas', style: theme.textTheme.labelMedium),
              const Spacer(),
              IconButton(
                tooltip: 'Nueva lista',
                icon: const Icon(Icons.add_circle_outline),
                onPressed: () => _createList(context, ref),
              ),
            ],
          ),
          listsAsync.when(
            data: (lists) {
              if (lists.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: AppSpacing.lg),
                  child: Text(
                    'Crea listas propias para lo que quieras: tappers, lo que tienes '
                    'en el congelador... lo que necesites.',
                    style: theme.textTheme.bodyMedium,
                  ),
                );
              }
              return AppCard(
                padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
                child: Column(
                  children: [
                    for (var i = 0; i < lists.length; i++) ...[
                      InkWell(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                        onTap: () => context.push('/listas/${lists[i].id}'),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppSpacing.sm,
                            vertical: AppSpacing.sm,
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.checklist_rounded, color: theme.colorScheme.onSurfaceVariant),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(child: Text(lists[i].name, style: theme.textTheme.bodyLarge)),
                              IconButton(
                                icon: const Icon(Icons.delete_outline_rounded),
                                onPressed: () => _deleteList(context, ref, lists[i].id, lists[i].name),
                              ),
                            ],
                          ),
                        ),
                      ),
                      if (i != lists.length - 1)
                        Divider(
                          height: AppSpacing.xs,
                          color: theme.colorScheme.outline.withValues(alpha: 0.5),
                        ),
                    ],
                  ],
                ),
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
