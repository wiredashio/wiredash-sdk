import 'dart:collection';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

// Prio #1
// TODO how to handle when two instances of the app, with two different wiredash configurations are open. Where would events be sent to?
// TODO send events every 30 seconds to the server (or 5min?)
// TODO send events to server on app close
// TODO wipe events older than 3 days
// TODO validate event name and parameters
// TODO implement Wiredash.of(context).method()
// TODO validate event key
// TODO send first_launch event with # in beginning.
// TODO don't allow # in the beginning
// TODO drop event if server responds 400 (code 2200)
// TODO keep events if server responds 400 (code 2201)
// TODO keep events for any other server error
// TODO allow white space in eventName
// TODO drop event when API credentials are obviously wrong
// TODO allow resetting of the analyticsId
// TODO allow triggering of event submission

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
      RegExp(r'^io\.wiredash\.events\.([\w-]+)\|(\d+)\|([\w-]+)$');

  final WiredashServices _services = WiredashServices();

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? params,
  }) async {
    print('Tracking event $eventName');

    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final flutterInfo = _services.metaDataCollector.collectFlutterInfo();

    final event = PendingEvent(
      analyticsId: await _services.wuidGenerator.appUsageId(),
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

    final project = projectId ?? defaultProjectId;
    final millis = event.createdAt!.millisecondsSinceEpoch;
    final discriminator = nanoid(length: 6);
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

    assert(
      activeWiredashInstances > 1,
      "Expect multiple Wiredash instances to be running.",
    );
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

const defaultProjectId = 'default';

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
