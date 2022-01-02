// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/common/network/wiredash_api.dart';
import 'package:wiredash/src/common/options/feedback_options.dart';
import 'package:wiredash/src/common/services/services.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/feedback_navigation.dart';
import 'package:wiredash/src/feedback/ui/steps/step_1_feedback_message.dart';
import 'package:wiredash/src/feedback/ui/steps/step_2_labels.dart';
import 'package:wiredash/src/feedback/ui/steps/step_3_screenshot_overview.dart';
import 'package:wiredash/src/feedback/ui/steps/step_5_email.dart';
import 'package:wiredash/src/feedback/ui/steps/step_6_submit.dart';
import 'package:wiredash/src/wiredash_widget.dart';

import 'mock_api.dart';
import 'wiredash_tester.dart';

class WiredashTestRobot {
  final WidgetTester tester;

  WiredashTestRobot(this.tester);

  static Future<WiredashTestRobot> launchApp(
    WidgetTester tester, {
    WiredashFeedbackOptions? feedbackOptions,
  }) async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider_macos');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });
    await tester.pumpWidget(
      Wiredash(
        projectId: 'test',
        secret: 'test',
        feedbackOptions: feedbackOptions,
        child: MaterialApp(
          home: Builder(
            builder: (context) {
              return Scaffold(
                floatingActionButton: FloatingActionButton(
                  onPressed: Wiredash.of(context).show,
                ),
              );
            },
          ),
        ),
      ),
    );
    final robot = WiredashTestRobot(tester);

    // Don't do actual http calls
    robot.services.inject<WiredashApi>((_) => MockWiredashApi());

    // replace submitter, because for testing we always want to submit directly
    robot.services.inject<FeedbackSubmitter>(
      (locator) => DirectFeedbackSubmitter(locator.api),
    );

    return robot;
  }

  final _navigationButtonFinder = find.descendant(
    of: find.byType(FeedbackNavigation),
    matching: find.byType(TronButton),
  );

  Wiredash get widget {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return element.widget as Wiredash;
  }

  WiredashServices get services {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return (element.state as WiredashState).debugServices;
  }

  void mockWiredashApi(WiredashApi api) {
    services.inject<WiredashApi>((_) => api);
  }

  Future<void> openWiredash() async {
    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle();
    expect(find.byType(WiredashFeedbackFlow), findsOneWidget);
    print('opened Wiredash');
  }

  Future<void> enterFeedbackMessage(String message) async {
    expect(find.byType(Step1FeedbackMessage), findsOneWidget);
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpAndSettle();
    await tester.waitUntil(
      find.byIcon(Wirecons.arrow_narrow_right),
      findsOneWidget,
    );
    expect(find.byIcon(Wirecons.arrow_narrow_right), findsOneWidget);
    expect(find.byIcon(Wirecons.chevron_double_up), findsOneWidget);
    print('entered feedback message: $message');
  }

  Future<void> enterEmail(String emailAddress) async {
    expect(find.byType(Step5Email), findsOneWidget);
    await tester.enterText(find.byType(TextField), emailAddress);
    await tester.pumpAndSettle();
    print('entered email: $emailAddress');
  }

  Future<void> skipScreenshot() async {
    expect(find.byType(Step3ScreenshotOverview), findsOneWidget);
    await tester.tap(find.byIcon(Wirecons.chevron_double_right));
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped taking screenshot, next $newStatus');
  }

  Future<void> skipLabels() async {
    expect(find.byType(Step2Labels), findsOneWidget);
    await goToNextStep();
    print('Skipped label selection');
  }

  Future<void> submitFeedback() async {
    expect(find.byType(Step6Submit), findsOneWidget);
    await tester.tap(find.byIcon(Wirecons.check));
    print('submit feedback');
    await tester.pump();
  }

  Future<void> skipEmail() async {
    expect(find.byType(Step5Email), findsOneWidget);
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped email, next $newStatus');
  }

  Future<void> submitEmailViaButton() async {
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Submitted email, next $newStatus');
  }

  Future<void> submitEmailViaKeyboard() async {
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Submitted email, next $newStatus');
  }

  Future<void> goToNextStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    await tester.tap(_navigationButtonFinder.last);
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to next $newStatus');
  }

  Future<void> goToPrevStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    await tester.tap(_navigationButtonFinder.first);
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to prev $newStatus');
  }

  Future<void> enterScreenshotMode() async {
    expect(find.byType(Step3ScreenshotOverview), findsOneWidget);
    await tester.tap(find.byIcon(Wirecons.arrow_narrow_right));
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    print('Entered screenshot mode');
  }

  Future<void> takeScreenshot() async {
    expect(find.byType(Step3ScreenshotOverview), findsOneWidget);
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotNavigating,
    );

    print('Take screeshot');
    // Click the screenshot button
    await tester.tap(find.byIcon(Wirecons.camera));
    await tester.pumpAndSettle();

    // Wait for edit screen
    await tester.waitUntil(find.byIcon(Wirecons.check), findsOneWidget);

    // Navigation buttons should show the pencil button and a check button
    expect(find.byIcon(Wirecons.pencil), findsOneWidget);
    expect(find.byIcon(Wirecons.check), findsOneWidget);
  }

  Future<void> confirmDrawing() async {
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotDrawing,
    );
    await tester.tap(find.byIcon(Wirecons.check));
    await tester.pumpAndSettle();

    // wait until the animation is closed
    await tester.waitUntil(
      find.byIcon(Wirecons.arrow_narrow_right),
      findsOneWidget,
    );
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Confirmed drawing $newStatus');
  }

  Future<void> selectLabel(String labelText) async {
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
  }
}
