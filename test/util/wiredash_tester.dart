library wiredashtester;

import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void _debugPrint(Object message) {
  //print('  $message');
}

extension WiredashTester on WidgetTester {
  /// Pumps [n] times
  Future<void> pumpN(int n) async {
    for (int i = 0; i < n; i++) {
      await pump();
    }
  }

  /// Pumps both, the Dart event loop and new frames as long as there are schedules frames
  ///
  /// This method is a combination of [pumpIfNecessary] and [pumpHard]
  ///
  Future<void> pumpSmart([
    Duration minimumDuration = Duration.zero,
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    assert(minimumDuration >= Duration.zero);
    assert(timeout >= Duration.zero);
    assert(minimumDuration < timeout);
    final binding = TestWidgetsFlutterBinding.instance;

    // Good stops during pump when to check if there is still work to do
    Iterable<int> stops() sync* {
      yield 0;
      yield 200; // kThemeAnimationDuration
      yield 500;

      int i = 1;
      while (true) {
        yield 1000 * i++;
      }
    }

    final start = binding.clock.now();
    int count = -1;

    Future<void> loop(Duration progress) async {
      // wait for pending platform channel messages
      if (binding.defaultBinaryMessenger.pendingMessageCount > 0) {
        await drainPlatformChannelMessageQueue();
      }

      // drain dart event queue
      await elapseTime(progress);
      await drainDartEventQueue();

      // build dirty widgets
      if (binding.hasScheduledFrame) {
        // draw the actual frame
        await binding.pump(Duration.zero);
      }
    }

    for (final stop in stops()) {
      count++;
      _debugPrint(
          'pumpSmart iteration $count ${binding.clock.now()} stop: $stop');

      final now = binding.clock.now();
      final nextStop = start.add(Duration(milliseconds: stop));
      final duration = nextStop.difference(now);

      final stopwatch = Stopwatch()..start();
      await loop(duration);
      stopwatch.stop();
      _debugPrint('loop $count took ${stopwatch.elapsedMilliseconds}ms');

      final reachedTimeout = binding.clock.now().isAfter(start.add(timeout));
      _debugPrint('reachedTimeout: $reachedTimeout');

      final hasScheduledFrame = binding.hasScheduledFrame;
      final pendingMessageCount =
          binding.defaultBinaryMessenger.pendingMessageCount;
      _debugPrint('hasScheduledFrame: $hasScheduledFrame');
      _debugPrint('pendingMessageCount: $pendingMessageCount');

      if (minimumDuration == Duration.zero) {
        if (!hasScheduledFrame && pendingMessageCount == 0) {
          return;
        }
        if (reachedTimeout) {
          _debugPrint(
              'Warning: pumpSmart() reached maximum iterations and completed before all work was done');
          return;
        }
      } else {
        final reachedMinimumDuration =
            binding.clock.now().isAfter(start.add(minimumDuration));
        if (reachedMinimumDuration) {
          if (!hasScheduledFrame && pendingMessageCount == 0) {
            return;
          }
        }

        if (reachedTimeout) {
          _debugPrint(
              'Warning: pumpSmart() reached maximum iterations and completed before all work was done');
          return;
        }
      }
    }
  }

  /// Moves the time forwards in small steps trying to trigger all pending futures
  Future<void> elapseTime(Duration duration) async {
    final binding = TestWidgetsFlutterBinding.instance;
    if (duration == Duration.zero) {
      await binding.delayed(Duration.zero);
    } else {
      const step = Duration(milliseconds: 100);

      // split duration in small 100ms steps (or smaller)
      Duration remaining = duration;
      while (remaining > Duration.zero) {
        final newRemaining = remaining - step;
        if (remaining > Duration.zero) {
          await binding.delayed(step);
        } else {
          await binding.delayed(remaining);
        }
        remaining = newRemaining;
      }
    }

    if (binding.microtaskCount > 0) {
      _debugPrint('delayed(0) - elapseTime');
      await binding.delayed(Duration.zero);
    }
  }

  Future<void> drainPlatformChannelMessageQueue([int max = 20]) async {
    // _debugPrint('drainPlatformChannelMessageQueue()');
    final pendingMessages = binding.defaultBinaryMessenger.pendingMessageCount;
    if (pendingMessages <= 0) {
      return;
    }
    int count = 0;
    while (
        binding.defaultBinaryMessenger.pendingMessageCount == pendingMessages) {
      // _debugPrint(
      //     'Messages in queue ${binding.defaultBinaryMessenger.pendingMessageCount}');
      _debugPrint('pumpEventQueue() - drainPlatformChannelMessageQueue');
      // wait for platform channel futures to complete
      await binding.runAsync(() => pumpEventQueue());
      // trigger microtasks
      if (binding.microtaskCount > 0) {
        // _debugPrint('draining ${binding.microtaskCount} microtasks');
        _debugPrint('delayed(0) - drainPlatformChannelMessageQueue');
        await binding.delayed(Duration.zero);
      }
      count++;
      if (count >= max) {
        _debugPrint('platform channel message queue not fully drained');
        return;
      }
    }
    // _debugPrint('Drained platform channel message queue');
  }

  /// Pumps new frames as long as there are frames scheduled
  ///
  /// This is an advanced version of [pumpAndSettle] that uses an
  /// advanced pump strategy and automatically stops after [max] iterations
  /// without a timeout error
  ///
  /// Returns true if there is still work to do after the pump
  Future<void> pumpIfNecessary([int max = 20]) async {
    if (!binding.hasScheduledFrame) {
      return;
    }
    final DateTime start = binding.clock.now();

    Iterable<int> stops() sync* {
      yield 0;
      yield 100;
      yield 250;
      yield 500;
      yield 1000;
      for (int i = 0; i < max - 5; i++) {
        yield 1000 * i;
      }
    }

    const maximumDuration = Duration(seconds: 10);
    final finalEnd = start.add(maximumDuration);

    for (final stop in stops()) {
      final now = binding.clock.now();
      if (now.isAfter(finalEnd)) {
        break;
      }
      final nextStop = start.add(Duration(milliseconds: stop));
      final duration = now.difference(nextStop).abs();
      if (duration < Duration.zero) {
        await binding.pump(Duration.zero);
      } else {
        await binding.pump(duration);
      }
      if (binding.hasScheduledFrame) {
        return;
      }
    }
  }

  /// Allows dart:io operations to execute (like file io) or timers like the famous [Future.delayed]
  Future<void> drainDartEventQueue() async {
    // trigger timers
    await binding.runAsync(() => Future.delayed(Duration.zero));
    // wait for Futures to complete
    await binding.runAsync(() => pumpEventQueue());
    // deliver results via microtasks
    if (binding.microtaskCount > 0) {
      await binding.delayed(Duration.zero);
    }
  }

  /// Pumps regularly until reaching [duration] while new frames are pumped and dart:io operations are executed
  ///
  /// Calling it with [duration] == Duration.zero calls the following pattern
  /// ```
  /// pump(); // handle input events / draws new frame
  /// runAsync(() => Future.delayed(Duration.zero)) // start io operations
  /// runAsync(() => pumpEventQueue()) // waits for io operations to finish
  /// pump(); // draw new frame
  /// ```
  ///
  /// When the [duration] is greater than zero, then it splits the duration
  /// into [rounds] segments and  repeats the pattern above. This guarantees
  /// that I/O operations are continuously executed.
  Future<void> pumpHard([
    Duration duration = Duration.zero,
    int rounds = 10,
  ]) async {
    final binding = TestWidgetsFlutterBinding.instance;
    final DateTime endTime = binding.clock.fromNowBy(duration);

    // pump once at the beginning to kick things off
    await binding.pump();
    await drainDartEventQueue();

    if (duration != Duration.zero) {
      // pump for the duration the user defined
      final stepDuration =
          Duration(microseconds: duration.inMicroseconds ~/ rounds);
      for (int round = 1; round < rounds; round++) {
        await drainDartEventQueue();
        await binding.delayed(stepDuration);
      }
    }

    // finish last round and end exactly at the time the user defined
    final now = binding.clock.now();
    final remainingTime = endTime.difference(now);
    if (remainingTime > Duration.zero) {
      await drainDartEventQueue();
      // _debugPrint('pump() ${clock.now()}');
      await binding.pump(remainingTime);
      await drainDartEventQueue();
    }
  }

  /// Continuously checks for [actual] to match [matcher] until [timeout] is reached
  ///
  /// Throws an error if the [timeout] is reached and the [actual] does not match [matcher]
  Future<void> waitUntil(
    // ignore: avoid_final_parameters
    final dynamic actual,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final stack = StackTrace.current;
    final start = DateTime.now();
    var attempt = 0;
    while (true) {
      attempt++;
      dynamic actualValue = actual;
      if (actual is Function()) {
        actualValue = actual.call();
      }
      if (matcher.matches(actualValue, {})) {
        break;
      }

      final now = DateTime.now();
      final executingTime = start.difference(now).abs();
      if (actualValue.runtimeType.toString().contains('_TextFinder') &&
          attempt > 1) {
        _debugPrint(
          'Text on screen (@ $executingTime) should '
          'match $actualValue but got "${matcher.describe(StringDescription())}":',
        );
        _debugPrint(
          "Text on screen: ${this.allWidgets.whereType<Text>().map((e) => e.data).toList()}",
        );
      }

      if (now.isAfter(start.add(timeout))) {
        // Exit with error
        _debugPrint(stack);
        if (actualValue.runtimeType.toString().contains('_TextFinder')) {
          _debugPrint('Text on screen:');
          _debugPrint(
              this.allWidgets.whereType<Text>().map((e) => e.data).toList());
        }
        throw 'Did not find $actualValue after $timeout (attempt: $attempt)';
      }

      final duration =
          Duration(milliseconds: math.pow(attempt, math.e).toInt());
      if (executingTime > const Duration(seconds: 1) &&
          duration > const Duration(seconds: 1)) {
        // show continuous updates
        _debugPrint(
          'Waiting for match (attempt: $attempt, @ $executingTime)\n'
          '\tFinder: $actualValue to match\n'
          '\tMatcher: ${matcher.describe(StringDescription())}',
        );
      }
      await pumpSmart(duration);
    }
  }
}
