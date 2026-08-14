import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../diario/providers/diary_providers.dart';

class MyDataScreen extends ConsumerStatefulWidget {
  const MyDataScreen({super.key});

  @override
  ConsumerState<MyDataScreen> createState() => _MyDataScreenState();
}

class _MyDataScreenState extends ConsumerState<MyDataScreen> {
  final _name = TextEditingController();
  final _height = TextEditingController();
  BiologicalSex _sex = BiologicalSex.male;
  DateTime _birthDate = DateTime(DateTime.now().year - 25);
  ActivityLevel _activityLevel = ActivityLevel.moderate;
  bool _initialized = false;

  void _initFrom(UserProfileData profile) {
    if (_initialized) return;
    _initialized = true;
    _name.text = profile.name ?? '';
    _height.text = profile.heightCm?.round().toString() ?? '';
    _sex = profile.sex ?? BiologicalSex.male;
    _birthDate = profile.birthDate ?? _birthDate;
    _activityLevel = profile.activityLevel;
  }

  @override
  void dispose() {
    _name.dispose();
    _height.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final height = double.tryParse(_height.text.replaceAll(',', '.'));
    await ref.read(appDatabaseProvider).userProfileDao.updateProfile(UserProfileCompanion(
          name: Value(_name.text.trim().isEmpty ? null : _name.text.trim()),
          sex: Value(_sex),
          birthDate: Value(_birthDate),
          heightCm: Value(height),
          activityLevel: Value(_activityLevel),
        ));
    if (mounted) Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final profileAsync = ref.watch(userProfileStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Mis datos')),
      body: profileAsync.when(
        data: (profile) {
          if (profile == null) return const Center(child: CircularProgressIndicator());
          _initFrom(profile);
          return ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              TextField(
                controller: _name,
                decoration: const InputDecoration(labelText: 'Nombre'),
              ),
              const SizedBox(height: AppSpacing.md),
              SegmentedButton<BiologicalSex>(
                segments: const [
                  ButtonSegment(value: BiologicalSex.male, label: Text('Hombre')),
                  ButtonSegment(value: BiologicalSex.female, label: Text('Mujer')),
                ],
                selected: {_sex},
                onSelectionChanged: (s) => setState(() => _sex = s.first),
              ),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Fecha de nacimiento'),
                subtitle: Text('${_birthDate.day}/${_birthDate.month}/${_birthDate.year}'),
                trailing: const Icon(Icons.calendar_today_outlined),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: _birthDate,
                    firstDate: DateTime(1920),
                    lastDate: DateTime.now(),
                  );
                  if (picked != null) setState(() => _birthDate = picked);
                },
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _height,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Altura (cm)'),
              ),
              const SizedBox(height: AppSpacing.md),
              DropdownButtonFormField<ActivityLevel>(
                initialValue: _activityLevel,
                decoration: const InputDecoration(labelText: 'Nivel de actividad'),
                items: const [
                  DropdownMenuItem(value: ActivityLevel.sedentary, child: Text('Sedentario')),
                  DropdownMenuItem(value: ActivityLevel.light, child: Text('Ligera')),
                  DropdownMenuItem(value: ActivityLevel.moderate, child: Text('Moderada')),
                  DropdownMenuItem(value: ActivityLevel.active, child: Text('Alta')),
                  DropdownMenuItem(value: ActivityLevel.veryActive, child: Text('Muy alta')),
                ],
                onChanged: (v) => setState(() => _activityLevel = v ?? _activityLevel),
              ),
              const SizedBox(height: AppSpacing.xl),
              ElevatedButton(onPressed: _save, child: const Text('Guardar')),
            ],
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }
}
