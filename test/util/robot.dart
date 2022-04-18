// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/wiredash.dart';

import 'assert_widget.dart';
import 'mock_api.dart';
import 'wiredash_tester.dart';

class WiredashTestRobot {
  final WidgetTester tester;

  WiredashTestRobot(this.tester);

  static Future<WiredashTestRobot> launchApp(
    WidgetTester tester, {
    WiredashFeedbackOptions? feedbackOptions,
    Widget Function(BuildContext)? builder,
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
        theme: WiredashThemeData(
          primaryBackgroundColor: Colors.grey,
          secondaryBackgroundColor: Colors.brown,
        ),
        child: MaterialApp(
          home: Builder(
            builder: builder ??
                (context) {
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

  WidgetSelector get _backdrop =>
      selectByType(Wiredash).childByType(WiredashBackdrop);

  WidgetSelector get _pageView => _backdrop.childByType(LarryPageView);

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
    final fab = selectByType(MaterialApp)
        .childByType(FloatingActionButton)
        .existsOnce();
    await tester.tap(fab.finder);
    await tester.pumpAndSettle();
    _backdrop.childByType(WiredashFeedbackFlow).existsOnce();
    print('opened Wiredash');
  }

  Future<void> closeWiredash() async {
    // tap app which is located at the bottom of the screen
    final bottomRight = tester.getBottomRight(find.byType(Wiredash));
    await tester.tapAt(Offset(bottomRight.dx / 2, bottomRight.dy - 20));
    await tester.pumpAndSettle();
    _backdrop.childByType(WiredashFeedbackFlow).doesNotExist();
    print('closed Wiredash');
  }

  Future<void> enterFeedbackMessage(String message) async {
    _pageView.childByType(Step1FeedbackMessage).existsOnce();
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpAndSettle();
    await tester.waitUntil(
      tester.getSemantics(find.widgetWithText(TronButton, 'Next')),
      matchesSemantics(
        isEnabled: true,
        isButton: true,
        isFocusable: true,
        hasEnabledState: true,
      ),
    );
    expect(find.text('Next'), findsOneWidget);
    expect(find.text('Close'), findsOneWidget);
    print('entered feedback message: $message');
  }

  Future<void> enterEmail(String emailAddress) async {
    final step = _pageView.childByType(Step5Email).existsOnce();
    await tester.enterText(step.childByType(TextField).finder, emailAddress);
    await tester.pumpAndSettle();
    print('entered email: $emailAddress');
  }

  Future<void> skipScreenshot() async {
    final step = _pageView.childByType(Step3ScreenshotOverview).existsOnce();
    await tester.tap(step.text('Skip').finder);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped taking screenshot, next $newStatus');
  }

  Future<void> skipLabels() async {
    _pageView.childByType(Step2Labels).existsOnce();
    await goToNextStep();
    print('Skipped label selection');
  }

  Future<void> submitFeedback() async {
    final step = _pageView.childByType(Step6Submit).existsOnce();
    await tester.tap(
      find.descendant(
        of: step.childByType(TronButton).finder,
        matching: find.text('Submit'),
      ),
    );
    print('submit feedback');
    await tester.pump();
  }

  Future<void> skipEmail() async {
    final step = _pageView.childByType(Step5Email).existsOnce();
    await tester.tap(step.text('Next').finder);
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped email, next $newStatus');
  }

  Future<void> submitEmailViaButton() async {
    final step = _pageView.childByType(Step5Email).existsOnce();
    await tester.tap(step.text('Next').finder);
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
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to next $newStatus');
  }

  Future<void> goToPrevStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    await tester.tap(find.text('Back'));
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to prev $newStatus');
  }

  Future<void> enterScreenshotMode() async {
    final step = _pageView.childByType(Step3ScreenshotOverview).existsOnce();
    final noAttachemntsResult =
        step.childByType(Step3NotAttachments).finder.evaluate().toList();
    if (noAttachemntsResult.isNotEmpty) {
      step.childByType(Step3NotAttachments).existsOnce();
      await tester.tap(find.text('Add screenshot'));
    } else {
      final gallery = step.childByType(Step3WithGallery).existsOnce();
      final addAttachmentItem =
          gallery.child(find.byIcon(Wirecons.plus)).existsOnce();
      await tester.tap(addAttachmentItem.finder, warnIfMissed: false);
    }

    await tester.waitUntil(find.byType(ScreenshotBar), findsOneWidget);
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
    print('Entered screenshot mode');
  }

  Future<void> takeScreenshot() async {
    final screenshotBar = _backdrop.childByType(ScreenshotBar).existsOnce();
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotNavigating,
    );

    print('Take screeshot');
    // Click the screenshot button
    await tester.tap(screenshotBar.text('Capture').finder);
    await tester.pumpHardAndSettle();
    await tester.pumpHardAndSettle(const Duration(seconds: 1));
    await tester.pumpHardAndSettle();
    await tester.pumpAndSettle();

    // Wait for edit screen
    final nextButton = find
        .descendant(
          of: screenshotBar.childByType(TronButton).finder,
          matching: find.text('Save'),
        )
        .select;

    try {
      await tester.waitUntil(
        nextButton.finder,
        findsOneWidget,
        timeout: const Duration(seconds: 10),
      );
    } catch (e) {
      nextButton.existsOnce();
      rethrow;
    }

    expect(find.byType(ColorPalette), findsOneWidget);
  }

  Future<void> confirmDrawing() async {
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotDrawing,
    );
    final screenshotBar = _backdrop.childByType(ScreenshotBar).existsOnce();
    await tester.tap(screenshotBar.text('Save').finder);
    await tester.pumpHardAndSettle(const Duration(milliseconds: 100));

    // wait until the animation is closed
    await tester.waitUntil(screenshotBar.text('Save').finder, findsNothing);

    await tester.waitUntil(
      services.feedbackModel.feedbackFlowStatus,
      isNot(
        anyOf(
          FeedbackFlowStatus.screenshotDrawing,
          FeedbackFlowStatus.screenshotCapturing,
          FeedbackFlowStatus.screenshotNavigating,
          FeedbackFlowStatus.screenshotSaving,
        ),
      ),
    );

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Confirmed drawing $newStatus');
  }

  Future<void> selectLabel(String labelText) async {
    await tester.tap(find.text(labelText));
    await tester.pumpAndSettle();
  }

  Future<void> pressAndroidBackButton() async {
    // ignore: invalid_use_of_protected_member
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }
}
