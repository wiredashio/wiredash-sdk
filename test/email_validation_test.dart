// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:spot/spot.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';

import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Email validation errors', () {
    testWidgets('Submit works with valid email', (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('dash@flutter.io');
      await robot.submitEmailViaButton();
      spot<LarryPageView>().spot<Step6Submit>().existsOnce();
    });

    testWidgets('Submit works without email', (tester) async {
      final WiredashTestRobot robot = await tester.goToEmailStep();
      await robot.enterEmail('');
      await robot.submitEmailViaButton();
      spot<LarryPageView>().spot<Step6Submit>().existsOnce();
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

    testWidgets('Submit via enter - Shows error for empty email when mandatory',
        (tester) async {
      final WiredashTestRobot robot =
          await tester.goToEmailStep(emailPrompt: EmailPrompt.mandatory);
      await robot.enterEmail('');
      await robot.submitEmailViaKeyboard();
      await tester.waitUntil(
        find.text('l10n.feedbackStep4EmailInvalidEmail'),
        findsOneWidget,
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
      final submittedFeedback = latestCall[0] as FeedbackItem?;

      // email is not submitted because the user actively deleted it
      expect(submittedFeedback!.metadata.userEmail, isNull);
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
      final submittedFeedback = latestCall[0] as FeedbackItem?;
      expect(submittedFeedback!.metadata.userEmail, 'dash@flutter.io');
    });
  });
}

extension on WidgetTester {
  Future<WiredashTestRobot> goToEmailStep({
    FutureOr<void> Function(WiredashTestRobot robot)? beforeOpen,
    EmailPrompt emailPrompt = EmailPrompt.optional,
  }) async {
    final robot = await WiredashTestRobot(this).launchApp(
      feedbackOptions: WiredashFeedbackOptions(
        email: emailPrompt,
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
