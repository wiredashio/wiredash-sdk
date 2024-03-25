import 'dart:convert';
import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

// Required
// TODO send events every 30 seconds to the server (or 5min?)
// TODO drop event if server responds 400 (code 2200) MISSING TEST
// TODO keep events if server responds 400 (code 2201) MISSING TEST
// TODO keep events for any other server error MISSING TEST
// TODO ignore corrupt events on disk (users might edit it on web)
// TODO export analytics
// TODO Write documentation

// Important
// TODO send events to server on app close
// TODO drop event when API credentials are obviously wrong
// TODO allow resetting of the analyticsId
// TODO send events directly on web
// TODO test InvalidEventFormatException with real server response

// Nice to have
// TODO allow triggering of event submission
// TODO write integration_test for isolates
// TODO automatically add page_name as property
// TODO check if WiredashRegistry instance could be saved in the zone

class WiredashAnalytics {
  /// Optional [projectId] in case multiple [Wiredash] widgets with different
  /// projectIds are used at the same time
  final String? projectId;

  WiredashAnalytics({
    this.projectId,
  });

  final WiredashServices _services = WiredashServices();

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? data,
  }) async {
    validateEventName(eventName);
    final eventData = validateParams(data, eventName);

    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final flutterInfo = _services.metaDataCollector.collectFlutterInfo();

    final event = AnalyticsEvent(
      analyticsId: await _services.wuidGenerator.appUsageId(),
      buildCommit: fixedMetadata.resolvedBuildCommit,
      buildNumber: fixedMetadata.resolvedBuildNumber,
      buildVersion: fixedMetadata.resolvedBuildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      createdAt: clock.now(),
      eventData: eventData,
      eventName: eventName,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
      platformLocale: flutterInfo.platformLocale,
      sdkVersion: wiredashSdkVersion,
    );

    await _services.eventStore.saveEvent(event, projectId);
    await _notifyWiredashInstance(projectId, eventName);
  }

  Future<void> _notifyWiredashInstance(
    String? projectId,
    String eventName,
  ) async {
    final allWidget = WiredashRegistry.instance.allWidgets;
    if (allWidget.isEmpty) {
      // no Wiredash instance is running. Wait for next mount to send the event

      final bool isMainIsolate = Isolate.current.debugName == 'main';
      if (!isMainIsolate) {
        // The event will be picked up automatically by the main isolate,
        // when the next event is sent from the main isolate.
        return;
      }
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "No Wiredash widget is mounted. "
        "The event '$eventName' was captured but not yet submitted to the server. "
        "Please make sure to wrap your app with Wiredash. "
        "See https://docs.wiredash.com/guide/start",
      );

      return;
    }

    if (allWidget.length == 1) {
      final state = allWidget.first;
      if (projectId == null) {
        // notify the only registered Wiredash instance
        await state.newEventAdded();
        return;
      }

      final widget = state.widget;
      if (widget.projectId == projectId) {
        // projectId matches, notify the only and correct Wiredash instance
        await state.newEventAdded();
        return;
      }
      // The only registered Wiredash instance has a different projectId
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "Wiredash is registered with ${widget.projectId}. "
        "The event event '$eventName' was explicit sent to projectId $projectId. "
        "No Wiredash instance was found with projectId $projectId. "
        "Please double check the projectId.",
      );
      return;
    }
    assert(allWidget.length > 1, "Multiple Wiredash instances are mounted.");

    if (projectId == null) {
      final firstWidgetState = allWidget.first;

      final ids = allWidget.map((e) => e.widget.projectId).join(", ");
      reportWiredashInfo(
        NoProjectIdSpecifiedException(),
        StackTrace.current,
        "Multiple Wiredash instances with different projectIds are mounted ($ids). "
        "Please specify a projectId when using multiple Wiredash instances like this:\n"
        "    Wiredash.trackEvent('$eventName', projectId: 'your_project_id');\n"
        "    WiredashAnalytics(projectId: 'your_project_id').trackEvent('$eventName');\n"
        "    Wiredash.of(context).trackEvent('$eventName');\n"
        "The event '$eventName' was sent to project '${firstWidgetState.widget.projectId}', because that Wiredash widget was registered first.",
      );
      await firstWidgetState.newEventAdded();
      return;
    }

    final projectInstances = allWidget
        .where((element) => element.widget.projectId == projectId)
        .toList();
    if (projectInstances.isEmpty) {
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "No Wiredash instance was found with projectId $projectId. "
        "Please double check the projectId.",
      );
      return;
    } else {
      // multiple with the same projectId, take the first one
      await projectInstances.first.newEventAdded();
    }

    debugPrint(
      "Multiple Wiredash instances are mounted! "
      "Please specify a projectId to avoid sending events to all instances, "
      "or use Wiredash.of(context).trackEvent() to send events to a specific instance.",
    );
  }
}

Future<void> trackEvent(
  String eventName, {
  Map<String, Object?>? data,
  String? projectId,
}) async {
  final analytics = WiredashAnalytics(projectId: projectId);
  await analytics.trackEvent(eventName, data: data);
}

class AnalyticsEvent {
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

  const AnalyticsEvent({
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

class NoWiredashInstanceFoundException implements Exception {
  NoWiredashInstanceFoundException();
}

class NoProjectIdSpecifiedException implements Exception {
  NoProjectIdSpecifiedException();
}

const List<String> _internalEvents = [
  '#first_launch',
];

final _eventKeyRegExp = RegExp(r'^#?[A-Za-z]+(?: ?[0-9A-Za-z_-]{2,})+$');

/// The event name must be between 3 to 64 characters long
/// Contain only letters (a-zA-Z), numbers (0-9), - and _
/// Must start with a letter (a-zA-Z)
/// Must not contain double spaces
/// Must not contain double or trailing spaces
void validateEventName(String eventName) {
  if (eventName.isEmpty) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must not be empty',
    );
  }

  if (eventName.startsWith('#')) {
    if (!_internalEvents.contains(eventName)) {
      throw ArgumentError.value(
        eventName,
        'eventName',
        'Unknown internal event (starting with #)',
      );
    }
  }

  if (eventName.length < 3 || eventName.length > 64) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must be between 3 and 64 characters long',
    );
  }

  if (eventName.contains('  ')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must not contain double spaces',
    );
  }

  if (eventName.endsWith(' ')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must not contain trailing spaces',
    );
  }

  if (eventName.contains('ä') ||
      eventName.contains('ö') ||
      eventName.contains('ü')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must not contain umlauts',
    );
  }

  String firstChar = String.fromCharCode(eventName.codeUnitAt(0));
  if (firstChar == '#') {
    firstChar = String.fromCharCode(eventName.codeUnitAt(1));
  }
  final regex = RegExp('^[A-Za-z]');
  if (!regex.hasMatch(firstChar)) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name must start with a letter (a-zA-Z)',
    );
  }

  if (!_eventKeyRegExp.hasMatch(eventName)) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      'Event name does not match $_eventKeyRegExp',
    );
  }

  // valid
}

/// Parameters must not contain more than 10 key-value pairs
///
/// Keys must not exceed 128 characters
///
/// Values can be String, int or bool. null is allowed, too.
/// Each value must not exceed 1024 characters (after running them through jsonEncode).
Map<String, Object?> validateParams(
  Map<String, Object?>? params,
  String eventName,
) {
  if (params == null) {
    return {};
  }
  final preprocessed = Map.of(params);

  // drop all keys that exceed the limit
  final keysToRemove = preprocessed.keys.skip(10).toList();
  for (final key in keysToRemove) {
    preprocessed.remove(key);
  }
  if (keysToRemove.isNotEmpty) {
    reportWiredashInfo(
      TooManyEventParametersException(),
      StackTrace.current,
      'Dropped the keys $keysToRemove because the event parameters must not exceed 10 key-value pairs.',
    );
  }

  for (final key in preprocessed.keys.toList()) {
    if (key.length > 128) {
      // drop key because it is too long
      preprocessed.remove(key);
      reportWiredashInfo(
        InvalidEventKeyFormatException(key),
        StackTrace.current,
        'Dropped the key $key of event $eventName because it exceeds 128 characters.',
      );
    }

    if (key == "") {
      preprocessed.remove(key);
      reportWiredashInfo(
        InvalidEventKeyFormatException(key),
        StackTrace.current,
        'Dropped the key "$key" of event $eventName because it is empty.',
      );
    }

    final value = params[key];
    if (value == null || value is int || value is bool) {
      continue;
    }
    if (value is String) {
      final encoded = jsonEncode(value);
      if (encoded.length > 1024) {
        preprocessed.remove(key);
        reportWiredashInfo(
          ArgumentError.value(
            params,
            'data["$key"]',
            'Event parameter value for "$key" has a length of ${encoded.length} '
                'and exceeds the maximum of 1024 characters\n'
                'Encoded Value: $encoded',
          ),
          StackTrace.current,
          'Dropped the key $key of event $eventName because it exceeds 1024 characters.',
        );
      }
      continue;
    }
    // all other types are unsupported
    final type = value.runtimeType;
    preprocessed.remove(key);
    reportWiredashInfo(
      ArgumentError.value(
        params,
        'data["$key"]',
        'Event parameter value for "$key" has an unsupported type $type',
      ),
      StackTrace.current,
      'Dropped the key $key of event $eventName because it has an unsupported type $type.',
    );
  }

  return preprocessed;
}

class TooManyEventParametersException implements Exception {
  TooManyEventParametersException();
}

class InvalidEventKeyFormatException implements Exception {
  final String key;

  InvalidEventKeyFormatException(this.key);
}
