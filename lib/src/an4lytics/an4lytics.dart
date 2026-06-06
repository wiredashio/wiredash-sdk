import 'dart:async';
import 'dart:convert';
import 'dart:isolate';

import 'package:clock/clock.dart';
import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/an4lytics/an4lytics_isolate_message.dart';
import 'package:wiredash/src/an4lytics/an4lytics_upload_router.dart';
import 'package:wiredash/src/an4lytics/ev3nt_store.dart';
import 'package:wiredash/src/an4lytics/isolate_messenger.dart'
    if (dart.library.io) 'package:wiredash/src/an4lytics/isolate_messenger_io.dart';
import 'package:wiredash/src/core/services/error_report.dart';
import 'package:wiredash/src/core/services/services.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_registry.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/utils/disposable.dart';

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
  /// {@macro environmentNameConstraints}
  final String? _environment;

  /// Creates a new instance of [WiredashAnalytics], creating multiple is totally fine.
  /// The events are stored on disk and sent to the server in periodic intervals.
  ///
  /// Set the [projectId] in case you have multiple [Wiredash] widgets with different
  /// projectIds in your app. If you only have one [Wiredash] widget, you can omit the [projectId].
  ///
  /// Set the [environment] of your app, like 'prod', 'dev', 'staging'
  /// Defaults to the environment of the [Wiredash] widget, which itself
  /// defaults to 'dev' for debug builds and 'prod' for release builds.
  ///
  /// It is necessary to set the [environment] in cases when there is no [Wiredash]
  /// widget mounted, like in a background isolate.
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
  ///
  /// Returns a [Future] which completes when the event is stored locally.
  /// Calling `trackEvent()` without `await` is usually fine, unless the app is killed right after it.
  ///
  /// Submission to the server will happen later in batches in the background.
  /// This method never crashes, instead it reports errors to [FlutterError.onError] or [FlutterError.presentError].
  ///
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
  /// When calling [trackEvent] from a background isolate, the event is stored
  /// locally and the background isolate wakes the main isolate to upload it.
  /// If no [Wiredash] widget is mounted yet, the event is sent with the next
  /// batch or when the app goes to the background.
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
    final Map<String, Object?> eventData;
    try {
      validateEventName(eventName);
      eventData = validateEventData(data, eventName);

      final wiredash = _findWiredashInstance(_projectId, _environment);
      _services.updateWidget(wiredash?.widget);
    } catch (e, stackTrace) {
      reportWiredashError(e, stackTrace, 'Failed to track event $eventName');
      return;
    }
    try {
      final String environment =
          _environment ?? await _services.environmentDetector.getEnvironment();

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
      unawaited(_notifyWiredashInstance(_projectId, _environment, eventName));
    } catch (e, stackTrace) {
      reportWiredashInfo(e, stackTrace, 'Failed to track event $eventName');
    }
  }

  /// Submits all pending analytics events to the server.
  ///
  /// Usually, events are submitted automatically, batched every 30 seconds, and
  /// when the app goes to the background.
  ///
  /// This method wakes the matching mounted [Wiredash] widget and asks it to
  /// submit pending events immediately.
  ///
  /// From a background isolate, this method only wakes the main isolate.
  /// The returned [Future] completes after the wake-up request was sent, not
  /// after the upload finished.
  Future<void> forceSubmitEvents() async {
    await _notifyWiredashInstance(
      _projectId,
      _environment,
      'forceSubmitEvents',
      submitImmediately: true,
    );
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

  /// Notifies the [Wiredash] instance that should upload the just-tracked event.
  ///
  /// On a background isolate there is no mounted widget, so it wakes the main
  /// isolate (see [registerMainIsolateAnalyticsListener]); the main isolate then
  /// routes to the matching instance via [notifyMatchingWiredashInstance], the
  /// same way a main-isolate event does.
  Future<void> _notifyWiredashInstance(
    String? projectId,
    String? environment,
    String eventName, {
    bool submitImmediately = false,
  }) async {
    final message = AnalyticsIsolateMessage(
      projectId: projectId,
      environment: environment,
      eventName: eventName,
      submitImmediately: submitImmediately,
    );
    final bool isMainIsolate = Isolate.current.debugName == 'main';
    if (isMainIsolate) {
      await notifyMatchingWiredashInstance(message);
      return;
    }

    notifyMainIsolateOfAnalyticsEvent(message);
  }

  @override
  String toString() {
    return 'WiredashAnalytics{projectId: $_projectId, environment: $_environment}';
  }
}

Disposable? _analyticsRegistryListenerRegistration;
Disposable? _analyticsIsolateListenerRegistration;

/// Ensures analytics keeps one process-wide isolate listener while at least one
/// [Wiredash] widget is mounted.
void ensureAnalyticsIsolateListenerRegistered() {
  if (_analyticsRegistryListenerRegistration != null) {
    return;
  }

  _analyticsRegistryListenerRegistration =
      WiredashRegistry.instance.addListener(
    _syncAnalyticsIsolateListener,
  );
  _syncAnalyticsIsolateListener();
}

void _syncAnalyticsIsolateListener() {
  final hasWidgets = WiredashRegistry.instance.referenceCount > 0;
  if (hasWidgets) {
    _analyticsIsolateListenerRegistration ??=
        registerMainIsolateAnalyticsListener();
    return;
  }

  _analyticsIsolateListenerRegistration?.dispose();
  _analyticsIsolateListenerRegistration = null;
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
