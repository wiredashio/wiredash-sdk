import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/metadata/renderer/renderer.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
import 'package:wiredash/src/utils/delay.dart';
import 'package:wiredash/src/utils/email_validator.dart';
import 'package:wiredash/wiredash.dart';

enum FeedbackFlowStatus {
  none,
  message,
  labels,
  screenshotsOverview,
  screenshotNavigating,
  screenshotCapturing,
  screenshotDrawing,
  screenshotSaving,
  email,
  submit,
  submittingAndRetry,
}

class FeedbackModel extends ChangeNotifier2 {
  FeedbackModel(WiredashServices services) : _services = services;

  final WiredashServices _services;
  FeedbackFlowStatus _feedbackFlowStatus = FeedbackFlowStatus.message;

  FeedbackFlowStatus get feedbackFlowStatus => _feedbackFlowStatus;

  final GlobalKey<FormState> stepFormKey = GlobalKey<FormState>();

  String? get feedbackMessage => _feedbackMessage;
  String? _feedbackMessage;

  final List<PersistedAttachment> _attachments = [];

  String? get userEmail => _userEmail;
  String? _userEmail;

  bool _hasEmailBeenEdited = false;

  bool get hasEmailBeenEdited => _hasEmailBeenEdited;

  /// Captured when taking a screenshot
  ///
  /// Capturing the metadata at the time the screenshot is taken is beneficial
  /// to the point when the feedback is submitted because users still have full
  /// control about the app and can sign out or change the language, etc. which
  /// might be conflicting with what's seen on the screenshot.
  CustomizableWiredashMetaData? _customizableMetadata;

  List<Label> get selectedLabels => List.unmodifiable(_selectedLabels);
  List<Label> _selectedLabels = [];

  List<Label> get labels =>
      _services.wiredashModel.feedbackOptions?.labels ?? [];

  List<PersistedAttachment> get attachments =>
      _attachments.toList(growable: false);

  set selectedLabels(List<Label> list) {
    _selectedLabels = list;
    notifyListeners();
  }

  bool get isActive => _feedbackFlowStatus != FeedbackFlowStatus.none;

  bool get hasAttachments => _attachments.isNotEmpty;

  bool get submitting => _submitting;
  bool _submitting = false;

  /// When true the feedback is either submitted (on server) or pending
  /// (on disk) waiting for the next opportunity to be submitted (offline case)
  ///
  /// In both cases, nothing the user can do
  bool get feedbackProcessed => _feedbackProcessed;
  bool _feedbackProcessed = false;

  Delay? _fakeSubmitDelay;
  Delay? _closeDelay;

  /// The error when submitting the feedback
  Object? get submissionError => _submissionError;
  Object? _submissionError;

  EmailValidator get _emailValidator => const EmailValidator();

  int get maxSteps {
    // message
    // screenshot
    var steps = 2;

    final emailPrompt = _services.wiredashModel.feedbackOptions?.email;
    if (emailPrompt == null ||
        emailPrompt == EmailPrompt.optional ||
        emailPrompt == EmailPrompt.mandatory) {
      steps++;
    }
    if (_services.wiredashModel.feedbackOptions?.labels?.isNotEmpty == true) {
      steps++;
    }

    return steps;
  }

  /// Returns the current stack of steps
  List<FeedbackFlowStatus> get steps {
    if (feedbackProcessed) {
      // Return just a single step, no back/forward possible
      return [
        FeedbackFlowStatus.submittingAndRetry,
      ];
    }

    if (_feedbackMessage == null) {
      return [FeedbackFlowStatus.message];
    }

    return _completeStack;
  }

  /// The list of steps a user has to go through to submit feedback
  List<FeedbackFlowStatus> get _completeStack {
    final List<FeedbackFlowStatus> stack = [];

    // message is always there
    stack.add(FeedbackFlowStatus.message);

    if (labels.where((it) => it.hidden != true).isNotEmpty) {
      stack.add(FeedbackFlowStatus.labels);
    }
    final renderer = getRenderer();
    if (_services.wiredashModel.feedbackOptions?.screenshot == null ||
        _services.wiredashModel.feedbackOptions?.screenshot ==
                ScreenshotPrompt.optional &&
            renderer != Renderer.html) {
      // Don't show the screenshot option with html renderer, because it
      // doesn't support rendering to canvas
      stack.add(FeedbackFlowStatus.screenshotsOverview);
    }
    final emailPrompt = _services.wiredashModel.feedbackOptions?.email;
    if (emailPrompt == null ||
        emailPrompt == EmailPrompt.optional ||
        emailPrompt == EmailPrompt.mandatory) {
      stack.add(FeedbackFlowStatus.email);
    }

    if (emailPrompt != EmailPrompt.mandatory ||
        (emailPrompt == EmailPrompt.mandatory &&
            _emailValidator.validate(userEmail ?? ''))) {
      stack.add(FeedbackFlowStatus.submit);

      if (submitting || feedbackProcessed || submissionError != null) {
        stack.add(FeedbackFlowStatus.submittingAndRetry);
      }
    }
    return stack;
  }

  int indexForFlowStatus(FeedbackFlowStatus flowStatus) {
    FeedbackFlowStatus statusInStack = flowStatus;
    if (flowStatus == FeedbackFlowStatus.screenshotDrawing ||
        flowStatus == FeedbackFlowStatus.screenshotNavigating ||
        flowStatus == FeedbackFlowStatus.screenshotCapturing) {
      // these states are not actually in the page stack LarryPageView shows
      // The index is still the same as the overview
      statusInStack = FeedbackFlowStatus.screenshotsOverview;
    }

    final index = _completeStack.indexOf(statusInStack);
    if (index == -1) {
      throw StateError('Could not find $statusInStack in stack)');
    }
    return index;
  }

  set feedbackMessage(String? feedbackMessage) {
    final trimmed = feedbackMessage?.trim();
    if (trimmed == '') {
      _feedbackMessage = null;
    } else {
      _feedbackMessage = trimmed;
    }
    notifyListeners();
  }

  set userEmail(String? userEmail) {
    final trimmed = userEmail?.trim();
    if (trimmed == '') {
      _userEmail = null;
    } else {
      _userEmail = trimmed;
    }
    _hasEmailBeenEdited = true;
    notifyListeners();
  }

  int? get currentStepIndex {
    final state = feedbackFlowStatus;
    final index = steps.indexOf(state);
    if (index == -1) {
      return null;
    }
    return index;
  }

  void goToNextStep() {
    if (!validateForm()) {
      throw FormValidationException();
    }
    final index = currentStepIndex;
    if (index == null) {
      throw StateError('Unknown step index');
    }
    final nextStepIndex = index + 1;
    if (nextStepIndex < steps.length) {
      final step = steps[nextStepIndex];
      _goToStep(step);
    } else {
      throw StateError('reached the end of the stack (length ${steps.length})');
    }
  }

  Future<void> skipScreenshot() async {
    if (_customizableMetadata == null) {
      await _collectCustomizableMetaData();
    }
    goToNextStep();
  }

  /// Goes to the previous step in [steps]
  void goToPreviousStep() {
    final index = currentStepIndex;
    if (index == null) {
      if (!steps.contains(feedbackFlowStatus)) {
        debugPrint('Warning: $feedbackFlowStatus is not in steps');
      }
      throw StateError('Unknown step index');
    }
    final prevStepIndex = index - 1;
    if (prevStepIndex >= 0) {
      final step = steps[prevStepIndex];
      _goToStep(step);
    } else {
      throw StateError('Already at first item');
    }
  }

  /// Enters the screenshot mode, executes the following steps:
  /// - [FeedbackFlowStatus.screenshotNavigating]
  /// - [FeedbackFlowStatus.screenshotCapturing]
  /// - [FeedbackFlowStatus.screenshotDrawing]
  /// - [FeedbackFlowStatus.screenshotSaving]
  Future<void> enterScreenshotCapturingMode() async {
    _goToStep(FeedbackFlowStatus.screenshotNavigating);
    _services.picassoController.isActive = false;
    _services.picassoController.clear();
    notifyListeners();

    await _services.backdropController.animateToCentered();
  }

  /// Combines the drawing and the screenshot into a single masterpiece
  Future<void> createMasterpiece() async {
    _goToStep(FeedbackFlowStatus.screenshotSaving);
    _services.picassoController.isActive = false;
    notifyListeners();

    final image = _services.screenCaptureController.screenshot;
    if (image != null) {
      final bg = _services.wiredashWidget?.theme?.appBackgroundColor ??
          const Color(0xffcccccc);
      final screenshot =
          await _services.picassoController.paintDrawingOntoImage(image, bg);
      final attachment = PersistedAttachment.screenshot(
        file: FileDataEventuallyOnDisk.inMemory(screenshot),
      );
      _attachments.add(attachment);
      notifyListeners();

      // give Flutter a few ms for GC before starting the closing animation
      await Future.delayed(const Duration(milliseconds: 100));
    }
    await _services.backdropController.animateToOpen();
    _services.screenCaptureController.releaseScreen();

    _goToStep(FeedbackFlowStatus.screenshotsOverview);
  }

  /// Removes the attachment
  void deleteAttachment(PersistedAttachment attachment) {
    _attachments.remove(attachment);
    notifyListeners();
  }

  /// Allow devs to collect additional information
  Future<CustomizableWiredashMetaData> _collectCustomizableMetaData() async {
    final fallbackCollector = _services
        .wiredashModel.feedbackOptions?.collectMetaData
        ?.map((it) => it.asFuture());
    _customizableMetadata =
        await _services.wiredashModel.collectSessionMetaData(fallbackCollector);
    notifyListeners();
    return _customizableMetadata!;
  }

  /// Captures the pixels of the app and the app metadata
  ///
  /// Call [createMasterpiece] to finalize the screenshot (with drawing)
  Future<void> captureScreenshot() async {
    _goToStep(FeedbackFlowStatus.screenshotCapturing);
    _services.picassoController.isActive = false;
    notifyListeners();

    // captures screenshot, it is saved in screenCaptureController
    await _services.screenCaptureController.captureScreen();
    // TODO show loading indicator?
    await _collectCustomizableMetaData();

    _services.picassoController.isActive = true;
    _goToStep(FeedbackFlowStatus.screenshotDrawing);
  }

  Future<void> cancelScreenshotCapturingMode() async {
    _goToStep(FeedbackFlowStatus.screenshotsOverview);

    _services.screenCaptureController.releaseScreen();
    await _services.backdropController.animateToOpen();
  }

  /// Debugging happens often here, this is a good point to start logging
  /// because it triggers all status changes
  void _goToStep(FeedbackFlowStatus newStatus) {
    _feedbackFlowStatus = newStatus;
    notifyListeners();
  }

  Future<void> submitFeedback() async {
    _submitting = true;
    _submissionError = null;
    notifyListeners();
    _goToStep(FeedbackFlowStatus.submittingAndRetry);
    bool fakeSubmit = false;
    assert(
      () {
        fakeSubmit = false;
        return true;
      }(),
    );
    try {
      if (fakeSubmit) {
        // ignore: avoid_print
        if (kDebugMode) print('Submitting feedback (fake)');
        _fakeSubmitDelay?.dispose();
        _fakeSubmitDelay = Delay(const Duration(seconds: 2));
        await _fakeSubmitDelay!.future;
        _feedbackProcessed = true;
        _submitting = false;
        notifyListeners();
      } else {
        // ignore: avoid_print
        if (kDebugMode) print('Submitting feedback');
        try {
          final item = await createFeedback();
          final submission = await _services.feedbackSubmitter.submit(item);
          if (submission == SubmissionState.pending) {
            if (kDebugMode) print("Feedback is pending");
          }
          unawaited(_services.syncEngine.onSubmitFeedback());
          _feedbackProcessed = true;
          notifyListeners();
        } catch (e, stack) {
          reportWiredashInfo(e, stack, 'Feedback submission failed');
          _submissionError = e;
        }
      }
    } finally {
      _submitting = false;
      notifyListeners();
    }

    if (_feedbackProcessed) {
      _closeDelay?.dispose();
      _closeDelay = Delay(const Duration(seconds: 1));
      await _closeDelay!.future;
      await returnToAppPostSubmit();
    }
  }

  Future<void> returnToAppPostSubmit() async {
    if (feedbackProcessed == false) return;
    await _services.wiredashModel.hide(discardFeedback: true);
  }

  Future<FeedbackItem> createFeedback() async {
    final deviceId = await _services.wuidGenerator.submitId();

    final fixedMetadata =
        await _services.metaDataCollector.collectFixedMetaData();
    final customizableMetadata =
        _customizableMetadata ?? await _collectCustomizableMetaData();
    final SessionMetaData? sessionMetadata =
        _services.wiredashModel.sessionMetaData;
    final flutterInfo = _services.metaDataCollector.collectFlutterInfo();

    final email = () {
      if (_services.wiredashModel.feedbackOptions?.email ==
              EmailPrompt.mandatory &&
          userEmail != null) {
        // user has explicitly deleted their email address
        return userEmail;
      }
      if (_services.wiredashModel.feedbackOptions?.email ==
              EmailPrompt.optional &&
          userEmail == null) {
        // user has explicitly deleted their email address
        return null;
      }
      return userEmail;
    }();
    return FeedbackItem(
      feedbackId: _services.wuidGenerator.localFeedbackId(),
      attachments: _attachments,
      labels: [..._selectedLabels, ...labels.where((it) => it.hidden == true)]
          .map((it) => it.id)
          .toList(),
      message: _feedbackMessage!,
      metadata: AllMetaData.from(
        customizableMetadata: customizableMetadata,
        sessionMetadata: sessionMetadata,
        fixedMetadata: fixedMetadata,
        flutterInfo: flutterInfo,
        installId: deviceId,
        email: email,
      ),
    );
  }

  @override
  void dispose() {
    _fakeSubmitDelay?.dispose();
    _closeDelay?.dispose();
    super.dispose();
  }

  @override
  void removeListener(VoidCallback listener) {
    try {
      super.removeListener(listener);
      // ignore: avoid_catching_errors
    } on FlutterError {
      // ignore when it is already disposed due to recreation
    }
  }

  /// Returns `true` when there are no errors
  bool validateForm() {
    final state = stepFormKey.currentState;
    if (state == null) {
      return true;
    }
    return state.validate();
  }
}

class FormValidationException implements Exception {}
