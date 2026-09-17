import 'package:flutter/material.dart';

// Shared by "crear lista nueva" (Listas) and "renombrar" (dentro de una
// lista) — same dialog either way, just a different title/confirm label and
// starting value.
Future<String?> promptForListName(
  BuildContext context, {
  required String title,
  String? initialValue,
  String confirmLabel = 'Crear',
}) {
  final controller = TextEditingController(text: initialValue);
  return showDialog<String>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: TextField(
        controller: controller,
        autofocus: true,
        decoration: const InputDecoration(hintText: 'p. ej. Tappers'),
        onSubmitted: (value) => Navigator.of(context).pop(value.trim()),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancelar')),
        TextButton(
          onPressed: () => Navigator.of(context).pop(controller.text.trim()),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}
