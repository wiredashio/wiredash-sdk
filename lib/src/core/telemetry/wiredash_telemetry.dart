import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract class WiredashTelemetry {
  /// Event when promoter score survey was shown to the user
  Future<void> onOpenedPromoterScoreSurvey();

  /// The last time the user has been surveyed with an promoter score survey
  Future<DateTime?> lastPromoterScoreSurvey();
}

/// A persistent storage for the telemetry data from Wiredash
class PersistentWiredashTelemetry extends WiredashTelemetry {
  PersistentWiredashTelemetry(this.sharedPreferencesProvider);

  static const _lastPromoterScoreSurveyKey = 'io.wiredash.last_ps_survey';

  final Future<SharedPreferences> Function() sharedPreferencesProvider;

  @override
  Future<void> onOpenedPromoterScoreSurvey() async {
    final prefs = await sharedPreferencesProvider();
    final now = clock.now().toUtc();
    await prefs.setString(_lastPromoterScoreSurveyKey, now.toIso8601String());
  }

  @override
  Future<DateTime?> lastPromoterScoreSurvey() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(_lastPromoterScoreSurveyKey)) {
      final recovered = prefs.getString(_lastPromoterScoreSurveyKey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    return null;
  }
}
