// ignore_for_file: avoid_print

library wiredashtester;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

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
    Duration? minimumDuration,
    Duration timeout = const Duration(seconds: 10),
  ]) async {
    final binding = TestWidgetsFlutterBinding.instance;
    final start = binding.clock.now();
    final d = minimumDuration ?? Duration.zero;
    await pumpHard(d);
    int count = 0;
    Duration increasing = Duration.zero;
    while (await pumpIfNecessary()) {
      if (binding.clock.now().isAfter(start.add(timeout))) {
        return;
      }

      count++;
      await pumpHard(increasing);
      if (count > 20) {
        if (d != Duration.zero) {
          // only enforce a maximum pump when an explicit duration is given
          return;
        } else {
          increasing += const Duration(milliseconds: 100);
        }
      }
    }
  }

  /// Pumps new frames as long as there are frames scheduled
  ///
  /// This is an advanced version of [pumpAndSettle] that uses an
  /// advanced pump strategy and automatically stops after [max] iterations
  /// without a timeout error
  Future<bool> pumpIfNecessary([int max = 20]) async {
    if (!binding.hasScheduledFrame) {
      return false;
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
      final duration = nextStop.difference(now).abs();
      await binding.pump(duration);
      if (!binding.hasScheduledFrame) {
        return true;
      }
    }
    return true;
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

    Future<void> drain() async {
      // pump event queue, trigger timers
      await binding.runAsync(() => Future.delayed(Duration.zero));
      await binding.runAsync(() => pumpEventQueue());

      await binding.pump();
    }

    // pump once at the beginning to kick things off
    await binding.pump();
    await drain();

    if (duration != Duration.zero) {
      // pump for the duration the user defined
      final stepDuration =
          Duration(microseconds: duration.inMicroseconds ~/ rounds);
      for (int round = 1; round < rounds; round++) {
        await drain();
        await binding.delayed(stepDuration);
      }
    }

    // finish last round and end exactly at the time the user defined
    final now = binding.clock.now();
    final remainingTime = endTime.difference(now);
    if (remainingTime > Duration.zero) {
      await drain();
      await binding.pump(remainingTime);
      await drain();
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
        print(
          'Text on screen (@ $executingTime) should '
          'match $actualValue but got "${matcher.describe(StringDescription())}":',
        );
        print(
          "Text on screen: ${allWidgets.whereType<Text>().map((e) => e.data).toList()}",
        );
      }

      if (now.isAfter(start.add(timeout))) {
        // Exit with error
        print(stack);
        if (actualValue.runtimeType.toString().contains('_TextFinder')) {
          print('Text on screen:');
          print(allWidgets.whereType<Text>().map((e) => e.data).toList());
        }
        throw 'Did not find $actualValue after $timeout (attempt: $attempt)';
      }

      final duration =
          Duration(milliseconds: math.pow(attempt, math.e).toInt());
      if (executingTime > const Duration(seconds: 1) &&
          duration > const Duration(seconds: 1)) {
        // show continuous updates
        print(
          'Waiting for match (attempt: $attempt, @ $executingTime)\n'
          '\tFinder: $actualValue to match\n'
          '\tMatcher: ${matcher.describe(StringDescription())}',
        );
      }
      await pumpSmart(duration);
    }
  }
}
