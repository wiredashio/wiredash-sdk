import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';

/// Abstract interface for submitting events to the backend
///
/// Implementations are
/// - [DirectEventSubmitter] for immediate submission of events (usually web)
/// - [PendingEventSubmitter] for batching events within a certain time frame (usually mobile)
abstract class EventSubmitter {
  /// Submits all pending events in [SharedPreferences] to the backend
  Future<void> submitEvents();
}

class DirectEventSubmitter extends PendingEventSubmitter {
  DirectEventSubmitter({
    required super.sharedPreferences,
    required super.api,
    required super.projectId,
  }) : super(throttleDuration: Duration.zero);
}

class PendingEventSubmitter implements EventSubmitter {
  final Future<SharedPreferences> Function() sharedPreferences;
  final WiredashApi api;
  final String Function() projectId;

  final Duration throttleDuration;

  PendingEventSubmitter({
    required this.sharedPreferences,
    required this.api,
    required this.projectId,
    this.throttleDuration = const Duration(seconds: 30),
  });

  @override
  Future<void> submitEvents() async {
    final projectId = this.projectId();
    print('Submitting events for $projectId');
    // TODO check last sent event call.
    //  If is was less than 30 seconds ago, start timer
    //  else kick of sending events to backend for this projectId
    final prefs = await sharedPreferences();
    await prefs.reload();
    final keys = prefs.getKeys();
    print('Found $keys events on disk');

    final now = clock.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final int unixThreeDaysAgo = threeDaysAgo.millisecondsSinceEpoch;
    final Map<String, PendingEvent> toBeSubmitted = {};
    for (final key in keys) {
      final match = WiredashAnalytics.eventKeyRegex.firstMatch(key);
      if (match == null) continue;
      final eventProjectId = match.group(1);
      final millis = int.parse(match.group(2)!);

      if (eventProjectId == defaultProjectId || eventProjectId == projectId) {
        if (millis < unixThreeDaysAgo) {
          // event is too old, ignore and remove
          await prefs.remove(key);
          continue;
        }

        final eventJson = prefs.getString(key);
        if (eventJson != null) {
          try {
            final PendingEvent event = deserializeEvent(jsonDecode(eventJson));
            print('Found event $key for submission');
            toBeSubmitted[key] = event;
          } catch (e, stack) {
            debugPrint('Error when parsing event $key: $e\n$stack');
            await prefs.remove(key);
          }
        }
      }
    }

    print('processed events');

    // Send all events to the backend
    final events = toBeSubmitted.values.toList();
    print('Found ${events.length} events for submission');
    if (events.isNotEmpty) {
      final requestEvents = events.map((event) {
        return RequestEvent(
          analyticsId: event.analyticsId,
          buildCommit: event.buildCommit,
          buildNumber: event.buildNumber,
          buildVersion: event.buildVersion,
          bundleId: event.bundleId,
          createdAt: event.createdAt,
          eventData: event.eventData,
          eventName: event.eventName,
          platformOS: event.platformOS,
          platformOSVersion: event.platformOSVersion,
          platformLocale: event.platformLocale,
          sdkVersion: event.sdkVersion,
        );
      }).toList();

      print('Sending ${events.length} events to backend');
      try {
        await api.sendEvents(requestEvents);
        print('Submitted ${events.length} events');
        for (final key in toBeSubmitted.keys) {
          await prefs.remove(key);
        }
      } on InvalidEventFormatException catch (e) {
        print('Received error when sending events: $e');
        print('Deleting all events');
        for (final key in toBeSubmitted.keys) {
          await prefs.remove(key);
        }
      } catch (e, stack) {
        print('Received error when sending events: $e\n$stack');
        print('Retrying at a later time');
      }
    }
  }
}
