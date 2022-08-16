import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class WiredashTelemetry {
  /// Event when NPS was shown to the user
  Future<void> onOpenedNpsSurvey();

  /// The last time the user has been surveyed with an NPS survey
  Future<DateTime?> lastNpsSurvey();
}

/// A persistent storage for the telemetry data from Wiredash
class PersistentWiredashTelemetry extends WiredashTelemetry {
  PersistentWiredashTelemetry(this.sharedPreferencesProvider);

  static const _lastNpsSurveyKey = 'io.wiredash.last_nps_survey';

  final Future<SharedPreferences> Function() sharedPreferencesProvider;

  @override
  Future<void> onOpenedNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    final now = clock.now().toUtc();
    await prefs.setString(_lastNpsSurveyKey, now.toIso8601String());
  }

  @override
  Future<DateTime?> lastNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(_lastNpsSurveyKey)) {
      final recovered = prefs.getString(_lastNpsSurveyKey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    return null;
  }
}
