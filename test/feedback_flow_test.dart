// ignore_for_file: avoid_print

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/wiredash.dart';

import 'util/assert_widget.dart';
import 'util/mock_api.dart';
import 'util/robot.dart';
import 'util/wiredash_tester.dart';

void main() {
  group('Wiredash', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send text only feedback', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.submitFeedback();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });

    testWidgets('No message shows error, entering one allows continue',
        (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);
      await robot.openWiredash();

      // Pressing next shows error
      await robot.goToNextStep();
      larryPageView
          .childByType(Step1FeedbackMessage)
          .text('Please enter a feedback message')
          .existsOnce();

      // Entering a message allows continue
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();

      larryPageView.childByType(Step1FeedbackMessage).doesNotExist();
      larryPageView.childByType(Step3ScreenshotOverview).existsOnce();
    });

    testWidgets('Send feedback with screenshot', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi.fake();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      await robot.goToNextStep();
      await robot.submitFeedback();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.attachments, hasLength(1));
    });

    testWidgets('Send feedback with multiple screenshots', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi.fake();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      expect(find.byType(AttachmentPreview), findsNWidgets(2));
      await robot.goToNextStep();
      await robot.submitFeedback();
      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.attachments, hasLength(2));
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
      final mockApi = MockWiredashApi.fake();
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
      await robot.submitFeedback();
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
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          askForUserEmail: true,
        ),
      );
      final mockApi = MockWiredashApi.fake();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.enterEmail('dash@flutter.io');
      await robot.goToNextStep();
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
      expect(submittedFeedback.attachments, hasLength(0));
    });

    testWidgets('Send feedback with everything', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          askForUserEmail: true,
          labels: [
            Label(id: 'lbl-1', title: 'One', description: 'First'),
            Label(id: 'lbl-2', title: 'Two', description: 'Second'),
          ],
        ),
      );
      final mockApi = MockWiredashApi.fake();
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
      await robot.goToNextStep();
      await robot.submitFeedback();

      await tester.waitUntil(
        find.text('Thanks for your feedback!'),
        findsOneWidget,
      );
      final latestCall = mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });

    testWidgets('Restore flow state when reopening', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      final mockApi = MockWiredashApi();
      robot.mockWiredashApi(mockApi);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      larryPageView.childByType(Step6Submit).existsOnce();

      await robot.closeWiredash();
      await robot.openWiredash();
      larryPageView.childByType(Step6Submit).existsOnce();
    });
  });
}

final larryPageView =
    selectByType(WiredashFeedbackFlow).childByType(LarryPageView);
