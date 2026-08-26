import 'package:health/health.dart';

// Reads "calorías quemadas" from Health Connect (Android) — e.g. data a
// wearable's own app (Mi Fitness for a Xiaomi Smart Band) writes there.
// Read-only: Kalibra never writes health data back. Callers must guard with
// `kIsWeb`/platform checks first — this file assumes Android and is never
// imported from web-reachable code paths.
final _health = Health();

const _burnedTypes = [
  HealthDataType.ACTIVE_ENERGY_BURNED,
  HealthDataType.TOTAL_CALORIES_BURNED,
];

// Whether Health Connect is ready to be queried on this device — kept as
// Kalibra's own enum so callers (e.g. the Diario UI) never need to import
// `package:health` themselves, the one file that must stay Android-only.
// The only two SDK states other than "available" both resolve the same way
// (send the user to install/update Health Connect via Play Store), so they
// collapse into a single `needsInstall` case.
enum HealthConnectAvailability { available, needsInstall }

Future<HealthConnectAvailability> checkHealthConnectAvailability() async {
  await _health.configure();
  final status = await _health.getHealthConnectSdkStatus();
  return status == HealthConnectSdkStatus.sdkAvailable
      ? HealthConnectAvailability.available
      : HealthConnectAvailability.needsInstall;
}

Future<void> openHealthConnectInstall() => _health.installHealthConnect();

Future<bool> requestBurnedCaloriesPermission() {
  return _health.requestAuthorization(
    _burnedTypes,
    permissions: _burnedTypes.map((_) => HealthDataAccess.READ).toList(),
  );
}

// Sums a single day's burned calories. Prefers ACTIVE_ENERGY_BURNED — the
// figure that belongs on top of an already-TDEE-based objetivo — and only
// falls back to TOTAL_CALORIES_BURNED (which bundles in BMR) if the source
// app never wrote an active-energy figure, so most devices still show
// something instead of a silent zero.
Future<double?> fetchBurnedKcalForDate(DateTime date) async {
  final start = DateTime(date.year, date.month, date.day);
  final end = start.add(const Duration(days: 1));

  final active = await _sumType(HealthDataType.ACTIVE_ENERGY_BURNED, start, end);
  if (active != null && active > 0) return active;

  return _sumType(HealthDataType.TOTAL_CALORIES_BURNED, start, end);
}

Future<double?> _sumType(HealthDataType type, DateTime start, DateTime end) async {
  final points = await _health.getHealthDataFromTypes(
    types: [type],
    startTime: start,
    endTime: end,
  );
  if (points.isEmpty) return null;

  var total = 0.0;
  for (final point in points) {
    final value = point.value;
    if (value is NumericHealthValue) total += value.numericValue.toDouble();
  }
  return total;
}
