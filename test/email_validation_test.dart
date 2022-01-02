// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/common/options/feedback_options.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/ui/steps/step_6_submit.dart';

import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Email validation errors', () {
    testWidgets('Submit works with valid email', (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('dash@flutter.io');
      await robot.submitEmailViaButton();
      expect(find.byType(Step6Submit), findsOneWidget);
    });

    testWidgets('Submit works without email', (tester) async {
      final WiredashTestRobot robot = await goToEmailStep(tester);
      await robot.enterEmail('');
      await robot.submitEmailViaButton();
      expect(find.byType(Step6Submit), findsOneWidget);
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

    testWidgets('Don not ask for email', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      expect(
        robot.services.feedbackModel.feedbackFlowStatus,
        isNot(FeedbackFlowStatus.email),
      );
      expect(
        robot.services.feedbackModel.feedbackFlowStatus,
        FeedbackFlowStatus.submit,
      );
    });
  });
}

Future<WiredashTestRobot> goToEmailStep(WidgetTester tester) async {
  final robot = await WiredashTestRobot.launchApp(
    tester,
    feedbackOptions: const WiredashFeedbackOptions(
      askForUserEmail: true,
    ),
  );

  await robot.openWiredash();
  await robot.enterFeedbackMessage('test message');
  await robot.goToNextStep();
  await robot.skipScreenshot();
  expect(
    robot.services.feedbackModel.feedbackFlowStatus,
    FeedbackFlowStatus.email,
  );
  return robot;
}
