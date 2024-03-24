import 'dart:io';

import 'package:async/async.dart';
import 'package:clock/clock.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

// TODO explicit analytics import should not be necessary
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/analytics/event_store.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/core/version.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';

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
              Wiredash.trackEvent('test_event', params: {'param1': 'value1'});
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
              analytics.trackEvent('test_event', params: {'param1': 'value1'});
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
                  .trackEvent('test_event', params: {'param1': 'value1'});
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
              analytics.trackEvent('test_event', params: {'param1': 'value1'});
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
    final robot = WiredashTestRobot(tester);

    const kb100EventToInsert = 20;
    await robot.launchApp(
      builder: (context) {
        return Scaffold(
          body: Column(
            children: [
              ElevatedButton(
                onPressed: () async {
                  final analytics = WiredashAnalytics();
                  const kb100 = 1024 * 1024 ~/ 10;
                  for (var i = 0; i < kb100EventToInsert; i++) {
                    await analytics.trackEvent(
                      'big',
                      params: {'param1': "".padLeft(kb100, '0')},
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

    // always save the last events
    final pending = await robot.services.eventStore.getEvents('test');
    expect(pending, hasLength(10));

    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0]! as List<RequestEvent>;
    expect(
      events.any((event) => event.eventName == 'small'),
      isTrue,
      reason: 'small event should be sent,'
          ' ${events.map((e) => e.eventData).join(',')}',
    );
  });

  testWidgets('send event from isolate', (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();

    // TODO create integration_test
    markTestSkipped('not possible on Dart VM');
    return;
    // bool skip = false;
    // assert(() {
    //   skip = true;
    //   return true;
    // }());
    // if (skip) {
    //   return;
    // }
    //
    // final token = ServicesBinding.rootIsolateToken!;
    // await tester.runAsync(() async {
    //   await compute(
    //     (RootIsolateToken token) async {
    //       BackgroundIsolateBinaryMessenger.ensureInitialized(token);
    //       await Wiredash.trackEvent('test_event');
    //     },
    //     token,
    //   );
    // });
    //
    // final events = await robot.services.eventStore.getEvents('test');
    // expect(events, hasLength(1));
  });

  testWidgets('default events are submitted with the next Wiredash instance',
      (tester) async {
    final robot = WiredashTestRobot(tester);
    robot.setupMocks();
    await tester.pumpWidget(
      // No Wiredash widget
      MaterialApp(
        home: Scaffold(
          body: ElevatedButton(
            onPressed: () {
              Wiredash.trackEvent('test_event', params: {'param1': 'value1'});
            },
            child: const Text('Send Event'),
          ),
        ),
      ),
    );

    await robot.tapText('Send Event');
    await tester.pumpSmart();

    // event is saved locally for the "default" project
    final eventStore =
        AnalyticsEventStore(sharedPreferences: SharedPreferences.getInstance);
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
    final eventStore =
        AnalyticsEventStore(sharedPreferences: SharedPreferences.getInstance);
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

    final eventStore =
        AnalyticsEventStore(sharedPreferences: SharedPreferences.getInstance);
    final eventsOnDisk1 = await eventStore.getEvents('projectX');
    expect(eventsOnDisk1, hasLength(2));

    // jump to 3 days in the future
    await tester.pump(const Duration(days: 2));

    // restart the app
    await robot.launchApp(projectId: 'projectX');
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

  group('registry', () {
    test('singleton', () {
      final r1 = WiredashRegistry.instance;
      final r2 = WiredashRegistry.instance;
      expect(identical(r1, r2), isTrue);
    });

    testWidgets('add existing item throws', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();

      final registry = WiredashRegistry.instance;
      final element =
          tester.firstElement(find.byWidget(robot.widget)) as StatefulElement;
      expect(
        () => registry.register(element.state as WiredashState),
        throwsA(
          isA<StateError>().having(
            (e) => e.message,
            'message',
            contains('is already registered'),
          ),
        ),
      );
    });

    testWidgets('add item', (tester) async {
      final robot = WiredashTestRobot(tester);
      await robot.launchApp();

      final registry = WiredashRegistry.instance;
      expect(registry.allWidgets, hasLength(1));
      expect(registry.referenceCount, 1);
    });

    test('zero items', () {
      // by default, the registry is empty.
      // and the state added in the previous test is not present anymore
      expect(WiredashRegistry.instance.allWidgets, isEmpty);
    });
  });
}
