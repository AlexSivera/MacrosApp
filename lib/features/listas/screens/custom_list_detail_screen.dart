import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/widgets/editable_checklist.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../providers/custom_lists_providers.dart';
import '../widgets/list_name_dialog.dart';

class CustomListDetailScreen extends ConsumerWidget {
  const CustomListDetailScreen({super.key, required this.listId});

  final int listId;

  Future<void> _rename(BuildContext context, WidgetRef ref, String currentName) async {
    final name = await promptForListName(
      context,
      title: 'Renombrar lista',
      initialValue: currentName,
      confirmLabel: 'Guardar',
    );
    if (name == null || name.isEmpty) return;
    await ref.read(appDatabaseProvider).customListsDao.renameList(listId, name);
  }

  Future<void> _delete(BuildContext context, WidgetRef ref, String name) async {
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
      await ref.read(appDatabaseProvider).customListsDao.deleteList(listId);
      if (context.mounted) Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final lists = ref.watch(customListsProvider).valueOrNull;
    CustomList? list;
    for (final candidate in lists ?? const <CustomList>[]) {
      if (candidate.id == listId) {
        list = candidate;
        break;
      }
    }
    final itemsAsync = ref.watch(customListItemsProvider(listId));
    final db = ref.read(appDatabaseProvider);

    // The list was deleted (e.g. from another session) while this screen
    // was open — nothing sensible left to show here.
    if (lists != null && list == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (Navigator.of(context).canPop()) Navigator.of(context).pop();
      });
      return const Scaffold(body: SizedBox.shrink());
    }

    final currentList = list;
    return Scaffold(
      appBar: AppBar(
        title: Text(currentList?.name ?? ''),
        actions: [
          IconButton(
            tooltip: 'Renombrar',
            icon: const Icon(Icons.edit_outlined),
            onPressed:
                currentList == null ? null : () => _rename(context, ref, currentList.name),
          ),
          IconButton(
            tooltip: 'Borrar lista',
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed:
                currentList == null ? null : () => _delete(context, ref, currentList.name),
          ),
        ],
      ),
      body: itemsAsync.when(
        data: (items) => EditableChecklist(
          items: [
            for (final item in items)
              ChecklistItemData(id: item.id, name: item.name, checked: item.checked),
          ],
          hintText: 'Añadir elemento...',
          emptyText: 'Esta lista está vacía. Añade lo que necesites.',
          onAdd: (name) => db.customListsDao.addItem(listId, name),
          onToggle: (id, checked) => db.customListsDao.updateItem(id, checked: checked),
          onDelete: db.customListsDao.deleteItem,
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
