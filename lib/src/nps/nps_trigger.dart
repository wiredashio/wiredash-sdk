import 'dart:math';

import 'package:clock/clock.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';

/// Decides when it is time to show the NPS survey
class NpsTrigger {
  NpsTrigger({
    required this.sharedPreferencesProvider,
    required this.options,
    required this.deviceIdGenerator,
  });

  final Future<SharedPreferences> Function() sharedPreferencesProvider;
  final NpsOptions options;
  final DeviceIdGenerator deviceIdGenerator;

  static const deviceRegistrationDateKey = 'io.wiredash.device_registered_date';
  static const lastNpsSurveyKey = 'io.wiredash.last_nps_survey';
  static const appStartsKey = 'io.wiredash.app_starts';

  Future<bool> shouldShowNps() async {
    final DateTime now = clock.now().toUtc();

    final appStarts = await _appStartCount();
    // TODO fall back to defaultNpsOptions? Seems odd, test in example
    final minimumAppStarts =
        options.minimumAppStarts ?? defaultNpsOptions.minimumAppStarts!;
    if (appStarts < minimumAppStarts) {
      // use has to use the app a bit more before the survey is shown
      return false;
    }

    final firstAppStartDate = await _firstAppStart();
    final newUserDelay =
        options.newUserDelay ?? defaultNpsOptions.newUserDelay!;
    final earliestNpsShow = firstAppStartDate.add(newUserDelay);
    if (now.isBefore(earliestNpsShow)) {
      // User has to use the app a bit longer before the survey is shown
      return false;
    }

    final nextSurvey = await earliestNextNpsSurveyDate();
    if (now != nextSurvey && !now.isAfter(nextSurvey)) {
      // too early, don't show it just yet
      return false;
    }

    // All conditions are met, show the survey
    return true;
  }

  Future<DateTime> earliestNextNpsSurveyDate() async {
    final DateTime? lastSurvey = await _lastNpsSurvey();
    final DateTime firstAppStart = await _firstAppStart();
    final String deviceId = await deviceIdGenerator.deviceId();
    final Duration frequency =
        options.frequency ?? defaultNpsOptions.frequency!;

    if (lastSurvey == null) {
      // TODO simplify logic. Look for survey time in the past interval
      // no survey ever shown, randomly distribute the first survey in the next period
      final random = Random(deviceId.hashCode);
      final shiftTimeInS = (random.nextDouble() * frequency.inSeconds).toInt();
      final nextSurvey = firstAppStart.add(Duration(seconds: shiftTimeInS));
      return nextSurvey;
    }

    final nextSurvey = lastSurvey.add(frequency);
    return nextSurvey;
  }

  Future<void> openedNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    final now = clock.now().toUtc();
    await prefs.setString(lastNpsSurveyKey, now.toIso8601String());
  }

  // TODO use this
  Future<void> _incrementAppStartCount() async {
    final prefs = await sharedPreferencesProvider();
    final appStarts = await _appStartCount();
    await prefs.setInt(appStartsKey, appStarts + 1);
  }

  Future<int> _appStartCount() async {
    final prefs = await sharedPreferencesProvider();
    final appStarts = prefs.getInt(appStartsKey) ?? 0;
    return appStarts;
  }

  // TODO make sure this is triggered at the first app start. Definitely write a test for it
  Future<DateTime> _firstAppStart() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(deviceRegistrationDateKey)) {
      final recovered = prefs.getString(deviceRegistrationDateKey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    // not yet started
    final now = clock.now().toUtc();
    await prefs.setString(deviceRegistrationDateKey, now.toIso8601String());
    return now;
  }

  Future<DateTime?> _lastNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(lastNpsSurveyKey)) {
      final recovered = prefs.getString(lastNpsSurveyKey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    return null;
  }

  // TODO implement clear methods
}
