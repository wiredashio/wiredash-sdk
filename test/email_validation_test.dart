// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:wiredash/src/core/options/feedback_options.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

import 'util/assert_widget.dart';
import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Email validation errors', () {
    testWidgets('Submit works with valid email', (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('dash@flutter.io');
      await robot.submitEmailViaButton();
      selectByType(LarryPageView).childByType(Step6Submit).existsOnce();
    });

    testWidgets('Submit works without email', (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('');
      await robot.submitEmailViaButton();
      selectByType(LarryPageView).childByType(Step6Submit).existsOnce();
    });

    testWidgets('Submit via button - Shows error for invalid email',
        (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('invalid');
      await robot.submitEmailViaButton();
      await tester.waitUntil(
        find.text('l10n.feedbackStep4EmailInvalidEmail'),
        findsOneWidget,
      );
    });

    testWidgets('Submit via enter - Shows error for invalid email',
        (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('invalid');
      await robot.submitEmailViaKeyboard();
      await tester.waitUntil(
        find.text('l10n.feedbackStep4EmailInvalidEmail'),
        findsOneWidget,
      );
    });

    testWidgets('Do not ask for email', (tester) async {
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

  group('email input', () {
    testWidgets(
        'Deleting the prefilled email address does not submit it in feedback',
        (tester) async {
      final robot = await tester.goToEmailStep(
        beforeOpen: (robot) {
          robot.wiredashController
              .setUserProperties(userEmail: 'dash@flutter.io');
        },
      );

      // shows prefilled email
      expect(find.text('dash@flutter.io'), findsOneWidget);
      // user clear the email address
      await robot.enterEmail('');

      await robot.goToNextStep();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;

      // email is not submitted because the user actively deleted it
      expect(submittedFeedback!.email, isNull);
    });

    testWidgets('Submit prefilled email address', (tester) async {
      final robot = await tester.goToEmailStep(
        beforeOpen: (robot) {
          robot.wiredashController
              .setUserProperties(userEmail: 'dash@flutter.io');
        },
      );

      // shows prefilled email / user leaves it as it
      expect(find.text('dash@flutter.io'), findsOneWidget);
      await robot.goToNextStep();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.email, 'dash@flutter.io');
    });
  });
}

extension on WidgetTester {
  Future<WiredashTestRobot> goToEmailStep({
    FutureOr<void> Function(WiredashTestRobot robot)? beforeOpen,
  }) async {
    final robot = await WiredashTestRobot.launchApp(
      this,
      feedbackOptions: const WiredashFeedbackOptions(
        askForUserEmail: true,
      ),
    );

    await beforeOpen?.call(robot);
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
}
