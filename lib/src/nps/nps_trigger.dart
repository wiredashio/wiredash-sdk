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

  // TODO save together with deviceId? Currently that is calculated lazily at first usage
  static const userSince = 'io.wiredash.device_registered_date';
  static const lastNpsSurvey = 'io.wiredash.last_nps_survey';

  Future<bool> shouldShowNps() async {
    final DateTime now = clock.now();

    final DateTime? lastSurvey = await _lastNpsSurvey();
    final DateTime firstAppStart = await _firstAppStart();
    final String deviceId = await deviceIdGenerator.deviceId();
    // TODO do we really wanna merge or just take the options?
    final Duration frequency =
        options.frequency ?? defaultNpsOptions.frequency!;

    final DateTime earliestNextSurvey = lastSurvey ?? firstAppStart;
    final DateTime latestNextSurvey = earliestNextSurvey.add(frequency);

    final random = Random(deviceId.hashCode);
    final shiftTimeInS = (random.nextDouble() * frequency.inSeconds).toInt();
    final nextSurveyDateTime =
        earliestNextSurvey.add(Duration(seconds: shiftTimeInS));
    print("nextSurveyDateTime: $nextSurveyDateTime");

    assert(nextSurveyDateTime.isBefore(latestNextSurvey));

    if (nextSurveyDateTime.isBefore(now)) {
      return true;
    }

    // TODO calculate percentage at first show, then save last shown time and ask based on frequency

    // TODO unclear: When do we save createdUser? At all? What if the user sign in/out?
    // Let's scrap this feature for now.
    // This would also for the wiredash to access the sharedPrefs even when it is not triggered.

    return false;
  }

  Future<DateTime> _firstAppStart() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(userSince)) {
      final recovered = prefs.getString(userSince);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    // not yet started
    final now = clock.now();
    await prefs.setString(userSince, now.toIso8601String());
    return now;
  }

  Future<DateTime?> _lastNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    if (prefs.containsKey(lastNpsSurvey)) {
      final recovered = prefs.getString(lastNpsSurvey);
      if (recovered != null) {
        return DateTime.parse(recovered);
      }
    }
    return null;
  }

  Future<void> openedNpsSurvey() async {
    final prefs = await sharedPreferencesProvider();
    final now = clock.now();
    await prefs.setString(lastNpsSurvey, now.toIso8601String());
  }

  // TODO implement clear methods
}
