// ignore_for_file: avoid_print

import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nanoid2/nanoid2.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:spot/spot.dart';
import 'package:wiredash/src/an4lytics/ev3nt_submitter.dart';
import 'package:wiredash/src/core/theme/wirecons.dart';
import 'package:wiredash/src/core/widgets/backdrop/step_page_scaffold.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/core/widgets/larry_page_view.dart';
import 'package:wiredash/src/core/widgets/tron/tron_button.dart';
import 'package:wiredash/src/core/wiredash_widget.dart';
import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';
import 'package:wiredash/src/feedback/feedback_flow.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/steps/step_1_feedback_message.dart';
import 'package:wiredash/src/feedback/steps/step_2_labels.dart';
import 'package:wiredash/src/feedback/steps/step_3_screenshot_overview.dart';
import 'package:wiredash/src/feedback/steps/step_5_email.dart';
import 'package:wiredash/src/feedback/steps/step_6_submit.dart';
import 'package:wiredash/src/feedback/ui/color_palette.dart';
import 'package:wiredash/src/feedback/ui/screenshot_bar.dart';

// ignore: unused_import
import 'package:wiredash/src/metadata/meta_data_collector.dart';
import 'package:wiredash/src/promoterscore/ps_flow.dart';
import 'package:wiredash/src/promoterscore/step_1_rating.dart';
import 'package:wiredash/src/promoterscore/step_2_message.dart';
import 'package:wiredash/src/promoterscore/step_3_thanks.dart';
import 'package:wiredash/wiredash.dart';

import 'mock_api.dart';
import 'wiredash_tester.dart';

class WiredashTestRobot {
  final WidgetTester tester;

  WiredashTestRobot(this.tester);

  bool _settedUpMock = false;

  void setupMocks() {
    if (_settedUpMock) return;
    _settedUpMock = true;
    SharedPreferences.setMockInitialValues({
      'mocked': true,
    });
    addTearDown(() => SharedPreferences.setMockInitialValues({}));
    PackageInfo.setMockInitialValues(
      appName: 'Wiredash Test',
      packageName: 'io.wiredash.test',
      version: '9.9.9',
      buildNumber: '9001',
      buildSignature: 'buildSignature',
      // ignore: avoid_redundant_argument_values
      installerStore: null,
    );
    addTearDown(
      () => PackageInfo.setMockInitialValues(
        appName: '',
        packageName: '',
        version: '',
        buildNumber: '',
        buildSignature: '',
        installerStore: '',
      ),
    );
    TestWidgetsFlutterBinding.ensureInitialized();

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('dev.fluttercommunity.plus/device_info'),
        (MethodCall methodCall) async {
      if (methodCall.method == 'getDeviceInfo') {
        return <String, dynamic>{
          'version': <String, dynamic>{
            'baseOS': 'fake-baseOD',
            'codename': 'fake-codename',
            'incremental': 'fake-incremental',
            'previewSdkInt': 9001,
            'release': 'FakeOS 9000',
            'sdkInt': 9000,
            'securityPatch': 'fake-securityPatch',
          },
          'board': 'fake-board',
          'bootloader': 'fake-bootloader',
          'brand': 'Canvas',
          'device': 'fake-device',
          'display': 'fake-display',
          'fingerprint': 'fake-fingerprint',
          'hardware': 'fake-hardware',
          'host': 'fake-host',
          'id': 'fake-id',
          'manufacturer': 'Instructure',
          'model': 'Some Phone',
          'modelName': 'Some Phone',
          'product': 'fake-product',
          'supported32BitAbis': [],
          'supported64BitAbis': [],
          'supportedAbis': [],
          'tags': 'fake-tags',
          'type': 'take-types',
          'isPhysicalDevice': false,
          'androidId': 'fake-androidId',
          'displayMetrics': <String, dynamic>{
            'widthPx': 100.0,
            'heightPx': 100.0,
            'xDpi': 100.0,
            'yDpi': 100.0,
          },
          'serialNumber': 'fake-serialNumber',
          'computerName': 'a',
          'hostName': 'a',
          'arch': 'a',
          'kernelVersion': 'a',
          'osRelease': 'Version OS (Build 22D68)',
          'majorVersion': 10,
          'minorVersion': 0,
          'patchVersion': 1,
          'activeCPUs': 0,
          'memorySize': 0,
          'cpuFrequency': 0,
          'systemGUID': 'a',
          'name': 'name',
          'idLike': [],
          'versionCodename': 'versionCodename',
          'versionId': 'versionId',
          'prettyName': 'prettyName',
          'buildId': 'buildId',
          'variant': 'variant',
          'variantId': 'variantId',
          'machineId': 'machineId',
        };
      }
      return null;
    });

    tester.binding.defaultBinaryMessenger.setMockMethodCallHandler(
        const MethodChannel('plugins.flutter.io/path_provider_macos'),
        (call) async {
      if (call.method == 'getApplicationDocumentsDirectory') {
        return '.';
      }
      return null;
    });
  }

  Future<WiredashTestRobot> launchApp({
    WiredashFeedbackOptions? feedbackOptions,
    PsOptions? psOptions,
    String? environment,
    FutureOr<CustomizableWiredashMetaData> Function(
      CustomizableWiredashMetaData metaData,
    )? collectMetaData,
    Widget Function(BuildContext)? builder,
    String? projectId,
    FutureOr<void> Function()? afterPump,
    List<LocalizationsDelegate> appLocalizationsDelegates = const [],
    bool useDirectFeedbackSubmitter = true,
    bool useDirectEventSubmitter = true,
    bool wrapWithWiredash = true,
    bool firstLaunch = false,
  }) async {
    setupMocks();
    await loadAppFonts();
    // spot's loadAppFonts() reads wiredash's pubspec and registers "Inter" /
    // "Wirecons" — but wiredash's TextStyles set `package: 'wiredash'`, so the
    // engine actually looks up "packages/wiredash/Inter" / "packages/wiredash/
    // Wirecons". Re-register under those names so Wiredash text isn't rendered
    // with the Ahem fallback. Remove once spot itself bridges this for
    // self-tested package fonts.
    await loadFont('packages/wiredash/Inter', const [
      'lib/assets/fonts/Inter-Regular.ttf',
      'lib/assets/fonts/Inter-SemiBold.ttf',
      'lib/assets/fonts/Inter-Bold.ttf',
    ]);
    await loadFont('packages/wiredash/Wirecons', const [
      'lib/assets/fonts/Wirecons.ttf',
    ]);
    WiredashServices.debugServicesCreator = () => createMockServices(
          useDirectFeedbackSubmitter: useDirectFeedbackSubmitter,
          useDirectEventSubmitter: useDirectEventSubmitter,
        );
    addTearDown(() => WiredashServices.debugServicesCreator = null);

    if (!firstLaunch) {
      await regenerateAnalyticsId();
    }

    Widget child = MaterialApp(
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
                      onTap: () async {
                        feedbackResult = await Wiredash.of(context).show();
                      },
                      child: const Text('Feedback'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Wiredash.of(context).showPromoterSurvey(force: true);
                      },
                      child: const Text('Promoter Score'),
                    ),
                    GestureDetector(
                      onTap: () {
                        Wiredash.of(context).trackEvent(
                          'default_event',
                          data: {
                            'wire': 'dash',
                          },
                        );
                      },
                      child: const Text('Send event'),
                    ),
                  ],
                ),
              );
            },
      ),
    );
    if (wrapWithWiredash) {
      child = Wiredash(
        projectId: projectId ?? 'test',
        secret: 'test',
        environment: environment,
        feedbackOptions: feedbackOptions,
        psOptions: psOptions,
        collectMetaData: collectMetaData,
        options: WiredashOptionsData(
          locale: const Locale('test'),
          localizationDelegate: WiredashTestLocalizationDelegate(),
        ),
        theme: WiredashThemeData(
          primaryBackgroundColor: Colors.grey,
          secondaryBackgroundColor: Colors.brown,
        ),
        child: child,
      );
    }
    await tester.pumpWidget(child);
    if (afterPump != null) {
      await afterPump();
    }

    return this;
  }

  FeedbackResult? feedbackResult;

  WidgetSelector<WiredashBackdrop> get _spotBackdrop =>
      spot<Wiredash>().last().spot<WiredashBackdrop>();

  WidgetSelector<LarryPageView> get _spotPageView =>
      _spotBackdrop.spot<LarryPageView>();

  LarryPageView get pageView =>
      tester.widget<LarryPageView>(_spotPageView.finder);

  int get pageIndex => pageView.pageIndex;

  int get pageCount => pageView.stepCount;

  void verifyOnPage(int index) {
    expect(pageIndex, index);
  }

  void verifyHasNextPage() {
    expect(pageIndex + 1, lessThan(pageCount));
  }

  void verifyPageCount(int count) {
    expect(pageCount, count);
  }

  Wiredash get widget {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return element.widget as Wiredash;
  }

  WiredashServices get services {
    final element = find.byType(Wiredash).evaluate().first as StatefulElement;
    return (element.state as WiredashState).debugServices;
  }

  WiredashServices servicesWith({String? projectId, String? environment}) {
    final elements =
        find.byType(Wiredash).evaluate().map((e) => e as StatefulElement);
    final element = elements.firstWhere((e) {
      final widget = (e.state as WiredashState).widget;
      return (projectId == null || widget.projectId == projectId) &&
          (environment == null || widget.environment == environment);
    });
    return (element.state as WiredashState).debugServices;
  }

  /// Equivalent to `Wiredash.of(context)`
  WiredashController get wiredashController {
    return WiredashController(services.wiredashModel);
  }

  WiredashMockServices get mockServices {
    return WiredashMockServices(services);
  }

  Future<void> regenerateAnalyticsId() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('_wiredashAppUsageID', nanoid(length: 16));
  }

  Future<void> submitMinimalFeedback() async {
    await goToMinimalFeedbackSubmitStep();
    await submitFeedback();
    await waitUntilWiredashIsClosed();
  }

  Future<void> goToMinimalFeedbackSubmitStep() async {
    await openWiredash();
    await enterFeedbackMessage('test message');
    await goToNextStep();
    await skipScreenshot();
    await skipEmail();
  }

  Future<PendingFeedbackSubmission> startPendingFeedbackSubmission() async {
    final sendFeedback = Completer<void>();
    mockServices.mockApi.sendFeedbackInvocations.interceptor =
        (_) => sendFeedback.future;
    await _tapSubmitFeedbackButton();
    await tester.pump();

    while (mockServices.mockApi.sendFeedbackInvocations.count == 0) {
      await tester.pump();
    }

    return PendingFeedbackSubmission(sendFeedback);
  }

  Future<void> openWiredash() async {
    feedbackResult = null;
    final feedbackText = spot<MaterialApp>().spotText('Feedback')..existsOnce();
    await act.tap(feedbackText);
    await tester.pumpSmart();

    _spotBackdrop.spot<WiredashFeedbackFlow>().existsOnce();
    print('opened Wiredash');
  }

  Future<void> openPromoterScore() async {
    final promoterScoreText = spot<MaterialApp>().spotText('Promoter Score')
      ..existsOnce();
    await act.tap(promoterScoreText);
    await tester.pumpSmart();

    _spotBackdrop.spot<PromoterScoreFlow>().existsOnce();
    print('opened promoter score');
  }

  Future<void> triggerAnalyticsEvent() async {
    await act.tap(spotText('Send event'));
    await tester.pumpSmart();
    print('sent event');
  }

  Future<void> closeWiredashWithButton() async {
    _spotPageView.spot<Step1FeedbackMessage>().existsOnce();
    final spotCloseButton = _spotBackdrop.spot<TronButton>(
      children: [
        spotText('l10n.feedbackCloseButton'),
      ],
    )..existsOnce();
    await act.tap(spotCloseButton);
    await tester.pumpSmart();
    print('closed Wiredash');
  }

  Future<void> closeWiredash() async {
    // tap app which is located at the bottom of the screen
    final bottomRight = tester.getBottomRight(find.byType(Wiredash));
    await tester.tapAt(Offset(bottomRight.dx / 2, bottomRight.dy - 20));
    await tester.pumpSmart();
    _spotBackdrop.spot<WiredashFeedbackFlow>().doesNotExist();
    _spotBackdrop.spot<PromoterScoreFlow>().doesNotExist();
    print('closed Wiredash');
  }

  Future<void> moveAppToBackground() async {
    print('Robot: Moving app to background');

    // iPad: resumed | (move to background) | inactive, hidden, paused
    // iPad: resumed | (app switcher) | inactive
    // iPad: resumed | (app switcher -> kill) | inactive, hidden, paused, detached | <dead>
    // macos: resumed | (app switcher) | inactive
    // macos: resumed | (minimize) | inactive, hidden
    // macos: resumed | (CMD + Q) or close button | <dead>
    // android: resumed | (switch app) | inactive, hidden, paused
    // android: resumed | (app switcher -> kill) | inactive, hidden, paused
    // android: resumed | (home) | inactive, hidden, paused
    // android: resumed | (back (close)) | inactive, hidden, paused, detached | <dead>
    // chrome: resumed | (switch tab) | inactive, hidden
    // chrome: resumed | (switch app) | inactive
    // chrome: resumed | (close tab) | hidden | <dead>
    TestWidgetsFlutterBinding.instance
        .handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    addTearDown(() {
      // reset to default
      TestWidgetsFlutterBinding.instance
          .handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    });
    await tester.pumpSmart(const Duration(seconds: 1));
  }

  Future<void> enterFeedbackMessage(String message) async {
    _spotPageView.spot<Step1FeedbackMessage>().existsOnce();
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpSmart();
    final button = spot<TronButton>(
      children: [spotText('l10n.feedbackNextButton')],
    );

    // TODO find easier way to check if the button is clickable. Hit Testing?
    await button.waitUntil(tester, (it) => it.single.isTappable(true));

    expect(find.text('l10n.feedbackNextButton'), findsOneWidget);
    expect(find.text('l10n.feedbackCloseButton'), findsOneWidget);
    print('entered feedback message: $message');
  }

  Future<void> enterPromotionScoreMessage(String message) async {
    final step = _spotPageView.spot<PsStep2Message>()..existsOnce();
    final done = step.spot<TronButton>(
      children: [spotText('l10n.promoterScoreSubmitButton')],
    )..existsOnce();
    step.spotText('l10n.promoterScoreBackButton').existsOnce();
    await tester.enterText(find.byType(TextField), message);
    await tester.pumpSmart();

    // TODO find easier way to check if the button is clickable. Hit Testing?
    await done.waitUntil(tester, (it) => it.single.isTappable(true));

    print('entered feedback message: $message');
  }

  Future<void> enterEmail(String emailAddress) async {
    final step = _spotPageView.spot<Step5Email>()..existsOnce();
    await tester.enterText(step.spot<TextField>().finder, emailAddress);
    await tester.pumpSmart();
    print('entered email: $emailAddress');
  }

  Future<void> skipScreenshot() async {
    final step = _spotPageView.spot<Step3ScreenshotOverview>()..existsOnce();
    await act.tap(
      step.spotText('l10n.feedbackStep3ScreenshotOverviewSkipButton'),
    );
    await tester.pumpSmart();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Skipped taking screenshot, next $newStatus');
  }

  Future<void> skipLabels() async {
    _spotPageView.spot<Step2Labels>().existsOnce();
    await goToNextStep();
    print('Skipped label selection');
  }

  /// Actually calling [FeedbackModel.submitFeedback]
  Future<void> submitFeedback() async {
    await _tapSubmitFeedbackButton();
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 100));
  }

  Future<void> _tapSubmitFeedbackButton() async {
    final step = _spotPageView.spot<Step6Submit>()..existsOnce();
    await act.tap(
      step.spot<TronButton>(
        children: [step.spotText('l10n.feedbackStep6SubmitSubmitButton')],
      ).last(),
    );
    print('submit feedback');
  }

  Future<void> skipEmail({bool catchError = true}) async {
    final step = _spotPageView.spot<Step5Email>()..existsOnce();
    await act.tap(step.spotText('l10n.feedbackNextButton'));
    await tester.pumpSmart();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    if (catchError) {
      // no email validation error
      step.spotText('l10n.feedbackStep4EmailInvalidEmail').doesNotExist();
      expect(newStatus, isNot(FeedbackFlowStatus.email));
      print('Skipped email, next $newStatus');
    }
  }

  Future<void> submitEmailViaButton() async {
    final step = _spotPageView.spot<Step5Email>()..existsOnce();
    await act.tap(step.spotText('l10n.feedbackNextButton'));
    await tester.pumpSmart();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Submitted email, next $newStatus');
  }

  Future<void> submitEmailViaKeyboard() async {
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pumpSmart();

    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Submitted email, next $newStatus');
  }

  Future<void> goToNextStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    await act.tap(spotText('l10n.feedbackNextButton'));
    await tester.pumpSmart();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped from $oldStatus to next $newStatus');
  }

  Future<void> goToPrevStep() async {
    final oldStatus = services.feedbackModel.feedbackFlowStatus;
    final texts = spotText('l10n.feedbackBackButton');
    final backdropStatus = services.backdropController.backdropStatus;

    if (backdropStatus == WiredashBackdropStatus.centered) {
      await act.tap(texts.last());
    } else {
      await act.tap(texts.first());
    }

    await tester.pumpSmart();
    final newStatus = services.feedbackModel.feedbackFlowStatus;
    print('Jumped back from $oldStatus to prev $newStatus');
  }

  Future<void> swipeToNext() async {
    final topRight = tester.getTopRight(find.byType(LarryPageView));

    // fling up
    await tester.flingFrom(
      Offset(topRight.dx / 2, topRight.dy + 20),
      // only a bit up so that the close button is still visible
      const Offset(0, -5000),
      5000,
    );
    await tester.pumpSmart();
  }

  Future<void> enterScreenshotMode() async {
    final step = _spotPageView.spot<Step3ScreenshotOverview>()..existsOnce();
    final noAttachmentsResult =
        step.spot<Step3NoAttachments>().snapshot().discovered;
    if (noAttachmentsResult.isNotEmpty) {
      step.spot<Step3NoAttachments>().existsOnce();
      final addScreenshotBtn = spotText(
        'l10n.feedbackStep3ScreenshotOverviewAddScreenshotButton',
      );
      await act.tap(addScreenshotBtn);
    } else {
      final gallery = step.spot<Step3WithGallery>()..existsOnce();
      final addAttachmentItem = gallery.spot<NewAttachment>()..existsOnce();
      await act.tap(addAttachmentItem);
    }
    await tester.pumpSmart();
    await tester.waitUntil(find.byType(ScreenshotBar), findsOneWidget);
    await tester.waitUntil(find.byIcon(Wirecons.camera), findsOneWidget);
    expect(
      find.text('l10n.feedbackStep3ScreenshotBarCaptureButton'),
      findsOneWidget,
    );
    print('Entered screenshot mode');
  }

  Future<void> takeScreenshot() async {
    final screenshotBar = _spotBackdrop.spot<ScreenshotBar>()..existsOnce();
    expect(
      services.feedbackModel.feedbackFlowStatus,
      FeedbackFlowStatus.screenshotNavigating,
    );
    print('Take screenshot');
    // Click the screenshot button
    await act.tap(
      screenshotBar.spotText('l10n.feedbackStep3ScreenshotBarCaptureButton'),
    );
    await tester.waitUntil(
      () => services.feedbackModel.feedbackFlowStatus,
      equals(FeedbackFlowStatus.screenshotDrawing),
    );
    // Wait for active "Save" button
    final nextButton = screenshotBar.spot<TronButton>(
      children: [spotText('l10n.feedbackStep3ScreenshotBarSaveButton')],
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
    final screenshotBar = _spotBackdrop.spot<ScreenshotBar>()..existsOnce();
    await act.tap(
      screenshotBar.spotText('l10n.feedbackStep3ScreenshotBarSaveButton'),
    );
    await tester.pumpSmart(const Duration(milliseconds: 100));

    // wait until the animation is closed
    await tester.waitUntil(
      screenshotBar
          .spotText('l10n.feedbackStep3ScreenshotBarSaveButton')
          .finder,
      findsNothing,
    );

    await tester.waitUntil(
      () => services.feedbackModel.feedbackFlowStatus,
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
    await act.tap(spotText(labelText));
    await tester.pumpSmart();
  }

  Future<void> pressAndroidBackButton() async {
    // ignore: invalid_use_of_protected_member
    await tester.binding.handlePopRoute();
    await tester.pumpSmart();
  }

  Future<void> waitUntilWiredashIsClosed() async {
    await tester.pumpSmart();
    await tester.waitUntil(
      () => services.wiredashModel.isWiredashActive,
      isFalse,
    );
  }

  Future<void> ratePromoterScore(int rating) async {
    assert(rating >= 0 && rating <= 10);
    final step = _spotPageView.spot<PsStep1Rating>()..existsOnce();

    WidgetSelector<RatingCard> spotRatingCard(int rating) => step
        .spot<RatingCard>()
        .whereWidget(
          (widget) => widget.value == rating,
          description: 'RatingCard $rating',
        )
        .first();

    await act.tap(spotRatingCard(rating));
    await tester.pumpSmart();
    await tester.pumpSmart(const Duration(milliseconds: 600));
  }

  Future<void> submitPromoterScore() async {
    final step = _spotPageView.spot<PsStep2Message>()..existsOnce();
    final submitButton = step.spot<TronButton>(
      children: [spotText('l10n.promoterScoreSubmitButton')],
    ).last()
      ..existsOnce();
    final scrollable = spot<LarryPageView>()
        .spot<StepPageScaffold>()
        .spot<ScrollBox>()
        .spot<SingleChildScrollView>()
        .spot<Scrollable>()
        .first();
    await tester.scrollUntilVisible(
      submitButton.finder,
      -100,
      scrollable: scrollable.finder,
    );
    await act.tap(submitButton);
    await tester.pumpSmart();
    print('submit Promoter Score');
  }

  Future<void> showsPromoterScoreThanksMessage([Finder? finder]) async {
    final step = _spotPageView.spot<PsStep3Thanks>()..existsOnce();
    if (finder != null) {
      step.spotFinder(finder).existsOnce();
    }
  }

  WidgetSelector<Widget> get _discard =>
      _spotPageView.spotText('l10n.feedbackDiscardButton');

  WidgetSelector<Widget> get _reallyDiscard =>
      _spotPageView.spotText('l10n.feedbackDiscardConfirmButton');

  /// Starts discarding feedback, call [confirmDiscardFeedback] to confirm
  Future<void> discardFeedback() async {
    _discard.existsOnce();
    await act.tap(_discard);
    await tester.pumpSmart();
    _reallyDiscard.existsOnce();
  }

  /// Confirms [discardFeedback]
  Future<void> confirmDiscardFeedback() async {
    _discard.doesNotExist();
    _reallyDiscard.existsOnce();
    await act.tap(_reallyDiscard);
    await tester.pumpSmart();
  }

  Future<void> tapText(String text) {
    return act.tap(spotText(text));
  }
}

class PendingFeedbackSubmission {
  PendingFeedbackSubmission(this._sendFeedback);

  final Completer<void> _sendFeedback;

  void complete() {
    _sendFeedback.complete();
  }
}

class WiredashMockServices {
  final WiredashServices services;

  WiredashMockServices(this.services);

  MockWiredashApi get mockApi => services.api as MockWiredashApi;
}

WiredashServices createMockServices({
  bool useDirectFeedbackSubmitter = false,
  bool useDirectEventSubmitter = false,
}) {
  return WiredashServices.setup((services) {
    registerProdWiredashServices(services);

    // Don't do actual http calls
    services.inject<WiredashApi>(
      (_) {
        // depend on the widget (secret/project)
        services.wiredashWidget;
        return MockWiredashApi.fake();
      },
    );

    // Let the widget behave as in production
    services.inject<TestDetector>((_) => _OverlookFakeAsync());

    if (useDirectFeedbackSubmitter) {
      // replace submitter, because for testing we always want to submit directly
      services.inject<FeedbackSubmitter>(
        (_) => DirectFeedbackSubmitter(() => services.api),
      );
    } else {
      assert(
        services.feedbackSubmitter.runtimeType == RetryingFeedbackSubmitter,
      );
    }

    if (useDirectEventSubmitter) {
      services.inject<EventSubmitter>(
        (_) {
          print('create direct submitter');
          return DirectEventSubmitter(
            projectId: () => services.wiredashWidget!.projectId,
            eventStore: () => services.eventStore,
            api: () => services.api,
          );
        },
      );
    } else {
      assert(services.eventSubmitter.runtimeType == DebounceEventSubmitter);
    }
  });
}

/// Fake the test detector to not detect the fake async environment
///
/// Wiredash should behave differently in user tests. But wiredash tests should
/// be able schedule jobs in a fake async environment.
class _OverlookFakeAsync implements TestDetector {
  @override
  bool inFakeAsync() {
    return false;
  }
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

extension SpotWaitUntil<W extends Widget> on WidgetSelector<W> {
  Future<void> waitUntil(
    WidgetTester tester,
    void Function(WidgetSnapshot<W>) matcher, {
    Duration timeout = const Duration(seconds: 5),
  }) async {
    final ogStack = StackTrace.current;
    final start = DateTime.now();
    var attempt = 0;
    while (true) {
      attempt++;

      final snapshot = this.snapshot();

      final Object error;
      final StackTrace stack;
      try {
        matcher(snapshot);
        break;
      } catch (e, s) {
        error = e;
        stack = s;
      }

      final now = DateTime.now();
      final executingTime = start.difference(now).abs();
      if (now.isAfter(start.add(timeout))) {
        // Exit with error
        print(ogStack);
        print(stack);
        throw 'Did not find $this after $timeout (attempt: $attempt)';
      }

      final duration =
          Duration(milliseconds: math.pow(attempt, math.e).toInt());
      if (executingTime > const Duration(seconds: 1) &&
          duration > const Duration(seconds: 1)) {
        // show continuous updates
        print(
          'Waiting for match (attempt: $attempt, @ $executingTime)\n'
          '\tSelector: $this to match\n'
          '\tException: $error',
        );
      }

      await tester.pumpSmart();
    }
  }
}

extension EffectiveTextMatcher on WidgetMatcher<TronButton> {
  // ignore: avoid_positional_boolean_parameters
  WidgetMatcher<TronButton> isTappable(bool value) {
    return hasWidgetProp(
      prop: widgetProp('is clickable', (widget) => widget.onTap != null),
      match: (it) => it.equals(value),
    );
  }
}
