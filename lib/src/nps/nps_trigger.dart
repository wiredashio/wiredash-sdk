import 'dart:math';

import 'package:clock/clock.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';

/// Decides when it is time to show the NPS survey
class NpsTrigger {
  NpsTrigger({
    required this.options,
    required this.deviceIdGenerator,
    required this.appTelemetry,
    required this.wiredashTelemetry,
  });

  final NpsOptions options;
  final DeviceIdGenerator deviceIdGenerator;
  final AppTelemetry appTelemetry;
  final WiredashTelemetry wiredashTelemetry;

  Future<bool> shouldShowNps() async {
    final DateTime now = clock.now().toUtc();

    final appStarts = await appTelemetry.appStartCount();
    final minimumAppStarts =
        options.minimumAppStarts ?? defaultNpsOptions.minimumAppStarts!;
    if (appStarts < minimumAppStarts) {
      // use has to use the app a bit more before the survey is shown
      return false;
    }

    final firstAppStart = await appTelemetry.firstAppStart();
    if (firstAppStart == null) {
      throw 'Wiredash did not catch that the app was started';
    }
    final initialDelay =
        options.initialDelay ?? defaultNpsOptions.initialDelay!;
    final earliestNpsShow = firstAppStart.add(initialDelay);
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
    final DateTime? lastSurvey = await wiredashTelemetry.lastNpsSurvey();
    final Duration frequency =
        options.frequency ?? defaultNpsOptions.frequency!;

    if (lastSurvey == null) {
      // Using the device id to randomly distribute the next survey time within
      // frequency. This results in the same date for every call of this method
      final String deviceId = await deviceIdGenerator.deviceId();
      final random = Random(deviceId.hashCode);
      final shiftTimeInS = (random.nextDouble() * frequency.inSeconds).toInt();
      final DateTime? firstAppStart = await appTelemetry.firstAppStart();
      if (firstAppStart == null) {
        throw 'Wiredash did not catch that the app was started';
      }
      final nextSurvey = firstAppStart.add(Duration(seconds: shiftTimeInS));
      return nextSurvey;
    }

    final nextSurvey = lastSurvey.add(frequency);
    return nextSurvey;
  }

// TODO implement clear methods
}
