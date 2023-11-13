import 'dart:math';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/telemetry/app_telemetry.dart';
import 'package:wiredash/src/core/telemetry/wiredash_telemetry.dart';

/// Decides when it is time to show the promoter score survey
class PsTrigger {
  PsTrigger({
    required this.wuidGenerator,
    required this.appTelemetry,
    required this.wiredashTelemetry,
  });

  final WuidGenerator wuidGenerator;
  final AppTelemetry appTelemetry;
  final WiredashTelemetry wiredashTelemetry;

  /// Reruns true when the next promoter score survey is due.
  ///
  /// When this method returns false the [diagnosticProperties] are filled with
  /// information what prevents the survey from being shown right now.
  Future<bool> shouldShowPromoterSurvey({
    required PsOptions options,
    DiagnosticPropertiesBuilder? diagnosticProperties,
  }) async {
    final DateTime now = clock.now().toUtc();

    final appStarts = await appTelemetry.appStartCount();
    final minimumAppStarts =
        options.minimumAppStarts ?? defaultPsOptions.minimumAppStarts!;
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
    final initialDelay = options.initialDelay ?? defaultPsOptions.initialDelay!;
    final earliestShow = firstAppStart.add(initialDelay);
    if (now.isBefore(earliestShow)) {
      diagnosticProperties?.add(
        DiagnosticsNode.message(
          'App is not used long enough (initialDelay), '
          'first promoter score survey will be shown $initialDelay after '
          'firstAppStart: $firstAppStart, earliest $earliestShow',
        ),
      );
      return false;
    }

    final DateTime? lastSurvey =
        await wiredashTelemetry.lastPromoterScoreSurvey();
    final Duration frequency = options.frequency ?? defaultPsOptions.frequency!;
    final nextSurvey = await _earliestNextPsSurvey(lastSurvey, frequency);
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
  Future<DateTime> _earliestNextPsSurvey(
    DateTime? lastSurvey,
    Duration frequency,
  ) async {
    if (lastSurvey == null) {
      // Using the device id to randomly distribute the next survey time within
      // frequency. This results in the same date for every call of this method
      final String deviceId = await wuidGenerator.submitId();
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

  /// The scheduled date for the next promoter score survey
  @visibleForTesting
  Future<DateTime> earliestNextPromoterScoreSurveyDate(
    PsOptions options,
  ) async {
    final DateTime? lastSurvey =
        await wiredashTelemetry.lastPromoterScoreSurvey();
    final Duration frequency = options.frequency ?? defaultPsOptions.frequency!;
    return _earliestNextPsSurvey(lastSurvey, frequency);
  }
}
