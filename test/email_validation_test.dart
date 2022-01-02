// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/common/options/feedback_options.dart';
import 'package:wiredash/src/feedback/data/label.dart';

import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Email validation errors', () {
    testWidgets('Submit works with valid email', (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('dash@flutter.io');
      await robot.submitEmailViaButton();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
    });
    testWidgets('Submit works without email', (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('');
      await robot.submitEmailViaButton();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
    });
    testWidgets('Submit via button - Shows error for invalid email',
        (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('invalid');
      await robot.submitEmailViaButton();
      await tester.waitUntil(
        find.text('Please enter a valid email or leave this field blank.'),
        findsOneWidget,
      );
    });

    testWidgets('Submit via enter - Shows error for invalid email',
        (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('invalid');
      await robot.submitEmailViaKeyboard();
      await tester.waitUntil(
        find.text('Please enter a valid email or leave this field blank.'),
        findsOneWidget,
      );
    });
  });
}

Future<WiredashTestRobot> goToEmailStep(WidgetTester tester) async {
  final robot = await WiredashTestRobot.launchApp(
    tester,
    feedbackOptions: const WiredashFeedbackOptions(
      labels: [
        Label(id: 'label-bug', title: 'Bug'),
      ],
    ),
  );

  await robot.openWiredash();
  await robot.enterFeedbackMessage('test message');
  await robot.goToNextStep();
  await robot.skipLabels();
  await robot.skipScreenshot();
  return robot;
}
