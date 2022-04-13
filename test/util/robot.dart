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

  WidgetSelector get _backdropSelector =>
      assertWidget(Wiredash).child(WiredashBackdrop);
  WidgetSelector get _pageViewSelector =>
      _backdropSelector.child(LarryPageView);

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
    _backdropSelector.child(WiredashFeedbackFlow).existsOnce();
    print('opened Wiredash');
  }

  Future<void> closeWiredash() async {
    // tap app which is located at the bottom of the screen
    final bottomRight = tester.getBottomRight(find.byType(Wiredash));
    await tester.tapAt(Offset(bottomRight.dx / 2, bottomRight.dy - 20));
    await tester.pumpAndSettle();
    _backdropSelector.child(WiredashFeedbackFlow).doesNotExist();
    print('closed Wiredash');
  }

  Future<void> enterFeedbackMessage(String message) async {
    _pageViewSelector.child(Step1FeedbackMessage).existsOnce();
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
    _pageViewSelector.child(Step5Email).existsOnce();
    await tester.enterText(find.byType(TextField), emailAddress);
    await tester.pumpAndSettle();
    print('entered email: $emailAddress');
  }

  Future<void> skipScreenshot() async {
    _pageViewSelector.child(Step3ScreenshotOverview).existsOnce();
    await tester.tap(find.text('Skip'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped taking screenshot, next $newStatus');
  }

  Future<void> skipLabels() async {
    _pageViewSelector.child(Step2Labels).existsOnce();
    await goToNextStep();
    print('Skipped label selection');
  }

  Future<void> submitFeedback() async {
    _pageViewSelector.child(Step6Submit).existsOnce();
    await tester.tap(
      find.descendant(
        of: find.byType(TronButton),
        matching: find.text('Submit'),
      ),
    );
    print('submit feedback');
    await tester.pump();
  }

  Future<void> skipEmail() async {
    _pageViewSelector.child(Step5Email).existsOnce();
    await tester.tap(find.text('Next'));
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped email, next $newStatus');
  }

  Future<void> submitEmailViaButton() async {
    _pageViewSelector.child(Step5Email).existsOnce();
    await tester.tap(find.text('Next'));
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
    _pageViewSelector.child(Step3ScreenshotOverview).existsOnce();
    final noAttachemntsResult =
        find.byType(Step3NotAttachments).evaluate().toList();
    if (noAttachemntsResult.isNotEmpty) {
      expect(find.byType(Step3NotAttachments), findsOneWidget);
      await tester.tap(find.text('Add screenshot'));
    } else {
      expect(find.byType(Step3WithGallery), findsOneWidget);
      await tester.tap(find.byIcon(Wirecons.plus), warnIfMissed: false);
    }

    await tester.waitUntil(find.byType(ScreenshotBar), findsOneWidget);
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    expect(find.text('Capture'), findsOneWidget);
    print('Entered screenshot mode');
  }

  Future<void> takeScreenshot() async {
    _backdropSelector.child(ScreenshotBar).existsOnce();
    expect(find.byType(ScreenshotBar), findsOneWidget);
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotNavigating,
    );

    print('Take screeshot');
    // Click the screenshot button
    await tester.tap(find.text('Capture'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(seconds: 1));
    await tester.pumpAndSettle();

    // Wait for edit screen
    final nextButton = find.descendant(
      of: find.byType(TronButton),
      matching: find.text('Save'),
    );
    await tester.waitUntil(nextButton, findsOneWidget);

    expect(find.byType(ColorPalette), findsOneWidget);
  }

  Future<void> confirmDrawing() async {
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotDrawing,
    );
    await tester.tap(find.text('Save'));
    await tester.pumpHardAndSettle(const Duration(milliseconds: 100));

    // wait until the animation is closed
    await tester.waitUntil(find.text('Save'), findsNothing);

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
    await tester.tap(find.text('Two'));
    await tester.pumpAndSettle();
  }

  Future<void> pressAndroidBackButton() async {
    // ignore: invalid_use_of_protected_member
    await tester.binding.handlePopRoute();
    await tester.pumpAndSettle();
  }
}
