import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/feedback/data/delay.dart';
import 'package:wiredash/src/metadata/build_info/app_info.dart';
import 'package:wiredash/src/metadata/build_info/build_info.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';
import 'package:wiredash/src/metadata/renderer/renderer.dart';
import 'package:wiredash/src/utils/changenotifier2.dart';
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

  bool _collectedMetadata = false;

  List<Label> get selectedLabels => List.unmodifiable(_selectedLabels);
  List<Label> _selectedLabels = [];

  List<Label> get labels =>
      _services.wiredashWidget.feedbackOptions?.labels ?? [];

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

  late FlutterDeviceInfo _deviceInfo;

  /// The error when submitting the feedback
  Object? get submissionError => _submissionError;
  Object? _submissionError;

  int get maxSteps {
    // message
    // screenshot
    var steps = 2;

    if (_services.wiredashWidget.feedbackOptions?.askForUserEmail == true) {
      steps++;
    }
    if (_services.wiredashWidget.feedbackOptions?.labels?.isNotEmpty == true) {
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

    if (labels.isNotEmpty) stack.add(FeedbackFlowStatus.labels);
    final renderer = getRenderer();
    if (_services.wiredashWidget.feedbackOptions?.screenshotStep != false &&
        renderer != Renderer.html) {
      // Don't show the screenshot option with html renderer, because it
      // doesn't support rendering to canvas
      stack.add(FeedbackFlowStatus.screenshotsOverview);
    }
    if (_services.wiredashWidget.feedbackOptions?.askForUserEmail == true) {
      stack.add(FeedbackFlowStatus.email);
    }
    stack.add(FeedbackFlowStatus.submit);

    if (submitting || feedbackProcessed || submissionError != null) {
      stack.add(FeedbackFlowStatus.submittingAndRetry);
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

  /// Goes to the previous step in [steps]
  void goToPreviousStep() {
    final index = currentStepIndex;
    if (index == null) {
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
      final bg = _services.wiredashWidget.theme?.appBackgroundColor ??
          const Color(0xffcccccc);
      final screenshot =
          await _services.picassoController.paintDrawingOntoImage(image, bg);
      final attachment = PersistedAttachment.screenshot(
        file: FileDataEventuallyOnDisk.inMemory(screenshot),
        deviceInfo: _deviceInfo,
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
    _deviceInfo = _services.deviceInfoGenerator.generate();
    final metaData = _services.wiredashModel.metaData;
    // Allow devs to collect additional information
    await _services.wiredashWidget.feedbackOptions?.collectMetaData
        ?.call(metaData);
    _services.wiredashModel.metaData = metaData;
    _collectedMetadata = true;
    notifyListeners();

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
          reportWiredashError(e, stack, 'Feedback submission failed');
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

  Future<PersistedFeedbackItem> createFeedback() async {
    final deviceId = await _services.deviceIdGenerator.deviceId();
    _deviceInfo = _services.deviceInfoGenerator.generate();

    CustomizableWiredashMetaData metaData = _services.wiredashModel.metaData;
    if (_collectedMetadata) {
      // Allow devs to collect additional information
      final updated = await _services
          .wiredashWidget.feedbackOptions?.collectMetaData
          ?.call(metaData);
      if (updated != null) {
        metaData = updated;
        _services.wiredashModel.metaData = metaData;
        notifyListeners();
      }
    }

    return PersistedFeedbackItem(
      appInfo: AppInfo(
        appLocale:
            _services.wiredashModel.appLocale?.toLanguageTag() ?? 'unknown',
      ),
      attachments: _attachments,
      buildInfo: buildInfo.copyWith(
        buildCommit: metaData.buildCommit,
        buildNumber: metaData.buildNumber,
        buildVersion: metaData.buildVersion,
      ),
      customMetaData: metaData.custom,
      deviceId: deviceId,
      deviceInfo: _deviceInfo,
      email: () {
        if (_services.wiredashWidget.feedbackOptions?.askForUserEmail == true &&
            userEmail == null) {
          // user has explicitly deleted their email address
          return null;
        }
        return userEmail;
      }(),
      message: _feedbackMessage!,
      labels: _selectedLabels.map((it) => it.id).toList(),
      userId: metaData.userId,
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
