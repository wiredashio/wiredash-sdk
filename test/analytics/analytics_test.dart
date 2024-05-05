import 'dart:convert';
import 'dart:io';

import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart';
import 'package:http/testing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/analytics/event_store.dart';

import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/network/wiredash_api.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/wiredash.dart';

import '../util/flutter_error.dart';
import '../util/invocation_catcher.dart';
import '../util/mock_api.dart';
import '../util/robot.dart';
import '../util/wiredash_tester.dart';

void main() {
  testWidgets('sendEvent (static)', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () {
              Wiredash.trackEvent('test_event', data: {'param1': 'value1'});
            },
            child: const Text('Send Event'),
          ),
        );
      },
    );

    final now = clock.now();
    await robot.tapText('Send Event');
    await tester.pumpSmart();

    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0] as List<RequestEvent>?;
    expect(events, hasLength(1));
    final event = events![0];
    expect(event.eventName, 'test_event');
    expect(event.eventData, {'param1': 'value1'});
    expect(event.analyticsId, isNotNull);
    expect(event.buildCommit, null);
    expect(event.buildNumber, '9001');
    expect(event.buildVersion, '9.9.9');
    expect(event.bundleId, 'io.wiredash.test');
    expect(event.createdAt, now);
    expect(event.platformOS, isNotNull);
    if (!Platform.isLinux) {
      expect(event.platformOSVersion, '10.0.1');
    }
    expect(event.platformLocale, isNotNull);
    expect(event.sdkVersion, wiredashSdkVersion);
  });

  testWidgets('sendEvent (instance)', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () {
              final analytics = WiredashAnalytics();
              analytics.trackEvent('test_event', data: {'param1': 'value1'});
            },
            child: const Text('Send Event'),
          ),
        );
      },
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0] as List<RequestEvent>?;
    expect(events, hasLength(1));
    final event = events![0];
    expect(event.eventName, 'test_event');
    expect(event.eventData, {'param1': 'value1'});
  });

  testWidgets('sendEvent (context)', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () async {
              await Wiredash.of(context)
                  .trackEvent('test_event', data: {'param1': 'value1'});
            },
            child: const Text('Send Event'),
          ),
        );
      },
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0] as List<RequestEvent>?;
    expect(events, hasLength(1));
    final event = events![0];
    expect(event.eventName, 'test_event');
    expect(event.eventData, {'param1': 'value1'});
  });

  testWidgets(
      'sendEvent top-level with two instances - '
      'forwards to the first registered with warning - order 1',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      wrapWithWiredash: false,
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              const Expanded(
                child: Wiredash(
                  projectId: 'project1',
                  secret: 'secret',
                  child: SizedBox(),
                ),
              ),
              const Expanded(
                child: Wiredash(
                  projectId: 'project2',
                  secret: 'secret',
                  child: SizedBox(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Wiredash.trackEvent('test_event');
                },
                child: const Text('Send Event'),
              ),
            ],
          ),
        );
      },
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    final api1 = robot.servicesForProject('project1').api as MockWiredashApi;
    final api2 = robot.servicesForProject('project2').api as MockWiredashApi;
    api1.sendEventsInvocations.verifyInvocationCount(1);
    api2.sendEventsInvocations.verifyInvocationCount(0);
  });

  testWidgets(
      'sendEvent top-level with two instances - '
      'forwards to the first registered with warning - order 2',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      wrapWithWiredash: false,
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              const Expanded(
                child: Wiredash(
                  projectId: 'project2',
                  secret: 'secret',
                  child: SizedBox(),
                ),
              ),
              const Expanded(
                child: Wiredash(
                  projectId: 'project1',
                  secret: 'secret',
                  child: SizedBox(),
                ),
              ),
              ElevatedButton(
                onPressed: () async {
                  await Wiredash.trackEvent('test_event');
                },
                child: const Text('Send Event'),
              ),
            ],
          ),
        );
      },
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    final api1 = robot.servicesForProject('project1').api as MockWiredashApi;
    final api2 = robot.servicesForProject('project2').api as MockWiredashApi;
    api1.sendEventsInvocations.verifyInvocationCount(0);
    api2.sendEventsInvocations.verifyInvocationCount(1);
  });

  testWidgets('sendEvent is blocked by ad blocker', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: ElevatedButton(
            onPressed: () {
              final analytics = WiredashAnalytics();
              analytics.trackEvent('test_event', data: {'param1': 'value1'});
            },
            child: const Text('Send Event'),
          ),
        );
      },
    );
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      throw 'Blocked by ad blocker';
    };

    await robot.tapText('Send Event');
    await tester.pumpSmart();
    await robot.tapText('Send Event');
    await tester.pumpSmart();

    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(2);

    final pending = await robot.services.eventStore.getEvents('test');
    expect(pending, hasLength(2));
  });

  testWidgets('1mb size limit', (tester) async {
    final errors = captureFlutterErrors();
    final robot = WiredashTestRobot(tester);

    const eventToInsert = 120;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final analytics = WiredashAnalytics();
                  const oneKb = 1024;
                  for (var i = 0; i < eventToInsert; i++) {
                    await analytics.trackEvent(
                      'big',
                      data: {
                        'param1': "".padLeft(oneKb - 2, '0'),
                        'param2': "".padLeft(oneKb - 2, '1'),
                        'param3': "".padLeft(oneKb - 2, '2'),
                        'param4': "".padLeft(oneKb - 2, '3'),
                        'param5': "".padLeft(oneKb - 2, '4'),
                        'param6': "".padLeft(oneKb - 2, '5'),
                        'param7': "".padLeft(oneKb - 2, '6'),
                        'param8': "".padLeft(oneKb - 2, '7'),
                        'param9': "".padLeft(oneKb - 2, '8'),
                        'param10': "".padLeft(oneKb - 2, '9'),
                      },
                    );
                  }
                },
                child: const Text('Big Event'),
              ),
              ElevatedButton(
                onPressed: () async {
                  final analytics = WiredashAnalytics();
                  await analytics.trackEvent('small');
                },
                child: const Text('Small Event'),
              ),
            ],
          ),
        );
      },
    );
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      throw 'offline';
    };

    await robot.tapText('Big Event');
    await tester.pumpSmart();
    await robot.tapText('Small Event');
    await tester.pumpSmart();

    errors.restoreDefaultErrorHandlers();
    expect(errors.errors, isEmpty);
    final presentErrors = errors.warnings
        .where((element) => !element.toString().contains('offline'));
    expect(presentErrors, isEmpty);

    // always save the last events
    final pending = await robot.services.eventStore.getEvents('test');
    expect(pending, hasLength(99)); // which is less than 120 (eventToInsert)

    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0]! as List<RequestEvent>;
    expect(
      events.any((event) => event.eventName == 'small'),
      isTrue,
      reason: 'small event should be sent,'
          ' ${events.map((e) => e.eventData).join(',')}',
    );
  });

  testWidgets('default events are submitted with the next Wiredash instance',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();
    await robot.regenerateAnalyticsId();
    await tester.pumpWidget(
      // No Wiredash widget
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              Wiredash.trackEvent(
                'test_event',
                data: {
                  'param1': 'value1',
                },
              );
            },
            child: const Text('Send Event'),
          ),
        ),
      ),
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    // event is saved locally for the "default" project
    final eventStore = PersistentAnalyticsEventStore(
      sharedPreferences: SharedPreferences.getInstance,
    );
    final eventsOnDisk = await eventStore.getEvents('default');
    expect(eventsOnDisk, hasLength(1));

    // When a wiredash Widget is added to the tree, the events are sent
    await robot.launchApp();
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(0);
    await tester.pumpSmart(const Duration(seconds: 5));
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
  });

  testWidgets(
      'project events are only submitted by the correct Wiredash instance',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();
    await robot.regenerateAnalyticsId();
    await tester.pumpWidget(
      // No Wiredash widget
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              Wiredash.trackEvent('test_event', projectId: 'project1');
            },
            child: const Text('Send Event'),
          ),
        ),
      ),
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    // event is saved locally for project1
    final eventStore = PersistentAnalyticsEventStore(
      sharedPreferences: SharedPreferences.getInstance,
    );
    final eventsOnDisk = await eventStore.getEvents('project1');
    expect(eventsOnDisk, hasLength(1));
    final defaultEventsOnDisk = await eventStore.getEvents('default');
    expect(defaultEventsOnDisk, hasLength(0));

    // other-project does not submit the event
    await robot.launchApp(projectId: 'other-project');
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(0);
    await tester.pumpSmart(const Duration(seconds: 5));
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(0);

    // project1 does
    await robot.launchApp(projectId: 'project1');
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(0);
    await tester.pumpSmart(const Duration(seconds: 5));
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
  });

  testWidgets('wipe events older than 3 days', (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();
    await robot.regenerateAnalyticsId();
    await tester.pumpWidget(
      // No Wiredash widget
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              Wiredash.trackEvent('test_event', projectId: 'projectX');
            },
            child: const Text('Send Event'),
          ),
        ),
      ),
    );

    // insert some old events
    await robot.tapText('Send Event');
    await tester.pumpSmart();
    await tester.pump(const Duration(days: 1));
    await robot.tapText('Send Event');
    await tester.pumpSmart();

    final eventStore = PersistentAnalyticsEventStore(
      sharedPreferences: SharedPreferences.getInstance,
    );
    final eventsOnDisk1 = await eventStore.getEvents('projectX');
    expect(eventsOnDisk1, hasLength(2));

    // jump to 3 days in the future
    await tester.pump(const Duration(days: 2));

    // restart the app
    await robot.launchApp(projectId: 'projectX');
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      throw 'offline';
    };
    final eventsOnDisk2 = await robot.services.eventStore.getEvents('projectX');
    expect(eventsOnDisk2, hasLength(2));

    final eventsOnDisk3 = await robot.services.eventStore.getEvents('projectX');
    expect(eventsOnDisk3, hasLength(2));

    // wait for submission
    final future = ResultFuture(
      robot.mockServices.services.syncEngine.onEvent(SdkEvent.appStartDelayed),
    );
    await tester.waitUntil(() => future.isComplete, isTrue);

    // Tried to submit only the one that is not older than 3 days
    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
    final submittedEvents = robot.mockServices.mockApi.sendEventsInvocations
        .latest[0]! as List<RequestEvent>;
    expect(submittedEvents, hasLength(1));

    // keep only that one on disk because submission failed
    final eventsOnDisk4 = await robot.services.eventStore.getEvents('projectX');
    expect(eventsOnDisk4, hasLength(1));
  });

  group('batching', () {
    testWidgets('submit events after app moves to background', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();
      robot.mockServices.mockApi.sendEventsInvocations.interceptor =
          (invocation) async {
        throw 'offline';
      };
      await robot.triggerAnalyticsEvent();
      robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
      final eventsOnDisk = await robot.services.eventStore.getEvents('test');
      expect(eventsOnDisk, hasLength(1));

      await robot.moveAppToBackground();
      robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(2);
    });

    testWidgets(
        'send first event immediately, then after 5s, then after 30s continuously',
        (tester) async {
      final start = clock.now();
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(useDirectEventSubmitter: false);
      for (int i = 0; i < 65; i++) {
        await robot.triggerAnalyticsEvent();
        await tester.pumpSmart(const Duration(seconds: 1));
      }
      final diff = clock.now().difference(start);
      expect(diff, const Duration(seconds: 65)); // one event each second

      final List<AssertableInvocation> calls =
          robot.mockServices.mockApi.sendEventsInvocations.invocations;
      final batches = calls.map((e) => e[0]! as List<RequestEvent>).toList();
      expect(batches, hasLength(3));
      expect(batches[0], hasLength(5));
      expect(batches[1], hasLength(30));
      expect(batches[2], hasLength(30));
    });

    testWidgets('send event immediately when no event was sent for 30s',
        (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp(useDirectEventSubmitter: false);

      // send first event to kick things off
      await robot.triggerAnalyticsEvent();
      await tester.pumpSmart(const Duration(seconds: 1));

      await tester.pumpSmart(const Duration(seconds: 60));
      await robot.triggerAnalyticsEvent();
      await tester.pumpSmart(const Duration(milliseconds: 1));

      final List<AssertableInvocation> calls =
          robot.mockServices.mockApi.sendEventsInvocations.invocations;
      final batches = calls.map((e) => e[0]! as List<RequestEvent>).toList();
      expect(batches, hasLength(2));
      expect(batches[0], hasLength(1));
      expect(batches[1], hasLength(1));
    });
  });

  testWidgets('Server marks event as illegal - code 2200', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    final errors = captureFlutterErrors();
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      final httpClient = MockClient((request) async {
        final body = jsonEncode(
          {
            "warnings": [
              {
                "index": 0,
                "code": 2200,
                "message":
                    'Event at index 0: {\n  "analyticsId": "Bp8RNRpLMgmtMNLD",\n  "buildNumber": "1",\n  "buildVersion": "1.0.0",\n  "bundleId": "wiredash_theming",\n  "createdAt": 1714430633384,\n  "eventData": {\n    "index": 9\n  },\n  "platformLocale": "en-GB",\n  "sdkVersion": 215,\n  "eventName" [1]: "illegal asdfadfasdfasdf}|"" fails to match the required pattern: /^#?(?:[0-9A-Za-z_-]+ ?)+\$/',
              },
            ],
          },
        );
        // Real world example
        // {
        //     "warnings": [
        //         {
        //             "index": 0,
        //             "code": 2200,
        //             "message": "Event at index 0: {\n  \"analyticsId\": \"Bp8RNRpLMgmtMNLD\",\n  \"buildNumber\": \"1\",\n  \"buildVersion\": \"1.0.0\",\n  \"bundleId\": \"wiredash_theming\",\n  \"createdAt\": 1714430633384,\n  \"eventData\": {\n    \"index\": 9\n  },\n  \"platformLocale\": \"en-GB\",\n  \"sdkVersion\": 215,\n  \"eventName\" [1]: \"illegal ^asdfadfasdfasdf\"\" fails to match the required pattern: /^#?(?:[0-9A-Za-z_-]+ ?)+$/"
        //         },
        //     ]
        // }
        return Response.bytes(body.codeUnits, 200);
      });
      final context =
          ApiClientContext(httpClient: httpClient, secret: '', projectId: '');
      return postSendEvents(
        context,
        'url',
        invocation.positionalArguments[0] as List<RequestEvent>,
      );
    };

    await robot.triggerAnalyticsEvent();
    await tester.idle();

    errors.restoreDefaultErrorHandlers();
    expect(errors.errors, isEmpty);
    expect(
      errors.warningText,
      contains(
        'Event "default_event" was rejected by the server due to an invalid format',
      ),
    );
    expect(
      errors.warningText,
      contains('fails to match the required pattern'),
    );
    expect(
      errors.warningText,
      contains('code: 2200'),
    );

    // no events are left to be resubmitted
    final eventsOnDisk = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk, hasLength(0));
  });

  testWidgets('Server could not handle requests - code 2201', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    final errors = captureFlutterErrors();
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      const body =
          '{"errorCode": 2201, "errorMessage": "can not process events at the moment"}';
      final response = Response(body, 400);
      throw CouldNotHandleRequestException(response: response);
    };

    await robot.triggerAnalyticsEvent();

    errors.restoreDefaultErrorHandlers();
    expect(errors.errors, isEmpty);
    expect(
      errors.warningText,
      contains('Could not submit events to backend. Retrying later.'),
    );
    expect(
      errors.warningText,
      contains('can not process events at the moment'),
    );
    expect(
      errors.warningText,
      contains('code: 400'),
    );
    expect(
      errors.warningText,
      contains('[2201]'),
    );

    // all events will be resubmitted at a later point
    final eventsOnDisk = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk, hasLength(1));
  });

  testWidgets('Drop events for unauthorized requests', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    final errors = captureFlutterErrors();
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      final httpClient = MockClient((request) async {
        return Response.bytes([], 401); // unauthorized
      });

      final context =
          ApiClientContext(httpClient: httpClient, secret: '', projectId: '');
      return postSendEvents(
        context,
        'url',
        invocation.positionalArguments[0] as List<RequestEvent>,
      );
    };

    await robot.triggerAnalyticsEvent();
    await tester.idle();

    errors.restoreDefaultErrorHandlers();
    expect(errors.warningText, contains('UnauthenticatedWiredashApiException'));
    expect(errors.warningText, contains("Invalid projectId: '', secret: ''"));

    // events have been dropped, to prevent spamming the server with invalid credentials
    final eventsOnDisk = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk, hasLength(0));
  });

  testWidgets('Server could not handle requests - statuscode 500',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    final errors = captureFlutterErrors();
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      throw WiredashApiException(response: Response('', 500));
    };

    await robot.triggerAnalyticsEvent();

    errors.restoreDefaultErrorHandlers();
    expect(errors.errors, isEmpty);
    expect(
      errors.warningText,
      contains('Could not submit events to backend. Retrying later.'),
    );

    // all events will be resubmitted at a later point
    final eventsOnDisk = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk, hasLength(1));
  });

  testWidgets(
      'server drops custom events of free projects - Reports PaidFeatureException once',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    final errors = captureFlutterErrors();
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      final httpClient = MockClient((request) async {
        final body = jsonEncode(
          {
            "warnings": [
              {
                "code": 2003,
                "index": 0,
                "message":
                    "Dropped event at index 0: Custom events are only available on paid plans. Current plan is 'free'.",
              },
            ],
          },
        );
        return Response.bytes(body.codeUnits, 200);
      });
      final context =
          ApiClientContext(httpClient: httpClient, secret: '', projectId: '');
      return postSendEvents(
        context,
        'url',
        invocation.positionalArguments[0] as List<RequestEvent>,
      );
    };

    await robot.triggerAnalyticsEvent();
    await tester.idle();

    errors.restoreDefaultErrorHandlers();
    expect(errors.errors, isEmpty);
    expect(errors.warningText, contains('PaidFeatureException'));
    expect(
      errors.warningText,
      contains(
        'Custom events are only available in paid plans. Current plan: free.',
      ),
    );
    expect(errors.warningText, contains('Custom events is a paid feature'));
    expect(errors.warningText, contains('code: 2003'));

    // no events are left to be resubmitted
    final eventsOnDisk = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk, hasLength(0));

    // submitting a second events once we know the project is on the free plan does not print the error anymore
    final error2 = captureFlutterErrors();
    await robot.triggerAnalyticsEvent();
    await tester.idle();
    error2.restoreDefaultErrorHandlers();
    expect(error2.warningText, isEmpty);
    expect(error2.errorText, isEmpty);
    final eventsOnDisk2 = await robot.services.eventStore.getEvents('test');
    expect(eventsOnDisk2, hasLength(0));
  });

  testWidgets('trackEvent does not throw when submit fails', (tester) async {
    final robot = WiredashTestRobot(tester);
    await robot.launchApp();

    bool thrown = false;
    robot.mockServices.mockApi.sendEventsInvocations.interceptor =
        (invocation) async {
      thrown = true;
      throw const SocketException('no internet');
    };

    try {
      await Wiredash.trackEvent('someEvent');
      await tester.idle();
    } catch (e, stack) {
      fail('trackEvent should never throw\n$e\n$stack');
    }
    expect(thrown, isTrue);
  });

  test('3rd party implements WiredashAnalytics', () {
    final analytics = ThirdPartyAnalytics();
    expect(analytics.projectId, isNull);
    expect(
      () => analytics.trackEvent('test_event', data: {'param1': 'value1'}),
      returnsNormally,
    );
  });
}

// verifies no new methods are accidentally added to WiredashAnalytics, making it easy to mock
class ThirdPartyAnalytics implements WiredashAnalytics {
  @override
  String? get projectId => null;

  @override
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? data,
  }) async {}
}
