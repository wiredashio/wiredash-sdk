import 'dart:collection';
import 'dart:convert';

import 'package:clock/clock.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

// TODO send events directly on web
// TODO how to handle when two instances of the app, with two different wiredash configurations are open. Where would events be sent to?
// TODO make sure that ad blockers don't crash the submission
// TODO save events to local storage
// TODO send events every 30 seconds to the server (or 5min?)
// TODO wipe events older than 3 days
// TODO Save projectId together with event
// TODO save events individually with key "{projectId}_{timestamp}"
// TODO handle different isolates
// TODO delete events when storage exceeds 1MB
// TODO validate event name and parameters
// TODO make the projectId "default" by default
// TODO check if we can replace Wiredash.of(context).method() with just Wiredash.method()

class WiredashAnalytics {
  /// Optional [projectId] in case multiple [Wiredash] widgets with different
  /// projectIds are used at the same time
  final String? projectId;

  WiredashAnalytics({
    this.projectId,
  });
  //
  // bool _initialized = false;
  //
  // void _initialize() {
  //   if (_initialized) {
  //     return;
  //   }
  //   // TODO inject?
  //   const ProjectCredentialValidator().validate(
  //     projectId: projectId,
  //     secret: secret,
  //   );
  //   // TODO inject client?
  //   final api =
  //       WiredashApi(secret: secret, projectId: projectId, httpClient: Client());
  //   _eventSubmitter = DirectEventSubmitter(api: api);
  //   _initialized = true;
  // }
  //
  // /// A way to access the services during testing
  // @visibleForTesting
  // // TODO find better way to initialize the services in tests, so that the real services are never created
  // WiredashAnalyticsServices get debugServices {
  //   if (kReleaseMode) {
  //     throw "Services can't be accessed in production code";
  //   }
  //   return WiredashAnalyticsServices();
  // }
  //
  // late final EventSubmitter _eventSubmitter;

  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? params,
  }) async {
    final event = Event.internal(
      name: eventName,
      params: params,
      timestamp: clock.now(),
    );

    final prefs = await SharedPreferences.getInstance();
    await prefs.reload();

    final project = projectId ?? "default";
    final millis = event.timestamp!.millisecondsSinceEpoch ~/ 1000;
    final discriminator =
        nanoid(length: 6, alphabet: Alphabet.alphanumeric /* no dash ("-")*/);
    final key = "$project-$millis-$discriminator";

    await prefs.setString(key, jsonEncode(serializeEvent(event)));
    print('Saved event $key to disk');

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
}

Map<String, Object?> serializeEvent(Event event) {
  final values = SplayTreeMap<String, Object?>.from({
    "name": event.name,
    "version": 1,
    "timestamp": event.timestamp?.toIso8601String(),
  });

  final paramsValidated = event.params?.map((key, value) {
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
      values.addAll({'params': paramsValidated});
    }
  }
  return values;
}

Event deserializeEvent(Map<String, Object?> map) {
  final version = map['version'] as int?;
  if (version == 1) {
    final name = map['name'] as String?;
    final params = map['params'] as Map<String, Object?>?;
    final timestampRaw = map['timestamp'] as String?;
    return Event.internal(
      name: name!,
      params: params,
      timestamp: DateTime.parse(timestampRaw!),
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

class Event {
  final String name;
  final Map<String, Object?>? params;
  final DateTime? timestamp;

  Event({
    required this.name,
    required this.params,
  }) : timestamp = null;

  Event.internal({
    required this.name,
    required this.params,
    required this.timestamp,
  });
}

abstract class EventSubmitter {
  Future<void> submitEvent(Event event);
}

class DirectEventSubmitter implements EventSubmitter {
  final WiredashApi api;

  DirectEventSubmitter({required this.api});

  @override
  Future<void> submitEvent(Event event) async {
    throw UnimplementedError();
    // TODO send event to server
  }
}

class PendingEventSubmitter implements EventSubmitter {
  final Future<SharedPreferences> Function() sharedPreferences;
  final WiredashApi api;

  PendingEventSubmitter({
    required this.sharedPreferences,
    required this.api,
  });

  @override
  Future<void> submitEvent(Event event) async {
    final prefs = await sharedPreferences();
    await prefs.reload();
    // persist event to disk
    // TODO how to get the projectId?
    // prefs.setString("{projectId}_{timestamp}", serializeEvent(eventName, params));}
  }
}

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

//
//
//
//
// final Wiredash wiredash = Wiredash(
//     projectId: 'YOUR-PROJECT-ID',
//     secret: 'YOUR-SECRET',
// );
//
//
// void main() {
//   wiredash.trackEvent('test_event');
//
//   void build(BuildContext context) {
//     return wiredash.widget(
//         config: wiredashConfig,
//         child: MyApp();
//     );
//   }
// }
