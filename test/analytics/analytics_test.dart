import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:shared_preferences/shared_preferences.dart';

// TODO explicit analytics import should not be necessary
import 'package:wiredash/src/analytics/analytics.dart';
import 'package:wiredash/src/core/network/send_events_request.dart';
import 'package:wiredash/wiredash.dart';

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
    print('pump end');

    robot.mockServices.mockApi.sendEventsInvocations.verifyInvocationCount(1);
    final lastEvents = robot.mockServices.mockApi.sendEventsInvocations.latest;
    final events = lastEvents[0] as List<RequestEvent>?;
    expect(events, hasLength(1));
    final event = events![0];
    expect(event.eventName, 'test_event');
    expect(event.eventData, {'param1': 'value1'});
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

    final pending = await getPendingEvents();
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
    final pending = await getPendingEvents();
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
    bool skip = false;
    assert(() {
      skip = true;
      return true;
    }());
    if (skip) {
      return;
    }

    final token = ServicesBinding.rootIsolateToken!;
    await tester.runAsync(() async {
      await compute(
        (RootIsolateToken token) async {
          BackgroundIsolateBinaryMessenger.ensureInitialized(token);
          await Wiredash.trackEvent('test_event');
        },
        token,
      );
    });

    final events = await getPendingEvents();
    expect(events, hasLength(1));
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
    final eventsOnDisk = await getPendingEvents();
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
    final eventsOnDisk = await getPendingEvents();
    expect(eventsOnDisk, hasLength(1));

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
}

Future<List<String>> getPendingEvents() async {
  final prefs = await SharedPreferences.getInstance();
  final events = prefs
      .getKeys()
      .where((key) => WiredashAnalytics.eventKeyRegex.hasMatch(key))
      .toList();
  return events;
}
