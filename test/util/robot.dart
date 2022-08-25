// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
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
    FutureOr<void> Function()? afterPump,
    List<LocalizationsDelegate> appLocalizationsDelegates = const [],
  }) async {
    SharedPreferences.setMockInitialValues({});
    TestWidgetsFlutterBinding.ensureInitialized();
    const MethodChannel channel =
        MethodChannel('plugins.flutter.io/path_provider_macos');
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '.';
    });

    debugServicesCreator = () => createMockServices();
    addTearDown(() => debugServicesCreator = null);

    await tester.pumpWidget(
      Wiredash(
        projectId: 'test',
        secret: 'test',
        feedbackOptions: feedbackOptions,
        options: WiredashOptionsData(
          locale: const Locale('test'),
          localizationDelegate: WiredashTestLocalizationDelegate(),
        ),
        theme: WiredashThemeData(
          primaryBackgroundColor: Colors.grey,
          secondaryBackgroundColor: Colors.brown,
        ),
        child: MaterialApp(
          locale: const Locale('test'),
          localizationsDelegates: [
            ...appLocalizationsDelegates,
            DefaultWidgetsLocalizations.delegate,
          ],
          home: Builder(
            builder: builder ??
                (context) {
                  return Scaffold(
                    body: Column(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Wiredash.of(context).show();
                          },
                          child: const Text('Feedback'),
                        ),
                        GestureDetector(
                          onTap: () {
                            Wiredash.of(context)
                                .showPromoterSurvey(force: true);
                          },
                          child: const Text('Promoter Score'),
                        ),
                      ],
                    ),
                  );
                },
          ),
        ),
      ),
    );
    final robot = WiredashTestRobot(tester);
    if (afterPump != null) {
      await afterPump();
    }

    // Don't do actual http calls
    robot.services.inject<WiredashApi>((_) => MockWiredashApi.fake());

    // replace submitter, because for testing we always want to submit directly
    robot.services.inject<FeedbackSubmitter>(
      (locator) => DirectFeedbackSubmitter(robot.services.api),
    );

    return robot;
  }

  WidgetSelector get _backdrop =>
      spot.byType(Wiredash).childByType(WiredashBackdrop);

  WidgetSelector get _pageView => _backdrop.childByType(LarryPageView);

  Wiredash get widget {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return element.widget as Wiredash;
  }

  WiredashServices get services {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return (element.state as WiredashState).debugServices;
  }

  /// Equivalent to `Wiredash.of(context)`
  WiredashController get wiredashController {
    return WiredashController(services.wiredashModel);
  }

  WiredashMockServices get mockServices {
    return WiredashMockServices(services);
  }

  Future<void> openWiredash() async {
    final feedbackText = spot.byType(MaterialApp).text('Feedback').existsOnce();
    await tester.tap(feedbackText.finder);

    // process the event, wait for backdrop to appear in the widget tree
    await tester.pumpN(4);
    // wait for animation finish
    await tester.pump(const Duration(milliseconds: 500));
    // When the pump pattern on top fails, use this instead
    // await tester.pumpAndSettle();

    _backdrop.childByType(WiredashFeedbackFlow).existsOnce();
    print('opened Wiredash');
  }

  Future<void> openPromoterScore() async {
    final promoterScoreText =
        spot.byType(MaterialApp).text('Promoter Score').existsOnce();
    await tester.tap(promoterScoreText.finder);

    // process the event, wait for backdrop to appear in the widget tree
    await tester.pumpN(4);
    // wait for animation finish
    await tester.pump(const Duration(milliseconds: 500));
    // When the pump pattern on top fails, use this instead
    // await tester.pumpAndSettle();

    _backdrop.childByType(PromoterScoreFlow).existsOnce();
    print('opened promoter score');
  }

  Future<void> closeWiredash() async {
    // tap app which is located at the bottom of the screen
    final bottomRight = tester.getBottomRight(find.byType(Wiredash));
    await tester.tapAt(Offset(bottomRight.dx / 2, bottomRight.dy - 20));
    await tester.pumpAndSettle();
    _backdrop.childByType(WiredashFeedbackFlow).doesNotExist();
    _backdrop.childByType(PromoterScoreFlow).doesNotExist();
    print('closed Wiredash');
  }

  Future<void> enterFeedbackMessage(String message) async {
    _pageView.childByType(Step1FeedbackMessage).existsOnce();
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpAndSettle();
    await tester.waitUntil(
      tester.getSemantics(
        find.widgetWithText(TronButton, 'l10n.feedbackNextButton'),
      ),
      matchesSemantics(
        isEnabled: true,
        isButton: true,
        isFocusable: true,
        hasEnabledState: true,
      ),
    );
    expect(find.text('l10n.feedbackNextButton'), findsOneWidget);
    expect(find.text('l10n.feedbackCloseButton'), findsOneWidget);
    print('entered feedback message: $message');
  }

  Future<void> enterPromotionScoreMessage(String message) async {
    final step = _pageView.childByType(PsStep2Message).existsOnce();
    final done = step.text('l10n.promoterScoreSubmitButton').existsOnce();
    step.text('l10n.promoterScoreBackButton').existsOnce();
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpAndSettle();
    await tester.waitUntil(
      tester.getSemantics(done.finder),
      matchesSemantics(
        isEnabled: true,
        isButton: true,
        isFocusable: true,
        hasEnabledState: true,
      ),
    );
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
    await tester.tap(
      step.text('l10n.feedbackStep3ScreenshotOverviewSkipButton').finder,
    );
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

  /// Actually calling [FeedbackModel.submitFeedback]
  Future<void> submitFeedback() async {
    final step = _pageView.childByType(Step6Submit).existsOnce();
    await tester.tap(
      find.descendant(
        of: step.childByType(TronButton).finder,
        matching: find.text('l10n.feedbackStep6SubmitSubmitButton'),
      ),
    );
    print('submit feedback');
    await tester.pump();
  }

  Future<void> skipEmail() async {
    final step = _pageView.childByType(Step5Email).existsOnce();
    await tester.tap(step.text('l10n.feedbackNextButton').finder);
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped email, next $newStatus');
  }

  Future<void> submitEmailViaButton() async {
    final step = _pageView.childByType(Step5Email).existsOnce();
    await tester.tap(step.text('l10n.feedbackNextButton').finder);
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
    await tester.tap(find.text('l10n.feedbackNextButton'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to next $newStatus');
  }

  Future<void> goToPrevStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    await tester.tap(find.text('l10n.feedbackBackButton'));
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
      await tester.tap(
        find.text('l10n.feedbackStep3ScreenshotOverviewAddScreenshotButton'),
      );
    } else {
      final gallery = step.childByType(Step3WithGallery).existsOnce();
      final addAttachmentItem =
          gallery.child(find.byIcon(Wirecons.plus)).existsOnce();
      await tester.tap(addAttachmentItem.finder, warnIfMissed: false);
    }

    await tester.waitUntil(find.byType(ScreenshotBar), findsOneWidget);
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    expect(
      find.text('l10n.feedbackStep3ScreenshotBarCaptureButton'),
      findsOneWidget,
    );
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
    await tester.tap(
      screenshotBar.text('l10n.feedbackStep3ScreenshotBarCaptureButton').finder,
    );
    while (services.feedbackModel.feedbackFlowStatus !=
        FeedbackFlowStatus.screenshotDrawing) {
      await tester.pumpHardAndSettle();
    }

    // Wait for active "Save" button
    final nextButton = screenshotBar.childByType(
      TronButton,
      children: [spot.text('l10n.feedbackStep3ScreenshotBarSaveButton')],
    );

    try {
      await tester.waitUntil(nextButton.finder, findsOneWidget);
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
    await tester.tap(
      screenshotBar.text('l10n.feedbackStep3ScreenshotBarSaveButton').finder,
    );
    await tester.pumpHardAndSettle(const Duration(milliseconds: 100));

    // wait until the animation is closed
    await tester.waitUntil(
      screenshotBar.text('l10n.feedbackStep3ScreenshotBarSaveButton').finder,
      findsNothing,
    );

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

  Future<void> waitUntilWiredashIsClosed() async {
    await tester.pump(const Duration(seconds: 1));
    await tester.waitUntil(
      () => services.wiredashModel.isWiredashActive,
      isFalse,
    );
  }

  Future<void> ratePromoterScore(int rating) async {
    assert(rating >= 0 && rating <= 10);
    final step = _pageView.childByType(PsStep1Rating).existsOnce();
    await tester.tap(step.text(rating.toString()).finder);
    await tester.pumpAndSettle();

    /// automatically goes to next step
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
  }

  Future<void> submitPromoterScore() async {
    final step = _pageView.childByType(PsStep2Message).existsOnce();
    final submitButton = step.byType(
      TronButton,
      children: [spot.text('l10n.promoterScoreSubmitButton')],
    ).existsOnce();
    await tester.scrollUntilVisible(
      submitButton.finder,
      -100,
      scrollable: spot
          .byType(LarryPageView)
          .childByType(StepPageScaffold)
          .childByType(ScrollBox)
          .childByType(SingleChildScrollView)
          .child(find.byType(Scrollable).first)
          .finder,
    );
    await tester.tap(submitButton.finder);
    await tester.pumpAndSettle();
    print('submit Promoter Score');
  }

  Future<void> showsPromoterScoreThanksMessage([Finder? finder]) async {
    final step = _pageView.childByType(PsStep3Thanks).existsOnce();
    if (finder != null) {
      step.child(finder).existsOnce();
    }
  }
}

class WiredashMockServices {
  final WiredashServices services;

  WiredashMockServices(this.services);

  MockWiredashApi get mockApi => services.api as MockWiredashApi;
}

WiredashServices createMockServices() {
  final services = WiredashServices();
  services.inject<WiredashApi>((_) => MockWiredashApi.fake());
  return services;
}

class WiredashTestLocalizationDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  @override
  bool isSupported(_) => true;

  @override
  Future<WiredashLocalizations> load(Locale locale) {
    return SynchronousFuture(ReturnKeysWiredashLocalizations());
  }

  @override
  bool shouldReload(_) => false;
}

class MaterialTestLocalizationDelegate
    extends LocalizationsDelegate<MaterialLocalizations> {
  @override
  bool isSupported(_) => true;

  @override
  Future<MaterialLocalizations> load(Locale locale) {
    return SynchronousFuture(ReturnKeysMaterialLocalizations());
  }

  @override
  bool shouldReload(_) => false;
}

class CupertinoTestLocalizationDelegate
    extends LocalizationsDelegate<CupertinoLocalizations> {
  @override
  bool isSupported(_) => true;

  @override
  Future<CupertinoLocalizations> load(Locale locale) {
    return SynchronousFuture(ReturnKeysCupertinoLocalizations());
  }

  @override
  bool shouldReload(_) => false;
}

class ReturnKeysWiredashLocalizations extends WiredashLocalizations
    with ReturnTranslationsKeysMixin {
  ReturnKeysWiredashLocalizations() : super('test');
}

class ReturnKeysCupertinoLocalizations extends CupertinoLocalizations
    with ReturnTranslationsKeysMixin {
  ReturnKeysCupertinoLocalizations();
}

class ReturnKeysMaterialLocalizations extends MaterialLocalizations
    with ReturnTranslationsKeysMixin {
  @override
  ScriptCategory get scriptCategory => ScriptCategory.englishLike;

  ReturnKeysMaterialLocalizations();
}

mixin ReturnTranslationsKeysMixin {
  @override
  dynamic noSuchMethod(Invocation invocation) {
    const prefix = 'l10n.';
    if (invocation.isGetter) {
      return "$prefix${invocation.memberName.symbolName}";
    }
    if (invocation.isMethod) {
      if (invocation.positionalArguments.isNotEmpty) {
        final args = invocation.positionalArguments.join(",");
        return "$prefix${invocation.memberName.symbolName}_($args)";
      }
    }
  }
}

extension on Symbol {
  String get symbolName {
    return toString()
        .characters
        .skip("Symbol('".length)
        .skipLast("')".length)
        .toString();
  }
}
