import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_nps.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';
import 'package:wiredash/src/metadata/build_info/device_id_generator.dart';

/// Decides when it is time to show the NPS survey
class NpsTrigger {
  NpsTrigger({
    required this.deviceIdGenerator,
    required this.appTelemetry,
    required this.wiredashTelemetry,
  });

  final DeviceIdGenerator deviceIdGenerator;
  final AppTelemetry appTelemetry;
  final WiredashTelemetry wiredashTelemetry;

  /// Reruns true when the next NPS survey is due.
  ///
  /// When this method returns false the [diagnosticProperties] are filled with
  /// information what prevents the survey from being shown right now.
  Future<bool> shouldShowNps({
    required NpsOptions options,
    DiagnosticPropertiesBuilder? diagnosticProperties,
  }) async {
    final DateTime now = clock.now().toUtc();

    final appStarts = await appTelemetry.appStartCount();
    final minimumAppStarts =
        options.minimumAppStarts ?? defaultNpsOptions.minimumAppStarts!;
    if (appStarts < minimumAppStarts) {
      diagnosticProperties?.add(
        DiagnosticsNode.message(
          'Not enough app starts (minimumAppStarts), '
          'expected minimum $minimumAppStarts, got $appStarts',
        ),
      );
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
      diagnosticProperties?.add(
        DiagnosticsNode.message(
          'App is not used long enough (initialDelay), '
          'first NPS survey will be shown $initialDelay after '
          'firstAppStart: $firstAppStart, earliest $earliestNpsShow',
        ),
      );
      return false;
    }

    final DateTime? lastSurvey = await wiredashTelemetry.lastNpsSurvey();
    final Duration frequency =
        options.frequency ?? defaultNpsOptions.frequency!;
    final nextSurvey = await _earliestNextNpsSurvey(lastSurvey, frequency);
    if (now != nextSurvey && !now.isAfter(nextSurvey)) {
      if (lastSurvey != null) {
        diagnosticProperties
            ?.add(DiagnosticsNode.message('Last survey was $lastSurvey'));
      }
      diagnosticProperties?.add(
        DiagnosticsNode.message(
          'Next survey is scheduled for $nextSurvey based on frequency $frequency',
        ),
      );
      return false;
    }

    // All conditions are met, show the survey
    return true;
  }

  /// Calculates the date for the next survey
  ///
  /// Usually lastSurvey + frequency
  ///
  /// When lastSurvey is null the last survey is artificially set randomly in
  /// the last frequency period. It uses the deviceId as stable seed.
  Future<DateTime> _earliestNextNpsSurvey(
    DateTime? lastSurvey,
    Duration frequency,
  ) async {
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

  /// The scheduled date for the next nps survey
  @visibleForTesting
  Future<DateTime> earliestNextNpsSurveyDate(NpsOptions options) async {
    final DateTime? lastSurvey = await wiredashTelemetry.lastNpsSurvey();
    final Duration frequency =
        options.frequency ?? defaultNpsOptions.frequency!;
    return _earliestNextNpsSurvey(lastSurvey, frequency);
  }
}
