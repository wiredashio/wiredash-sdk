// ignore_for_file: avoid_print

import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spot/spot.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/wiredash.dart';

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
    // Replace with tester.binding.defaultBinaryMessenger.setMockMethodCallHandler when we drop support for Flutter v3.9.0-19.0.pre.
    // ignore: deprecated_member_use
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

  WidgetSelector<WiredashBackdrop> get _spotBackdrop =>
      spot<Wiredash>().last().spotSingle<WiredashBackdrop>();

  WidgetSelector<LarryPageView> get _spotPageView =>
      _spotBackdrop.spotSingle<LarryPageView>();

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
    final feedbackText = spotSingle<MaterialApp>().spotSingleText('Feedback')
      ..existsOnce();
    await _tap(feedbackText);

    // process the event, wait for backdrop to appear in the widget tree
    await tester.pumpN(4);
    // wait for animation finish
    await tester.pump(const Duration(milliseconds: 500));
    // When the pump pattern on top fails, use this instead
    // await tester.pumpAndSettle();

    _spotBackdrop.spotSingle<WiredashFeedbackFlow>().existsOnce();
    print('opened Wiredash');
  }

  Future<void> openPromoterScore() async {
    final promoterScoreText = spotSingle<MaterialApp>()
        .spotSingleText('Promoter Score')
      ..existsOnce();
    await _tap(promoterScoreText);

    // process the event, wait for backdrop to appear in the widget tree
    await tester.pumpN(4);
    // wait for animation finish
    await tester.pump(const Duration(milliseconds: 500));
    // When the pump pattern on top fails, use this instead
    // await tester.pumpAndSettle();

    _spotBackdrop.spotSingle<PromoterScoreFlow>().existsOnce();
    print('opened promoter score');
  }

  Future<void> closeWiredash() async {
    // tap app which is located at the bottom of the screen
    final bottomRight = tester.getBottomRight(find.byType(Wiredash));
    await tester.tapAt(Offset(bottomRight.dx / 2, bottomRight.dy - 20));
    await tester.pumpAndSettle();
    _spotBackdrop.spotSingle<WiredashFeedbackFlow>().doesNotExist();
    _spotBackdrop.spotSingle<PromoterScoreFlow>().doesNotExist();
    print('closed Wiredash');
  }

  Future<void> enterFeedbackMessage(String message) async {
    _spotPageView.spotSingle<Step1FeedbackMessage>().existsOnce();
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
    final step = _spotPageView.spotSingle<PsStep2Message>()..existsOnce();
    final done = step.spotSingleText('l10n.promoterScoreSubmitButton')
      ..existsOnce();
    step.spotSingleText('l10n.promoterScoreBackButton').existsOnce();
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
    final step = _spotPageView.spotSingle<Step5Email>()..existsOnce();
    await tester.enterText(step.spotSingle<TextField>().finder, emailAddress);
    await tester.pumpAndSettle();
    print('entered email: $emailAddress');
  }

  Future<void> skipScreenshot() async {
    final step = _spotPageView.spotSingle<Step3ScreenshotOverview>()
      ..existsOnce();
    await _tap(
      step.spotSingleText('l10n.feedbackStep3ScreenshotOverviewSkipButton'),
    );
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped taking screenshot, next $newStatus');
  }

  Future<void> skipLabels() async {
    _spotPageView.spotSingle<Step2Labels>().existsOnce();
    await goToNextStep();
    print('Skipped label selection');
  }

  /// Actually calling [FeedbackModel.submitFeedback]
  Future<void> submitFeedback() async {
    final step = _spotPageView.spotSingle<Step6Submit>()..existsOnce();
    await _tap(
      step.spot<TronButton>(
        children: [step.spotSingleText('l10n.feedbackStep6SubmitSubmitButton')],
      ).last(),
    );
    print('submit feedback');
    await tester.pump();
  }

  Future<void> skipEmail() async {
    final step = _spotPageView.spotSingle<Step5Email>()..existsOnce();
    await _tap(step.spotSingleText('l10n.feedbackNextButton'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped email, next $newStatus');
  }

  Future<void> submitEmailViaButton() async {
    final step = _spotPageView.spotSingle<Step5Email>()..existsOnce();
    await _tap(step.spotSingleText('l10n.feedbackNextButton'));
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
    await _tap(spotSingleText('l10n.feedbackNextButton'));
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to next $newStatus');
  }

  Future<void> goToPrevStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    final texts = spotTexts('l10n.feedbackBackButton');
    final backdropStatus = services.backdropController.backdropStatus;

    if (backdropStatus == WiredashBackdropStatus.centered) {
      await _tap(texts.last());
    } else {
      await _tap(texts.first());
    }

    await tester.pumpAndSettle();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped back from $oldStatus to prev $newStatus');
  }

  Future<void> enterScreenshotMode() async {
    final step = _spotPageView.spotSingle<Step3ScreenshotOverview>()
      ..existsOnce();
    final noAttachmentsResult =
        step.spot<Step3NoAttachments>().snapshot().discovered;
    if (noAttachmentsResult.isNotEmpty) {
      step.spot<Step3NoAttachments>().existsOnce();
      final addScreenshotBtn = spotSingleText(
        'l10n.feedbackStep3ScreenshotOverviewAddScreenshotButton',
      );
      await _tap(addScreenshotBtn);
    } else {
      final gallery = step.spotSingle<Step3WithGallery>()..existsOnce();
      final addAttachmentItem = gallery.spotSingleIcon(Wirecons.plus)
        ..existsOnce();
      // TODO
      await _tap(
        addAttachmentItem, /* warnIfMissed: false*/
      );
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
    final screenshotBar = _spotBackdrop.spotSingle<ScreenshotBar>()
      ..existsOnce();
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotNavigating,
    );

    print('Take screeshot');
    // Click the screenshot button
    await _tap(
      screenshotBar
          .spotSingleText('l10n.feedbackStep3ScreenshotBarCaptureButton'),
    );
    while (services.feedbackModel.feedbackFlowStatus !=
        FeedbackFlowStatus.screenshotDrawing) {
      await tester.pumpHardAndSettle();
    }

    // Wait for active "Save" button
    final nextButton = screenshotBar.spotSingle<TronButton>(
      children: [spotSingleText('l10n.feedbackStep3ScreenshotBarSaveButton')],
    ).last();

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
    final screenshotBar = _spotBackdrop.spotSingle<ScreenshotBar>()
      ..existsOnce();
    await _tap(
      screenshotBar.spotSingleText('l10n.feedbackStep3ScreenshotBarSaveButton'),
    );
    await tester.pumpHardAndSettle(const Duration(milliseconds: 100));

    // wait until the animation is closed
    await tester.waitUntil(
      screenshotBar
          .spotSingleText('l10n.feedbackStep3ScreenshotBarSaveButton')
          .finder,
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
    await _tap(spotSingleText(labelText));
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
    final step = _spotPageView.spotSingle<PsStep1Rating>()..existsOnce();
    await _tap(step.spotSingleText(rating.toString()));
    await tester.pumpAndSettle();

    /// automatically goes to next step
    await tester.pumpAndSettle();
    await tester.pumpAndSettle();
    await tester.pumpAndSettle(const Duration(milliseconds: 600));
  }

  Future<void> submitPromoterScore() async {
    final step = _spotPageView.spotSingle<PsStep2Message>()..existsOnce();
    final submitButton = step.spot<TronButton>(
      children: [spotSingleText('l10n.promoterScoreSubmitButton')],
    ).last()
      ..existsOnce();
    await tester.scrollUntilVisible(
      submitButton.finder,
      -100,
      scrollable: spotSingle<LarryPageView>()
          .spotSingle<StepPageScaffold>()
          .spotSingle<ScrollBox>()
          .spotSingle<SingleChildScrollView>()
          .spot<Scrollable>()
          .first()
          .finder,
    );
    await _tap(submitButton);
    await tester.pumpAndSettle();
    print('submit Promoter Score');
  }

  Future<void> showsPromoterScoreThanksMessage([Finder? finder]) async {
    final step = _spotPageView.spotSingle<PsStep3Thanks>()..existsOnce();
    if (finder != null) {
      step.spotFinder(finder).existsOnce();
    }
  }

  Future<void> _tap(SingleWidgetSelector spot) async {
    await tester.tap(spot.finder);
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
