import 'dart:async';

import 'package:flutter/foundation.dart';

/// Detects if the code is currently running in a test environment
///
/// Being fully aware that test detection in production code is an anti-pattern
/// it is very useful to prevent Wiredash from scheduling background jobs,
/// that would exchange data with the backend. Those requests will fail in a
/// test environment, but the scheduled jobs could unnecessarily interfere with
/// the app under test by creating Timers, use timeouts or call method channels.
class TestDetector {
  /// Returns true if the code is executed inside testWidgets()
  bool inFakeAsync() {
    try {
      if (kReleaseMode) {
        // release mode never executes tests
        return false;
      }

      // Check the timer implementation. Wiredash should only ignore job scheduling in testWidgets()
      final timer = Zone.current.createTimer(Duration.zero, () {});
      timer.cancel();

      // Detect FakeTimer by its toString() method
      // timer.toString(); returns => Instance of 'FakeTimer'
      final isFakeTimer = timer.toString().contains('FakeTimer');
      if (isFakeTimer) {
        // Wiredash schedules jobs with timers.
        // If FakeTimers are used, we are inside a widget test.
        // Do not schedule jobs with fakeTimers because application test code is
        // most likely not about the Wiredash jobs, but about the application itself.
        // Scheduling jobs would interfere with the test.
        return true;
      }

      return false;
    } catch (e) {
      // being paranoid, but never ever crash this function
      return false;
    }
  }
}
