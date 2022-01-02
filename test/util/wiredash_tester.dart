// ignore_for_file: avoid_print

library wiredashtester;

import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

extension WiredashTester on WidgetTester {
  /// Pumps and also drains the event queue, then pumps again and settles
  Future<void> pumpHardAndSettle([
    Duration duration = const Duration(milliseconds: 1),
  ]) async {
    await pumpAndSettle();
    // pump event queue, trigger timers
    await runAsync(() => Future.delayed(duration));
  }

  Future<void> waitUntil(
    Finder finder,
    Matcher matcher, {
    Duration timeout = const Duration(seconds: 3),
  }) async {
    // print('waitUntil $finder matches within $timeout');
    final stack = StackTrace.current;
    final start = DateTime.now();
    // await pumpAndSettle();
    var attempt = 0;
    while (true) {
      attempt++;
      if (matcher.matches(finder, {})) {
        break;
      }
      if (finder.runtimeType.toString().contains('_TextFinder')) {
        print('Text on screen (${DateTime.now().difference(start)}):');
        print(allWidgets.whereType<Text>().map((e) => e.data).toList());
      }

      final now = DateTime.now();
      if (now.isAfter(start.add(timeout))) {
        print(stack);
        if (finder.runtimeType.toString().contains('_TextFinder')) {
          print('Text on screen:');
          print(allWidgets.whereType<Text>().map((e) => e.data).toList());
        }
        throw 'Did not find $finder after $timeout (attempt: $attempt)';
      }

      final duration =
          Duration(milliseconds: math.pow(attempt, math.e).toInt());
      if (duration > const Duration(seconds: 1)) {
        // show continuous updates
        print(
          'Waiting for (attempt: $attempt)\n'
          '\tFinder: $finder to match\n'
          '\tMatcher: $matcher',
        );
      }
      if (attempt < 10) {
        await pumpAndSettle(duration);
      } else {
        await pumpHardAndSettle(duration);
      }
    }
  }
}
