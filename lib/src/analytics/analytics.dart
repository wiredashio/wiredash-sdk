import 'dart:collection';
import 'dart:convert';
import 'dart:ui';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/metadata/meta_data_collector.dart';

import '../core/version.dart';

// Prio #1
// TODO how to handle when two instances of the app, with two different wiredash configurations are open. Where would events be sent to?
// TODO separate api event model and persistence event model
// TODO save events to local storage
// TODO send events every 30 seconds to the server (or 5min?)
// TODO wipe events older than 3 days
// TODO validate event name and parameters
// TODO check if we can replace Wiredash.of(context).method() with just Wiredash.method()
// TODO validate event key
// TODO send first_launch event with # in beginning.
// TODO don't allow # in the beginning

// Nice to have
// TODO write integration_test for isolates
// TODO send events directly on web

class WiredashAnalytics {
  /// Optional [projectId] in case multiple [Wiredash] widgets with different
  /// projectIds are used at the same time
  final String? projectId;

  WiredashAnalytics({
    this.projectId,
  });

  static final eventKeyRegex =
      RegExp(r'^io\.wiredash\.events\.(\w+)\|(\d+)\|(\w+)$');

  static const _defaultProjectId = 'default';

  final MetaDataCollector metaDataCollector = MetaDataCollector(
    deviceInfoCollector: () => FlutterInfoCollector(window),
    buildInfoProvider: () => getBuildInformation(),
  );

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? params,
  }) async {
    print('Tracking event $eventName');

    final WuidGenerator wuidGenerator = SharedPrefsWuidGenerator(
      sharedPrefsProvider: SharedPreferences.getInstance,
    );
    final fixedMetadata = await metaDataCollector.collectFixedMetaData();
    final flutterInfo = metaDataCollector.collectFlutterInfo();

    final event = PendingEvent(
      analyticsId: await wuidGenerator.appUsageId(),
      buildCommit: fixedMetadata.resolvedBuildCommit,
      buildNumber: fixedMetadata.resolvedBuildNumber,
      buildVersion: fixedMetadata.resolvedBuildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      createdAt: clock.now(),
      eventData: params,
      eventName: eventName,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
      platformLocale: flutterInfo.platformLocale,
      sdkVersion: wiredashSdkVersion,
    );

    final prefs = await SharedPreferences.getInstance();
    print('Loaded prefs from disk');
    await prefs.reload();

    final project = projectId ?? _defaultProjectId;
    final millis = event.createdAt!.millisecondsSinceEpoch ~/ 1000;
    final discriminator = nanoid(
      length: 6,
      // \w in regex, ignores "-"
      alphabet: Alphabet.alphanumeric,
    );
    final key = "io.wiredash.events.$project|$millis|$discriminator";
    assert(eventKeyRegex.hasMatch(key), 'Invalid event key: $key');

    await prefs.setString(key, jsonEncode(serializeEvent(event)));
    print('Saved event $key to disk');

    try {
      await _removeOldEvents();
    } catch (e, stack) {
      reportWiredashInfo(
        e,
        stack,
        'Could not remove old events',
      );
    }

    final id = projectId;
    if (id != null) {
      // Inform correct Wiredash instance about event
      final state = WiredashRegistry.findByProjectId(id);
      if (state != null) {
        await state.newEventAdded();
      } else {
        // widget not found, it will upload the event when mounted the next time
      }
      return;
    }

    // Forward default events to the only Wiredash instance that is running
    final activeWiredashInstances = WiredashRegistry.referenceCount;
    if (activeWiredashInstances == 0) {
      // no Wiredash instance is running. Wait for next mount to send the event
      return;
    }
    if (activeWiredashInstances == 1) {
      // found a single Wiredash instance, notify about the new event
      await WiredashRegistry.forEach((wiredashState) async {
        await wiredashState.newEventAdded();
      });
      return;
    }

    assert(activeWiredashInstances > 1,
        "Expect multiple Wiredash instances to be running.");
    assert(projectId == null, "No projectId defined");
    debugPrint(
      "Multiple Wiredash instances are mounted! "
      "Please specify a projectId to avoid sending events to all instances, "
      "or use Wiredash.of(context).trackEvent() to send events to a specific instance.",
    );
  }

  Future<void> _removeOldEvents() async {
    final prefs = await SharedPreferences.getInstance();
    final eventKeys = prefs
        .getKeys()
        .where((key) => WiredashAnalytics.eventKeyRegex.hasMatch(key))
        .toList();

    final oldestLast = eventKeys
        .sortedBy<num>((key) {
          final match = WiredashAnalytics.eventKeyRegex.firstMatch(key);
          final int millis = int.parse(match!.group(2)!);
          return millis;
        })
        .reversed
        .toList();

    const oneMb = 1024 * 1024;

    int limit = oneMb;
    for (final event in oldestLast.toList()) {
      final String? data = prefs.getString(event);
      if (data == null) {
        continue;
      }
      // TODO check what a normal event size is. Adjust limit accordingly
      final int size /* bytes */ = utf8.encode(data).length;
      limit -= size;
      if (limit < 0) {
        break;
      }
      oldestLast.remove(event);
    }

    // remove remaining events that exceed the maximum size
    for (final event in oldestLast) {
      print('Removing $event from disk');
      await prefs.remove(event);
    }
  }
}

Map<String, Object?> serializeEvent(PendingEvent event) {
  final values = SplayTreeMap<String, Object?>.from({
    "analyticsId": event.analyticsId,
    if (event.buildCommit != null) "buildCommit": event.buildCommit,
    if (event.buildNumber != null) "buildNumber": event.buildNumber,
    if (event.buildVersion != null) "buildVersion": event.buildVersion,
    if (event.bundleId != null) "bundleId": event.bundleId,
    if (event.createdAt != null)
      "createdAt": event.createdAt!.toIso8601String(),
    "eventName": event.eventName,
    if (event.platformOS != null) "platformOS": event.platformOS,
    if (event.platformOSVersion != null)
      "platformOSVersion": event.platformOSVersion,
    if (event.platformLocale != null) "platformLocale": event.platformLocale,
    "sdkVersion": event.sdkVersion,
    "version": 1,
  });

  final paramsValidated = event.eventData?.map((key, value) {
    if (value == null) {
      return MapEntry(key, null);
    }
    try {
      // try encoding. We don't care about the actual encoded content because
      // it will be later by the http library encoded
      jsonEncode(value);
      // encoding worked, it's valid data
      return MapEntry(key, value);
    } catch (e, stack) {
      reportWiredashError(
        e,
        stack,
        'Could not serialize event property '
        '$key=$value',
      );
      return MapEntry(key, null);
    }
  });
  if (paramsValidated != null) {
    paramsValidated.removeWhere((key, value) => value == null);
    if (paramsValidated.isNotEmpty) {
      values.addAll({'eventData': paramsValidated});
    }
  }
  return values;
}

PendingEvent deserializeEvent(Map<String, Object?> map) {
  final version = map['version'] as int?;
  if (version == 1) {
    final analyticsId = map['analyticsId']! as String;
    final buildCommit = map['buildCommit'] as String?;
    final buildNumber = map['buildNumber'] as String?;
    final buildVersion = map['buildVersion'] as String?;
    final bundleId = map['bundleId'] as String?;
    final createdAtRaw = map['createdAt'] as String?;
    final eventData = map['eventData'] as Map<String, Object?>?;
    final eventName = map['eventName']! as String;
    final platformOS = map['platformOS'] as String?;
    final platformOSVersion = map['platformOSVersion'] as String?;
    final platformLocale = map['platformLocale'] as String?;
    final sdkVersion = map['sdkVersion']! as int;
    return PendingEvent(
      analyticsId: analyticsId,
      buildCommit: buildCommit,
      buildNumber: buildNumber,
      buildVersion: buildVersion,
      bundleId: bundleId,
      createdAt: createdAtRaw != null ? DateTime.parse(createdAtRaw) : null,
      eventData: eventData,
      eventName: eventName,
      platformOS: platformOS,
      platformOSVersion: platformOSVersion,
      platformLocale: platformLocale,
      sdkVersion: sdkVersion,
    );
  }

  throw UnimplementedError("Unknown event version $version");
}

Future<void> trackEvent(
  String eventName, {
  Map<String, Object?>? params,
  String? projectId,
}) async {
  final analytics = WiredashAnalytics(projectId: projectId);
  await analytics.trackEvent(eventName, params: params);
}

class WiredashAnalyticsServices {
  // TODO create service locator
}

class PendingEvent {
  final String analyticsId;
  final String? buildCommit;
  final String? buildNumber;
  final String? buildVersion;
  final String? bundleId;
  final DateTime? createdAt;
  final Map<String, Object?>? eventData;
  final String eventName;
  final String? platformOS;
  final String? platformOSVersion;
  final String? platformLocale;
  final int sdkVersion;

  const PendingEvent({
    required this.analyticsId,
    this.buildCommit,
    this.buildNumber,
    this.buildVersion,
    this.bundleId,
    this.createdAt,
    this.eventData,
    required this.eventName,
    this.platformOS,
    this.platformOSVersion,
    this.platformLocale,
    required this.sdkVersion,
  });
}

abstract class EventSubmitter {
  Future<void> submitEvents(String projectId);
}

class PendingEventSubmitter implements EventSubmitter {
  final Future<SharedPreferences> Function() sharedPreferences;
  final WiredashApi api;

  PendingEventSubmitter({
    required this.sharedPreferences,
    required this.api,
  });

  @override
  Future<void> submitEvents(String projectId) async {
    // TODO check last sent event call.
    //  If is was less than 30 seconds ago, start timer
    //  else kick of sending events to backend for this projectId
    final prefs = await sharedPreferences();
    await prefs.reload();
    final keys = prefs.getKeys();
    print('Found $keys events on disk');

    final now = clock.now();
    final threeDaysAgo = now.subtract(const Duration(days: 3));
    final int unixThreeDaysAgo = threeDaysAgo.millisecondsSinceEpoch ~/ 1000;
    final Map<String, PendingEvent> toBeSubmitted = {};
    for (final key in keys) {
      print('Checking key $key');
      final match = WiredashAnalytics.eventKeyRegex.firstMatch(key);
      if (match == null) continue;
      final eventProjectId = match.group(1);
      final millis = int.parse(match.group(2)!);

      if (eventProjectId == WiredashAnalytics._defaultProjectId ||
          eventProjectId == projectId) {
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
      await api.sendEvents(requestEvents);
      for (final key in toBeSubmitted.keys) {
        await prefs.remove(key);
      }
    }
  }
}

// TODO write documentation with these examples
void main() async {
  final BuildContext context = RootElement(const RootWidget());

  // plain arguments
  await trackEvent('test_event', params: {'param1': 'value1'});

  // Event object
  // final event = Event(name: 'test_event', params: {'param1': 'value1'});
  // await trackEvent2(event);

  // WiredashAnalytics instance
  final analytics = WiredashAnalytics();
  await analytics.trackEvent('test_event', params: {'param1': 'value1'});

  // state instance method (will always work)
  await Wiredash.of(context)
      .trackEvent('test_event', params: {'param1': 'value1'});

  await trackEvent('test_event', params: {'param1': 'value1'});
}
