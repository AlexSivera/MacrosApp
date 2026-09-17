import 'package:flutter/material.dart';

import '../theme/app_spacing.dart';
import 'app_card.dart';

// A free-text checklist: an "add" text field on top, then a card of
// checkbox + name + delete rows below. Shared by the shopping list's manual
// mode and every user-created list in "Listas" — both are the same shape
// (a name, a checked flag, no quantities), just backed by different tables.
class ChecklistItemData {
  const ChecklistItemData({required this.id, required this.name, required this.checked});

  final int id;
  final String name;
  final bool checked;
}

class EditableChecklist extends StatefulWidget {
  const EditableChecklist({
    super.key,
    required this.items,
    required this.onAdd,
    required this.onToggle,
    required this.onDelete,
    required this.hintText,
    required this.emptyText,
  });

  final List<ChecklistItemData> items;
  final ValueChanged<String> onAdd;
  final void Function(int id, bool checked) onToggle;
  final ValueChanged<int> onDelete;
  final String hintText;
  final String emptyText;

  @override
  State<EditableChecklist> createState() => _EditableChecklistState();
}

class _EditableChecklistState extends State<EditableChecklist> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final name = _controller.text.trim();
    if (name.isEmpty) return;
    widget.onAdd(name);
    _controller.clear();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _controller,
                  decoration: InputDecoration(hintText: widget.hintText),
                  onSubmitted: (_) => _submit(),
                ),
              ),
              const SizedBox(width: AppSpacing.xs),
              IconButton(icon: const Icon(Icons.add_circle_rounded), onPressed: _submit),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.sm),
        Expanded(
          child: widget.items.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Text(
                      widget.emptyText,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium,
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.fromLTRB(
                    AppSpacing.lg,
                    0,
                    AppSpacing.lg,
                    AppSpacing.lg,
                  ),
                  children: [
                    AppCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < widget.items.length; i++) ...[
                            _ChecklistTile(
                              item: widget.items[i],
                              onToggle: (checked) => widget.onToggle(widget.items[i].id, checked),
                              onDelete: () => widget.onDelete(widget.items[i].id),
                            ),
                            if (i != widget.items.length - 1)
                              Divider(
                                height: AppSpacing.md,
                                color: theme.colorScheme.outline.withValues(alpha: 0.5),
                              ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
        ),
      ],
    );
  }
}

class _ChecklistTile extends StatelessWidget {
  const _ChecklistTile({required this.item, required this.onToggle, required this.onDelete});

  final ChecklistItemData item;
  final ValueChanged<bool> onToggle;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => onToggle(!item.checked),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 2),
        child: Row(
          children: [
            Checkbox(value: item.checked, onChanged: (v) => onToggle(v ?? false)),
            const SizedBox(width: AppSpacing.xs),
            Expanded(
              child: Text(
                item.name,
                style: theme.textTheme.bodyLarge?.copyWith(
                  decoration: item.checked ? TextDecoration.lineThrough : null,
                  color: item.checked ? theme.colorScheme.onSurfaceVariant : null,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close_rounded),
              iconSize: 20,
              onPressed: onDelete,
            ),
          ],
        ),
      ),
    );
  }
}
