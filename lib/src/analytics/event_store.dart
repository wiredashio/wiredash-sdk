import 'dart:collection';
import 'dart:convert';

import 'package:collection/collection.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/core/services/error_report.dart';

/// Saves [AnalyticsEvent] on disk
class AnalyticsEventStore {
  AnalyticsEventStore({
    required this.sharedPreferences,
  });

  static const Duration outdatedAfter = Duration(days: 3);
  static const String defaultProjectId = 'default';

  static const maximumDiskSizeInBytes = 1024 * 1024; // 1MB
  static final eventKeyRegex =
      RegExp(r'^io\.wiredash\.events\.([\w-]+)\|(\d+)\|([\w-]+)$');

  final Future<SharedPreferences> Function() sharedPreferences;

  Future<void> saveEvent(AnalyticsEvent event, String? projectId) async {
    final prefs = await sharedPreferences();
    await prefs.reload();

    final project = projectId ?? defaultProjectId;
    final millis = event.createdAt!.millisecondsSinceEpoch;
    final discriminator = nanoid(length: 6);
    final key = "io.wiredash.events.$project|$millis|$discriminator";
    assert(
      eventKeyRegex.hasMatch(key),
      'Invalid event key: $key',
    );

    await prefs.setString(key, jsonEncode(serializeEventV1(event)));
  }

  Future<void> deleteOutdatedEvents() async {
    final prefs = await sharedPreferences();
    await prefs.reload();
    final keys = prefs.getKeys();

    final now = DateTime.now();
    final threeDaysAgo = now.subtract(outdatedAfter);
    final int unixThreeDaysAgo = threeDaysAgo.millisecondsSinceEpoch;
    for (final key in keys) {
      final match = eventKeyRegex.firstMatch(key);
      if (match == null) continue;
      final millis = int.parse(match.group(2)!);
      if (millis < unixThreeDaysAgo) {
        await prefs.remove(key);
      }
    }
  }

  Future<void> trimToDiskLimit() async {
    final prefs = await sharedPreferences();
    final eventKeys = prefs
        .getKeys()
        .where((key) => eventKeyRegex.hasMatch(key))
        .toList();

    final oldestLast = eventKeys
        .sortedBy<num>((key) {
          final match = eventKeyRegex.firstMatch(key);
          final int millis = int.parse(match!.group(2)!);
          return millis;
        })
        .reversed
        .toList();

    int limit = maximumDiskSizeInBytes;
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

  Future<void> removeEvent(String key) async {
    final prefs = await sharedPreferences();
    await prefs.remove(key);
  }

  Future<Map<String, AnalyticsEvent>> getEvents(String? projectId) async {
    final prefs = await sharedPreferences();
    await prefs.reload();
    final keys = prefs.getKeys();

    final Map<String, AnalyticsEvent> toBeSubmitted = {};
    for (final key in keys) {
      final match = eventKeyRegex.firstMatch(key);
      if (match == null) continue;
      final eventProjectId = match.group(1);
      if (eventProjectId == defaultProjectId || eventProjectId == projectId) {
        final eventJson = prefs.getString(key);
        if (eventJson == null) continue;
        try {
          final AnalyticsEvent event =
              deserializeEventV1(jsonDecode(eventJson));
          toBeSubmitted[key] = event;
        } catch (e, stack) {
          reportWiredashInfo(
              e, stack, 'Error when parsing event $key. Removing.');
          await prefs.remove(key);
        }
      }
    }
    return toBeSubmitted;
  }
}

Map<String, Object?> serializeEventV1(AnalyticsEvent event) {
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

AnalyticsEvent deserializeEventV1(Map<String, Object?> map) {
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
    return AnalyticsEvent(
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
