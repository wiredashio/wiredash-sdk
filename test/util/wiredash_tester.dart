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

  /// Pumps and also drains the event queue, then pumps again and settles
  Future<void> pumpHardAndSettle([
    Duration duration = const Duration(milliseconds: 1),
  ]) async {
    await pumpAndSettle();
    // pump event queue, trigger timers
    await runAsync(() => Future.delayed(duration));
  }

  Future<void> waitUntil(
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
          'match $actualValue but got "${matcher.describe(StringDescription()).toString()}":',
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
          '\tMatcher: ${matcher.describe(StringDescription()).toString()}',
        );
      }
      if (attempt < 10) {
        await pumpAndSettle(duration);
      } else {
        await pumpHardAndSettle(duration);
        await pump();
      }
    }
  }
}
