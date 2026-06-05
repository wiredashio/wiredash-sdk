@TestOn('vm')
library;

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/an4lytics/isolate_messenger_io.dart';

void main() {
  // The real cross-isolate wake-up runs across two isolates; here we exercise
  // the IsolateNameServer round-trip within one isolate, which is enough to
  // prove a ping reaches the registered listener.
  test('a ping delivers projectId, environment and eventName to the listener',
      () async {
    final pinged = Completer<(String?, String?, String)>();
    registerMainIsolateAnalyticsListener((projectId, environment, eventName) {
      if (!pinged.isCompleted) {
        pinged.complete((projectId, environment, eventName));
      }
    });
    addTearDown(unregisterMainIsolateAnalyticsListener);

    notifyMainIsolateOfNewEvent('my_project', 'prod', 'test_event');

    final received = await pinged.future.timeout(const Duration(seconds: 5));
    expect(received, ('my_project', 'prod', 'test_event'));
  });

  test('notifying without a listener is a no-op', () async {
    unregisterMainIsolateAnalyticsListener();
    // Must not throw when no main isolate has registered a port.
    expect(
      () => notifyMainIsolateOfNewEvent(null, null, 'test_event'),
      returnsNormally,
    );
  });
}
