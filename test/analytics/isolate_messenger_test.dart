@TestOn('vm')
library;

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/an4lytics/an4lytics_isolate_message.dart';
import 'package:wiredash/src/an4lytics/isolate_messenger_io.dart';

import '../util/flutter_error.dart';

void main() {
  group('AnalyticsIsolateMessage.fromObject', () {
    test('parses a serialized message', () {
      final message = AnalyticsIsolateMessage.fromObject([
        'my_project',
        'prod',
        'test_event',
        true,
      ]);

      expect(message.projectId, 'my_project');
      expect(message.environment, 'prod');
      expect(message.eventName, 'test_event');
      expect(message.submitImmediately, isTrue);
    });

    test('parses nullable routing fields', () {
      final message = AnalyticsIsolateMessage.fromObject([
        null,
        null,
        'test_event',
        false,
      ]);

      expect(message.projectId, isNull);
      expect(message.environment, isNull);
      expect(message.eventName, 'test_event');
      expect(message.submitImmediately, isFalse);
    });

    test('treats only true as immediate submit', () {
      final message = AnalyticsIsolateMessage.fromObject([
        null,
        null,
        'test_event',
        'true',
      ]);

      expect(message.submitImmediately, isFalse);
    });

    test('throws for malformed messages', () {
      final malformedMessages = <Object?>[
        null,
        'test_event',
        <Object?>[],
        <Object?>[null, null, null, false],
        <Object?>[null, null, 42, false],
      ];

      for (final message in malformedMessages) {
        expect(
          () => AnalyticsIsolateMessage.fromObject(message),
          throwsA(isA<Object>()),
        );
      }
    });
  });

  // The real cross-isolate wake-up runs across two isolates; here we exercise
  // the IsolateNameServer round-trip within one isolate, which is enough to
  // prove a ping reaches the main-isolate analytics router.
  test('a ping reaches the analytics router', () async {
    final errors = captureFlutterErrors();
    final registration = registerMainIsolateAnalyticsListener();
    addTearDown(registration.dispose);

    notifyMainIsolateOfAnalyticsEvent(
      const AnalyticsIsolateMessage(
        projectId: 'my_project',
        environment: 'prod',
        eventName: 'test_event',
        submitImmediately: true,
      ),
    );
    await pumpEventQueue();

    expect(errors.warnings, hasLength(1));
    expect(errors.warningText, contains("No Wiredash widget is mounted"));
    expect(errors.warningText, contains("test_event"));
  });

  test('notifying without a listener is a no-op', () async {
    // Must not throw when no main isolate has registered a port.
    expect(
      () => notifyMainIsolateOfAnalyticsEvent(
        const AnalyticsIsolateMessage(
          projectId: null,
          environment: null,
          eventName: 'test_event',
          submitImmediately: false,
        ),
      ),
      returnsNormally,
    );
  });

  test('reports malformed isolate messages', () async {
    final errors = captureFlutterErrors();
    final registration = registerMainIsolateAnalyticsListener();
    addTearDown(registration.dispose);

    sendRawMainIsolateAnalyticsMessage('bad_message');
    await pumpEventQueue();

    expect(errors.warnings, hasLength(1));
    expect(errors.warningText, contains('Received malformed'));
    expect(errors.warningText, contains('bad_message'));
  });

  test('each registration disposes only its own port ownership', () async {
    final errors = captureFlutterErrors();
    expect(debugMainIsolateAnalyticsRegistrationCount, 0);
    final firstRegistration = registerMainIsolateAnalyticsListener();
    addTearDown(firstRegistration.dispose);
    expect(debugMainIsolateAnalyticsRegistrationCount, 1);
    final secondRegistration = registerMainIsolateAnalyticsListener();
    addTearDown(secondRegistration.dispose);
    expect(debugMainIsolateAnalyticsRegistrationCount, 2);

    firstRegistration.dispose();
    expect(debugMainIsolateAnalyticsRegistrationCount, 1);
    notifyMainIsolateOfAnalyticsEvent(
      const AnalyticsIsolateMessage(
        projectId: 'my_project',
        environment: 'prod',
        eventName: 'test_event',
        submitImmediately: false,
      ),
    );
    await pumpEventQueue();

    expect(errors.warnings, hasLength(1));

    secondRegistration.dispose();
    expect(debugMainIsolateAnalyticsRegistrationCount, 0);
    notifyMainIsolateOfAnalyticsEvent(
      const AnalyticsIsolateMessage(
        projectId: 'my_project',
        environment: 'prod',
        eventName: 'test_event',
        submitImmediately: false,
      ),
    );
    await pumpEventQueue();

    expect(errors.warnings, hasLength(1));
  });
}
