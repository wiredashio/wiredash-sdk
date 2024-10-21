import 'dart:convert';
import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/analytics/event_store.dart';
import 'package:wiredash/src/core/options/environment_loader.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

/// Interact with the Wiredash Analytics service.
///
/// This class provides a convenient way to track events and send them to the
/// Wiredash Console.
///
/// This class makes it easy to inject and mock the [trackEvent] method for testing.
/// For simple scenarios, call [Wiredash.trackEvent] directly.
class WiredashAnalytics {
  /// Optional [projectId] in case multiple [Wiredash] widgets with different
  /// projectIds are used at the same time
  final String? _projectId;

  /// The environment of your app, like 'prod', 'dev', 'staging'
  ///
  /// Only required when
  /// - Send events to a different environment than the one set in the [Wiredash] widget
  /// - No [Wiredash] widget present, like in a background isolate
  ///
  /// Defaults to 'dev' for debug builds and 'prod' for release builds.
  ///
  /// Setting an environment is useful to differentiate between different
  /// versions of your app allowing you to filter analytics and feedback by
  /// environment.
  ///
  /// White-label apps can use this to differentiate between different clients,
  /// when they share the same Wiredash project.
  ///
  /// The environment needs to be
  /// - at least 2 characters long, max 32 characters
  /// - only use lowercase a-z, - and _
  /// - start with a letter (a-z)
  final String? _environment;

  /// Creates a new instance of [WiredashAnalytics], creating multiple is totally fine.
  /// The events are stored on disk and sent to the server in periodic intervals.
  ///
  /// Set the [projectId] in case you have multiple [Wiredash] widgets with different
  /// projectIds in your app. If you only have one [Wiredash] widget, you can omit the [projectId].
  WiredashAnalytics({
    String? projectId,
    String? environment,
  })  : _projectId = projectId,
        _environment = environment {
    if (environment != null) {
      validateEnvironment(environment);
    }
  }

  /// All services used by Wiredash, but no shared memory with the [WiredashState] services.
  final WiredashServices _services = WiredashServices();

  /// Tracks an event with Wiredash.
  ///
  /// This method allows you to record user interactions or other significant
  /// occurrences within your app and send them to the Wiredash service for
  /// analysis.
  ///
  /// ```dart
  /// final analytics = WiredashAnalytics();
  /// await analytics.trackEvent('button_tapped', data: {
  ///  'button_id': 'submit_button',
  /// });
  /// ```
  /// ### [eventName] constraints
  /// {@macro eventNameConstraints}
  ///
  /// ### [data] constraints
  /// {@macro eventDataConstraints}
  ///
  /// **Event Sending Behavior:**
  ///
  /// * Events are batched and sent to the Wiredash server periodically at 30-second intervals.
  /// * The first batch of events is sent after a 5-second delay.
  /// * Events are also sent immediately when the app goes to the background (not applicable to web platforms).
  /// * If events cannot be sent due to network issues, they are stored locally and retried later.
  /// * Unsent events are discarded after 3 days.
  ///
  /// **Multiple Wiredash Widgets:**
  ///
  /// If you have multiple [Wiredash] widgets in your app with different projectIds,
  /// you can specify the desired [projectId] when creating [WiredashAnalytics].
  /// This ensures that the event is sent to the correct project.
  ///
  /// If no [projectId] is provided and multiple widgets are mounted, the event will be sent to
  /// the project associated with the first mounted widget. A warning message will also be logged
  /// to the console in this scenario.
  ///
  /// **Background Isolates:**
  ///
  /// When calling [trackEvent] from a background isolate, the event will be stored locally.
  /// The main isolate will pick up these events and send them along with the next batch or
  /// when the app goes to the background.
  ///
  /// **See also**
  ///
  /// Use [Wiredash.trackEvent] for easy access from everywhere in your app.
  ///
  /// ```dart
  /// await Wiredash.trackEvent('Click Button', data: {/**/});
  /// ```
  ///
  /// Access the correct [Wiredash] project via context to send events to if you
  /// use multiple Wiredash widgets in your app. This way you don't have to
  /// specify the [projectId] every time you call [trackEvent].
  ///
  /// ```dart
  /// Wiredash.of(context).trackEvent('Click Button');
  /// ```
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? data,
  }) async {
    validateEventName(eventName);
    final eventData = validateEventData(data, eventName);

    final wiredash = _findWiredashInstance(_projectId, _environment);
    _services.updateWidget(wiredash?.widget);

    final String environment =
        _environment ?? await _services.environmentLoader.getEnvironment();

    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final flutterInfo = _services.metaDataCollector.collectFlutterInfo();
    final analyticsId = await _services.wuidGenerator.appUsageId();

    final event = AnalyticsEvent(
      analyticsId: analyticsId,
      buildCommit: fixedMetadata.resolvedBuildCommit,
      buildNumber: fixedMetadata.resolvedBuildNumber,
      buildVersion: fixedMetadata.resolvedBuildVersion,
      bundleId: fixedMetadata.appInfo.bundleId,
      createdAt: clock.now(),
      eventData: eventData,
      eventName: eventName,
      environment: environment,
      platformOS: flutterInfo.platformOS,
      platformOSVersion: fixedMetadata.deviceInfo.osVersion,
      platformLocale: flutterInfo.platformLocale,
      sdkVersion: wiredashSdkVersion,
    );

    await _services.eventStore.saveEvent(event, _projectId);
    await _notifyWiredashInstance(_projectId, _environment, eventName);
  }

  /// Finds the intrinsic matching [Wiredash] widget to gather information from,
  /// usually the only mounted one, or the one that matches the [projectId] and/or [environment].
  ///
  /// The 95% case is that a single mounted [Wiredash] widget is found and used.
  ///
  /// If no matching widget is found, the developer must provide the information in the constructor.
  WiredashState? _findWiredashInstance(
    String? projectId,
    String? environment,
  ) {
    final allWidget = WiredashRegistry.instance.allWidgets;

    return allWidget.firstWhereOrNull((state) {
      return (projectId == null || state.widget.projectId == projectId) &&
          (environment == null || state.widget.environment == environment);
    });
  }

  /// Checks the currently mounted [Wiredash] widgets and notifies the correct one
  /// to send the event.
  /// This ensures only a single instance sends the event on the main isolate,
  /// making batching and sending more efficient.
  Future<void> _notifyWiredashInstance(
    String? projectId,
    String? environment,
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
      final WiredashState state = allWidget.first;
      final widget = state.widget;
      if (projectId == null || widget.projectId == projectId) {
        // projectId and environment match when set, notify the only and correct Wiredash instance
        await state.triggerAnalyticsEventUpload();
        return;
      }
      // The only registered Wiredash instance has a different projectId
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "Wiredash is registered with projectId:${widget.projectId}. "
        "The event event '$eventName' was explicit sent to projectId projectId:$projectId. "
        "No Wiredash instance was found with projectId:$projectId. "
        "Please double check the projectId.",
      );
      return;
    }
    assert(allWidget.length > 1, "Multiple Wiredash instances are mounted.");

    if (projectId == null) {
      final firstWidgetState = allWidget.first;

      final ids = allWidget.map((e) {
        return "projectId:${e.widget.projectId}/environment:${e.widget.environment}";
      }).join(", ");
      reportWiredashInfo(
        NoProjectIdSpecifiedException(),
        StackTrace.current,
        "Multiple Wiredash instances with different projectIds are mounted ($ids). "
        "Please specify a projectId when using multiple Wiredash instances like this:\n"
        "    Wiredash.trackEvent('$eventName', projectId: 'your_project_id');\n"
        "    WiredashAnalytics(projectId: 'your_project_id').trackEvent('$eventName');\n"
        "    Wiredash.of(context).trackEvent('$eventName');\n"
        "The event '$eventName' was sent to project '${firstWidgetState.widget.projectId} "
        "because that Wiredash widget was registered first.",
      );
      await firstWidgetState.triggerAnalyticsEventUpload();
      return;
    }

    // Use first matching Wiredash instance by projectId. environment does not matter
    final projectInstances = allWidget
        .where((element) => element.widget.projectId == projectId)
        .toList();

    if (projectInstances.isEmpty) {
      reportWiredashInfo(
        NoWiredashInstanceFoundException(),
        StackTrace.current,
        "No Wiredash instance was found with projectId:$projectId. "
        "Please double check the projectId.",
      );
      return;
    } else {
      // multiple with the same projectId, take the first one
      await projectInstances.first.triggerAnalyticsEventUpload();
    }

    debugPrint(
      "Multiple Wiredash instances are mounted! "
      "Please specify a projectId to avoid sending events to all instances, "
      "or use Wiredash.of(context).trackEvent() to send events to a specific instance.",
    );
  }

  @override
  String toString() {
    return 'WiredashAnalytics{projectId: $_projectId, environment: $_environment}';
  }
}

/// Reported when [WiredashAnalytics.trackEvent] but no [Wiredash] widget is mounted.
///
/// This warning is only throw on the main isolate, where the [Wiredash] widget
/// is expected to be always mounted.
class NoWiredashInstanceFoundException implements Exception {
  NoWiredashInstanceFoundException();
}

/// Reported when multiple [Wiredash] widgets with different projectIds are
/// mounted but [Wiredash.trackEvent] is called without a [projectId].
class NoProjectIdSpecifiedException implements Exception {
  NoProjectIdSpecifiedException();
}

/// This is the complete list of internal events that Wiredash uses.
/// Those events should not be used by the user, only the SDK itself.
const List<String> _internalEvents = [
  '#firstLaunch',
];

/// The complete regular expression to validate a event name.
///
/// All checks in validateEventName are based on this regular expression but
/// are split up for better error messages.
final _eventNameRegExp = RegExp(r'^#?[A-Za-z]+(?: ?[0-9A-Za-z_-]{2,})+$');

/// Validates the event name.
///
/// {@template eventNameConstraints}
/// - The event name must be between 3 to 64 characters long
/// - Contain only letters (a-zA-Z), numbers (0-9), - and _ and spaces
/// - Must start with a letter (a-zA-Z)
/// - Must not contain double spaces
/// - Must not contain double or trailing spaces
/// {@endtemplate}
void validateEventName(String eventName) {
  if (eventName.isEmpty) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName must not be empty',
    );
  }

  if (eventName.startsWith('#')) {
    if (!_internalEvents.contains(eventName)) {
      throw ArgumentError.value(
        eventName,
        'eventName',
        '$eventName is an unknown internal event (starting with #)',
      );
    }
  }

  if (eventName.length < 3 || eventName.length > 64) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName must be between 3 and 64 characters long',
    );
  }

  if (eventName.contains('  ')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName must not contain double spaces',
    );
  }

  if (eventName.endsWith(' ')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName must not contain trailing spaces',
    );
  }

  if (eventName.contains('ä') ||
      eventName.contains('ö') ||
      eventName.contains('ü')) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName must not contain umlauts',
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
      '$eventName must start with a letter (a-zA-Z)',
    );
  }

  if (!_eventNameRegExp.hasMatch(eventName)) {
    throw ArgumentError.value(
      eventName,
      'eventName',
      '$eventName does not match $_eventNameRegExp',
    );
  }

  // valid
}

/// Validates the event data of [WiredashAnalytics.trackEvent].
///
/// {@template eventDataConstraints}
/// - Parameters must not contain more than 10 key-value pairs
/// - Keys must not exceed 128 characters
/// - Keys must not be empty
/// - Values can be String, int or bool. null is allowed, too.
/// - Each individual value must not exceed 1024 characters (after running them through jsonEncode).
/// {@endtemplate}
Map<String, Object?> validateEventData(
  Map<String, Object?>? data,
  String eventName,
) {
  if (data == null) {
    return {};
  }
  final preprocessed = Map.of(data);

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

    final value = data[key];
    if (value == null || value is bool || value is int || value is double) {
      // primitives are supported without further checks
      continue;
    }
    if (value is DateTime) {
      preprocessed[key] = value.toIso8601String();
      continue;
    }
    if (value is String) {
      final encoded = jsonEncode(value);
      if (encoded.length > 1024) {
        preprocessed.remove(key);
        reportWiredashInfo(
          ArgumentError.value(
            data,
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
        data,
        'data["$key"]',
        'Event parameter value for "$key" has an unsupported type $type',
      ),
      StackTrace.current,
      'Dropped the key $key of event $eventName because it has an unsupported type $type.',
    );
  }

  return preprocessed;
}

/// Reported when the event parameters exceed the limit of 10 key-value pairs.
/// Additional parameters are dropped.
class TooManyEventParametersException implements Exception {
  TooManyEventParametersException();
}

/// Event key does not match the required format, and is therefore dropped.
///
/// {@macro eventNameConstraints}
class InvalidEventKeyFormatException implements Exception {
  final String key;

  InvalidEventKeyFormatException(this.key);
}
