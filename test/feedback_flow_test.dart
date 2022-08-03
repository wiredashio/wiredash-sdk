import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/wiredash.dart';

import 'util/assert_widget.dart';
import 'util/robot.dart';

void main() {
  autoUpdateGoldenFiles = true;
  group('Feedback', () {
    setUp(() {
      SharedPreferences.setMockInitialValues({});
    });

    testWidgets('Send text only feedback', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.skipEmail();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });

    testWidgets('No message shows error, entering one allows continue',
        (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);
      await robot.openWiredash();

      // Pressing next shows error
      await robot.goToNextStep();
      _larryPageView
          .childByType(Step1FeedbackMessage)
          .text('l10n.feedbackStep1MessageErrorMissingMessage')
          .existsOnce();

      // Entering a message allows continue
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();

      _larryPageView.childByType(Step1FeedbackMessage).doesNotExist();
      _larryPageView.childByType(Step3ScreenshotOverview).existsOnce();
    });

    testWidgets('Send feedback with screenshot', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.enterScreenshotMode();
      await robot.takeScreenshot();
      await robot.confirmDrawing();
      await robot.goToNextStep();
      await robot.skipEmail();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.attachments, hasLength(1));
    });

    testWidgets('Send feedback with multiple screenshots', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

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
      await robot.skipEmail();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
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
            Label(id: 'lbl-1', title: 'One'),
            Label(id: 'lbl-2', title: 'Two'),
          ],
        ),
      );

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
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.labels, ['lbl-2']);
      expect(submittedFeedback.message, 'feedback with labels');
    });

    testWidgets('Send feedback with email', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          email: EmailPrompt.optional,
        ),
      );

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.enterEmail('dash@flutter.io');
      await robot.goToNextStep();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.email, 'dash@flutter.io');
      expect(submittedFeedback.attachments, hasLength(0));
    });

    testWidgets('Default steps are message, screenshot, email', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        // empty feedback options
        feedbackOptions: const WiredashFeedbackOptions(),
      );

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.enterEmail('dash@flutter.io');
      await robot.goToNextStep();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.message, 'test message');
      expect(submittedFeedback.email, 'dash@flutter.io');
      expect(submittedFeedback.attachments, hasLength(0));
    });

    testWidgets('Do not ask for email', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          email: EmailPrompt.hidden,
        ),
      );

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

    testWidgets('Send feedback with everything', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          email: EmailPrompt.optional,
          labels: [
            Label(id: 'lbl-1', title: 'One'),
            Label(id: 'lbl-2', title: 'Two'),
          ],
        ),
      );
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
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback!.message, 'test message');
    });

    testWidgets('Restore flow state when reopening', (tester) async {
      final robot = await WiredashTestRobot.launchApp(tester);

      await robot.openWiredash();
      await robot.enterFeedbackMessage('test message');
      await robot.goToNextStep();
      await robot.skipScreenshot();
      await robot.skipEmail();
      _larryPageView.childByType(Step6Submit).existsOnce();

      await robot.closeWiredash();
      await robot.openWiredash();
      _larryPageView.childByType(Step6Submit).existsOnce();
    });

    testWidgets('Dont show hidden labels but send them regardless',
        (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'lbl-1', title: 'One'),
            Label(id: 'lbl-2', title: 'Two'),
            Label(id: 'lbl-3', title: 'Hidden', hidden: true),
          ],
        ),
      );

      await robot.openWiredash();
      await robot.enterFeedbackMessage('feedback with labels');
      await robot.goToNextStep();

      // labels
      expect(find.text('One'), findsOneWidget);
      expect(find.text('Two'), findsOneWidget);
      // hidden label is not shown
      expect(find.text('Hidden'), findsNothing);
      await robot.selectLabel('Two');
      await robot.goToNextStep();

      await robot.skipScreenshot();
      await robot.skipEmail();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      // 'lbl-3' is submitted but was not selected by user
      expect(submittedFeedback!.labels, ['lbl-2', 'lbl-3']);
      expect(submittedFeedback.message, 'feedback with labels');
    });

    testWidgets('Hidden labels only skip label step', (tester) async {
      final robot = await WiredashTestRobot.launchApp(
        tester,
        feedbackOptions: const WiredashFeedbackOptions(
          labels: [
            Label(id: 'lbl-1', title: 'One', hidden: true),
            Label(id: 'lbl-2', title: 'Two', hidden: true),
          ],
        ),
      );

      await robot.openWiredash();
      await robot.enterFeedbackMessage('feedback with labels');
      await robot.goToNextStep();

      selectByType(Wiredash)
          .childByType(WiredashBackdrop)
          .childByType(LarryPageView)
          .childByType(Step2Labels)
          .doesNotExist();

      await robot.skipScreenshot();
      await robot.skipEmail();
      await robot.submitFeedback();
      await robot.waitUntilWiredashIsClosed();
      final latestCall =
          robot.mockServices.mockApi.sendFeedbackInvocations.latest;
      final submittedFeedback = latestCall[0] as PersistedFeedbackItem?;
      expect(submittedFeedback, isNotNull);
      expect(submittedFeedback!.labels, ['lbl-1', 'lbl-2']);
      expect(submittedFeedback.message, 'feedback with labels');
    });
  });
}

final _larryPageView =
    selectByType(WiredashFeedbackFlow).childByType(LarryPageView);
