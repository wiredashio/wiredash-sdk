// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

import 'util/invocation_catcher.dart';
import 'util/mock_api.dart';
import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('widget can be created', (tester) async {
      await tester.pumpWidget(
        const Wiredash(
          projectId: 'test',
          secret: 'test',
          child: SizedBox(),
        ),
      );

      expect(find.byType(Wiredash), findsOneWidget);
    });

    testWidgets(
      'calls ProjectCredentialValidator.validate() initially',
      (tester) async {
        final _MockProjectCredentialValidator validator =
            _MockProjectCredentialValidator();
        debugProjectCredentialValidator = validator;
        addTearDown(() {
          debugProjectCredentialValidator = const ProjectCredentialValidator();
        });

        await tester.pumpWidget(
          const Wiredash(
            projectId: 'my-project-id',
            secret: 'my-secret',
            child: SizedBox(),
          ),
        );

        validator.validateInvocations.verifyInvocationCount(1);
        final lastCall = validator.validateInvocations.latest;
        expect(lastCall['projectId'], 'my-project-id');
        expect(lastCall['secret'], 'my-secret');
      },
    );

    testWidgets('Send text only feedback', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.skipEmail();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });

    testWidgets('Send feedback with screenshot', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      await robot.goToNextStep();
      await robot.skipEmail();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(latestCall['images'], hasLength(1));
    });

    testWidgets('Send feedback with labels', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'lbl-1', title: 'One', description: 'First'),
            Label(id: 'lbl-2', title: 'Two', description: 'Second'),
          ],
        ),
      );
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('feedback with labels');
      await robot.goToNextStep();

      // labels
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      await robot.selectLabel('Two');
      await robot.goToNextStep();

      await robot.skipScreenshot();
      await robot.skipEmail();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.labels, ['lbl-2']);
      expect(submittedFeedback.message, 'feedback with labels');
    });

    testWidgets('Send feedback with email', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.enterEmail('dash@flutter.io');
      await robot.submitFeedback();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.email, 'dash@flutter.io');
      expect(latestCall['images'], hasLength(0));
    });

    testWidgets('Send feedback with everything', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'lbl-1', title: 'One', description: 'First'),
            Label(id: 'lbl-2', title: 'Two', description: 'Second'),
          ],
        ),
      );
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();

      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();

      await robot.selectLabel('Two');
      await robot.goToNextStep();

      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      await robot.goToNextStep();

      await robot.enterEmail('dash@flutter.io');
      await robot.submitFeedback();

      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });
  });
}

class _MockProjectCredentialValidator extends Fake
    implements ProjectCredentialValidator {
  final MethodInvocationCatcher validateInvocations =
      MethodInvocationCatcher('validate');

  @override
  Future<void> validate({
    required String projectId,
    required String secret,
  }) async {
    validateInvocations
        .addMethodCall(namedArgs: {'projectId': projectId, 'secret': secret});
  }
}
