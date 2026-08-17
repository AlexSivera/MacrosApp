import 'dart:convert';
import 'dart:typed_data';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/backup/backup_service.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _busy = false;

  Future<void> _confirmReset() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Restablecer datos'),
        content: const Text(
          'Se eliminarán tu perfil, diario, recetas, peso y alimentos personalizados. '
          'Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: TextButton.styleFrom(foregroundColor: Theme.of(context).colorScheme.error),
            child: const Text('Restablecer'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    await ref.read(appDatabaseProvider).resetAllData();
    if (mounted) context.go('/onboarding');
  }

  Future<void> _export() async {
    setState(() => _busy = true);
    try {
      final json = await exportBackup(ref.read(appDatabaseProvider));
      final dateSuffix = DateTime.now().toIso8601String().split('T').first;
      await FilePicker.saveFile(
        fileName: 'kalibra_backup_$dateSuffix.json',
        bytes: Uint8List.fromList(utf8.encode(json)),
        mimeType: 'application/json',
        type: FileType.custom,
        allowedExtensions: const ['json'],
      );
      if (mounted) _showMessage('Copia de seguridad guardada.');
    } catch (e) {
      if (mounted) _showMessage('No se pudo exportar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _import() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Importar copia de seguridad'),
        content: const Text(
          'Los alimentos, recetas y registros del archivo se añadirán a los que ya tienes '
          '— no se borra nada existente.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancelar')),
          TextButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Importar')),
        ],
      ),
    );
    if (confirmed != true || !mounted) return;

    setState(() => _busy = true);
    try {
      final file = await FilePicker.pickFile(type: FileType.custom, allowedExtensions: ['json']);
      if (file == null) return;

      final bytes = await file.readAsBytes();
      final summary = await importBackup(ref.read(appDatabaseProvider), utf8.decode(bytes));
      if (mounted) {
        _showMessage(
          'Importado: ${summary.recipes} recetas, ${summary.diaryEntries} registros del diario, '
          '${summary.bodyWeightLogs} pesos, ${summary.burnedCalories} calorías quemadas.',
        );
      }
    } on BackupFormatException catch (e) {
      if (mounted) _showMessage(e.message);
    } catch (e) {
      if (mounted) _showMessage('No se pudo importar: $e');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Configuración')),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Copia de seguridad', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _busy ? null : _export,
              icon: const Icon(Icons.file_download_outlined),
              label: const Text('Exportar copia de seguridad'),
            ),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _busy ? null : _import,
              icon: const Icon(Icons.file_upload_outlined),
              label: const Text('Importar copia de seguridad'),
            ),
            const SizedBox(height: AppSpacing.xxl),
            Text('Zona de peligro', style: theme.textTheme.labelMedium),
            const SizedBox(height: AppSpacing.sm),
            OutlinedButton.icon(
              onPressed: _busy ? null : _confirmReset,
              icon: Icon(Icons.delete_outline_rounded, color: theme.colorScheme.error),
              label: Text(
                'Restablecer datos de la app',
                style: TextStyle(color: theme.colorScheme.error),
              ),
              style: OutlinedButton.styleFrom(side: BorderSide(color: theme.colorScheme.error)),
            ),
            if (_busy) ...[
              const SizedBox(height: AppSpacing.lg),
              const Center(child: CircularProgressIndicator()),
            ],
          ],
        ),
      ),
    );
  }
}
