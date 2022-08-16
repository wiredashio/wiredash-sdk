import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Telemetry data from the app that ships with Wiredash
abstract class AppTelemetry {
  /// Event from the [Wiredash] widget when it gets started for the first time in the current Zone
  Future<void> onAppStart();

  /// Returns the time the app was first started
  ///
  /// This should be close the the app install time or the
  /// first the app shipped with Wiredash
  ///
  /// Falls back to the current time if no first app start time is available
  Future<DateTime?> firstAppStart();

  /// Returns the number of app starts
  Future<int> appStartCount();
}

/// A persistent storage for the app telemetry data
class PersistentAppTelemetry extends AppTelemetry {
  PersistentAppTelemetry(this.sharedPreferencesProvider);

  static const deviceRegistrationDateKey = 'io.wiredash.device_registered_date';
  static const appStartsKey = 'io.wiredash.app_starts';

  final Future<SharedPreferences> Function() sharedPreferencesProvider;

  @override
  Future<void> onAppStart() async {
    await _saveFirstAppStart();
    await _saveAppStartCount();
  }

  @override
  Future<DateTime?> firstAppStart() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(deviceRegistrationDateKey)) {
      final recovered = prefs.getString(deviceRegistrationDateKey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    return null;
  }

  Future<void> _saveFirstAppStart() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(deviceRegistrationDateKey)) {
      return;
    }
    // not yet started
    final now = clock.now().toUtc();
    await prefs.setString(deviceRegistrationDateKey, now.toIso8601String());
  }

  @override
  Future<int> appStartCount() async {
    final prefs = await sharedPreferencesProvider();
    final appStarts = prefs.getInt(appStartsKey) ?? 0;
    return appStarts;
  }

  Future<void> _saveAppStartCount() async {
    final appStarts = await appStartCount();
    final prefs = await sharedPreferencesProvider();
    await prefs.setInt(appStartsKey, appStarts + 1);
  }
}
