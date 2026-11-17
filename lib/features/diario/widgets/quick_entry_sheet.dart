import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/meal_types.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/widgets/macro_preview_row.dart';
import '../../../core/widgets/unit_input_decoration.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/nutrition_engine/food_macros_calculator.dart';
import '../../../services/nutrition_engine/macro_text_parser.dart';
import '../../../services/nutrition_engine/meal_plan_macros_calculator.dart';
import '../../plan_semanal/widgets/added_entry_snack_bar.dart';

const quickEntryDefaultLabel = 'Entrada rápida';

// "Entrada rápida": logs a dish by its kcal/macros alone, for food that
// can't be weighed or broken into ingredients — someone else cooked it, a
// restaurant plate... The usual source is an estimate (a photo sent to
// ChatGPT), so the sheet can copy a ready-made question and read the
// answer straight back from the clipboard.
class QuickEntrySheet extends ConsumerStatefulWidget {
  const QuickEntrySheet({super.key, this.date, this.mealType, this.entry, this.eaten = true});

  final DateTime? date;
  final MealType? mealType;
  final MealPlanEntry? entry;
  final bool eaten;

  static Future<void> showAdd(
    BuildContext context, {
    required DateTime date,
    required MealType mealType,
    bool eaten = true,
  }) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => QuickEntrySheet(date: date, mealType: mealType, eaten: eaten),
    );
  }

  static Future<void> showEdit(BuildContext context, {required MealPlanEntry entry}) {
    return showModalBottomSheet<void>(
      context: context,
      useRootNavigator: true,
      isScrollControlled: true,
      builder: (context) => QuickEntrySheet(entry: entry),
    );
  }

  @override
  ConsumerState<QuickEntrySheet> createState() => _QuickEntrySheetState();
}

class _QuickEntrySheetState extends ConsumerState<QuickEntrySheet> {
  late final TextEditingController _name;
  late final TextEditingController _kcal;
  late final TextEditingController _protein;
  late final TextEditingController _carbs;
  late final TextEditingController _fat;
  String? _error;

  // Feedback for the copy/paste buttons, shown inline: a SnackBar would
  // land behind this sheet.
  String? _clipboardNote;

  @override
  void initState() {
    super.initState();
    final entry = widget.entry;
    String prefill(double? v) => v == null ? '' : formatInputNumber(v);
    final label = entry?.labelSnapshot;
    _name = TextEditingController(text: label == quickEntryDefaultLabel ? '' : label ?? '');
    _kcal = TextEditingController(text: prefill(entry?.kcal));
    _protein = TextEditingController(text: prefill(entry?.proteinG));
    _carbs = TextEditingController(text: prefill(entry?.carbsG));
    _fat = TextEditingController(text: prefill(entry?.fatG));
  }

  @override
  void dispose() {
    for (final c in [_name, _kcal, _protein, _carbs, _fat]) {
      c.dispose();
    }
    super.dispose();
  }

  double? _read(TextEditingController c) {
    final v = parseDecimal(c.text);
    return v != null && v >= 0 ? v : null;
  }

  // Typed kcal wins; otherwise estimated from whatever macros are filled.
  double? get _macroKcal {
    final p = _read(_protein), c = _read(_carbs), f = _read(_fat);
    if (p == null && c == null && f == null) return null;
    return kcalFromMacros(proteinG: p ?? 0, carbsG: c ?? 0, fatG: f ?? 0);
  }

  FoodMacros? get _macros {
    final kcal = _read(_kcal) ?? _macroKcal;
    if (kcal == null || kcal <= 0) return null;
    return FoodMacros(
      kcal: kcal,
      proteinG: _read(_protein) ?? 0,
      carbsG: _read(_carbs) ?? 0,
      fatG: _read(_fat) ?? 0,
    );
  }

  Future<void> _copyPrompt() async {
    await Clipboard.setData(const ClipboardData(text: chatGptMacrosPrompt));
    if (!mounted) return;
    setState(() => _clipboardNote = 'Pregunta copiada. Pégala en ChatGPT junto a la foto.');
  }

  Future<void> _pasteAnswer() async {
    String? text;
    try {
      text = (await Clipboard.getData(Clipboard.kTextPlain))?.text;
    } catch (_) {
      text = null;
    }
    if (!mounted) return;
    final parsed = text == null ? null : parseMacrosFromText(text);
    if (parsed == null || parsed.isEmpty) {
      setState(() => _clipboardNote =
          'No he encontrado macros en el portapapeles. Copia la respuesta de ChatGPT y vuelve a pulsar.');
      return;
    }
    void fill(TextEditingController c, double? v) {
      if (v != null) c.text = formatInputNumber(v.roundToDouble());
    }

    setState(() {
      fill(_kcal, parsed.kcal);
      fill(_protein, parsed.proteinG);
      fill(_carbs, parsed.carbsG);
      fill(_fat, parsed.fatG);
      _error = null;
      final missing = [
        if (parsed.kcal == null) 'kcal',
        if (parsed.proteinG == null) 'proteína',
        if (parsed.carbsG == null) 'carbos',
        if (parsed.fatG == null) 'grasa',
      ];
      _clipboardNote = missing.isEmpty
          ? 'Respuesta pegada. Revisa los números antes de guardar.'
          : 'Respuesta pegada, pero falta: ${missing.join(', ')}.';
    });
  }

  Future<void> _submit() async {
    final macros = _macros;
    if (macros == null) {
      setState(() => _error = 'Pon al menos las kcal o algún macro.');
      return;
    }
    final label = _name.text.trim().isEmpty ? quickEntryDefaultLabel : _name.text.trim();
    final db = ref.read(appDatabaseProvider);
    final messenger = ScaffoldMessenger.of(context);

    if (widget.entry != null) {
      await db.mealPlanDao.updateQuick(widget.entry!.id, label: label, macros: macros);
    } else {
      final orderIndex = await db.mealPlanDao.nextOrderIndex(widget.date!, widget.mealType!);
      final entryId = await db.mealPlanDao.addQuick(
        date: widget.date!,
        mealType: widget.mealType!,
        label: label,
        macros: macros,
        orderIndex: orderIndex,
        eaten: widget.eaten,
      );
      showAddedEntrySnackBar(messenger, db: db, entryId: entryId, mealType: widget.mealType!, eaten: widget.eaten);
    }

    if (mounted) Navigator.of(context).pop();
  }

  // Two buttons share a phone-width row: tighter padding and a slightly
  // smaller label keep each one on a single line.
  static final _compactButton = ButtonStyle(
    padding: const WidgetStatePropertyAll(EdgeInsets.symmetric(horizontal: 10, vertical: 12)),
    textStyle: const WidgetStatePropertyAll(TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
  );

  Widget _gramsField(TextEditingController c, String label) => Expanded(
        child: TextField(
          controller: c,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          textInputAction: TextInputAction.next,
          decoration: unitInputDecoration(label: label, unit: 'g'),
          onChanged: (_) => setState(() => _error = null),
        ),
      );

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final macros = _macros;
    final estimatedKcal = _read(_kcal) == null ? _macroKcal : null;

    return SafeArea(
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          left: AppSpacing.lg,
          right: AppSpacing.lg,
          top: AppSpacing.lg,
          bottom: MediaQuery.of(context).viewInsets.bottom + AppSpacing.lg,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (widget.entry == null && widget.mealType != null)
              Text(
                widget.mealType!.label.toUpperCase(),
                style: theme.textTheme.labelMedium?.copyWith(letterSpacing: 0.6),
              ),
            Text('Entrada rápida', style: theme.textTheme.titleLarge),
            const SizedBox(height: AppSpacing.xs),
            Text(
              'Para lo que no puedes pesar. Haz una foto al plato, pregúntale a ChatGPT y pega aquí lo que te diga.',
              style: theme.textTheme.bodyMedium?.copyWith(color: theme.colorScheme.onSurfaceVariant),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    style: _compactButton,
                    icon: const Icon(Icons.copy_rounded, size: 18),
                    label: const Text('Copiar pregunta', maxLines: 1, softWrap: false),
                    onPressed: _copyPrompt,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Expanded(
                  child: FilledButton.tonalIcon(
                    style: _compactButton,
                    icon: const Icon(Icons.content_paste_rounded, size: 18),
                    label: const Text('Pegar respuesta', maxLines: 1, softWrap: false),
                    onPressed: _pasteAnswer,
                  ),
                ),
              ],
            ),
            if (_clipboardNote != null) ...[
              const SizedBox(height: AppSpacing.xs),
              Text(_clipboardNote!, style: theme.textTheme.bodySmall),
            ],
            const SizedBox(height: AppSpacing.lg),
            TextField(
              controller: _name,
              textCapitalization: TextCapitalization.sentences,
              textInputAction: TextInputAction.next,
              decoration: const InputDecoration(
                labelText: '¿Qué era?',
                hintText: 'p. ej. Lentejas de mamá',
                floatingLabelBehavior: FloatingLabelBehavior.always,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            TextField(
              controller: _kcal,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              textInputAction: TextInputAction.next,
              // The helper is always there (not only once macros are typed)
              // so the bottom-anchored sheet never grows under the finger.
              decoration: unitInputDecoration(
                label: 'Calorías',
                unit: 'kcal',
                hint: estimatedKcal != null ? '≈ ${estimatedKcal.round()}' : null,
                errorText: _error,
              ).copyWith(helperText: 'Si lo dejas vacío, se calcula con los macros.'),
              onChanged: (_) => setState(() => _error = null),
            ),
            const SizedBox(height: AppSpacing.md),
            Row(
              children: [
                _gramsField(_protein, 'Proteína'),
                const SizedBox(width: AppSpacing.sm),
                _gramsField(_carbs, 'Carbos'),
                const SizedBox(width: AppSpacing.sm),
                _gramsField(_fat, 'Grasa'),
              ],
            ),
            const SizedBox(height: AppSpacing.lg),
            MacroPreviewRow(macros: macros ?? FoodMacros.zero),
            const SizedBox(height: AppSpacing.xl),
            ElevatedButton(
              onPressed: _submit,
              child: Text(
                widget.entry != null
                    ? 'Guardar'
                    : (widget.eaten ? 'Añadir al diario' : 'Añadir al plan'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Shown under a quick entry's name in a meal section: its macros (with "≈",
// since they're an estimate), as there's no quantity to show instead.
String quickEntrySubtitle(MealPlanEntry entry) {
  final m = storedEntryMacros(entry);
  return '≈ P ${m.proteinG.round()} · C ${m.carbsG.round()} · G ${m.fatG.round()}';
}
