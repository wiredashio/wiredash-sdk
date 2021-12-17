import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/utils/delay.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/wiredash_widget.dart';

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
  submitting
}

class FeedbackModel with ChangeNotifier {
  FeedbackModel(WiredashState state) : _wiredashState = state;

  final WiredashState _wiredashState;
  FeedbackFlowStatus _feedbackFlowStatus = FeedbackFlowStatus.message;

  FeedbackFlowStatus get feedbackFlowStatus => _feedbackFlowStatus;

  final BuildInfoManager buildInfoManager = BuildInfoManager();

  String? get feedbackMessage => _feedbackMessage;
  String? _feedbackMessage;

  Uint8List? _screenshot;

  String? get userEmail => _userEmail;
  String? _userEmail;

  List<Label> get selectedLabels => List.unmodifiable(_selectedLabels);
  List<Label> _selectedLabels = [];

  set selectedLabels(List<Label> list) {
    _selectedLabels = list;
    notifyListeners();
  }

  bool get isActive => _feedbackFlowStatus != FeedbackFlowStatus.none;

  bool get hasScreenshots => _screenshot != null;
  Uint8List? get screenshot => _screenshot;

  bool get submitting => _submitting;
  bool _submitting = false;

  bool get submitted => _submitted;
  bool _submitted = false;

  Delay? _submitDelay;
  Delay? _closeDelay;

  List<FeedbackFlowStatus> get steps {
    if (submitted) {
      return [FeedbackFlowStatus.submitting];
    }

    final stack = [FeedbackFlowStatus.message];

    if (_feedbackMessage != null) {
      stack.add(FeedbackFlowStatus.labels);
      stack.add(FeedbackFlowStatus.screenshotsOverview);
      stack.add(FeedbackFlowStatus.email);
    }
    if (submitting || submitted) {
      stack.add(FeedbackFlowStatus.submitting);
    }
    return stack;
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

  Future<void> goToStep(FeedbackFlowStatus newStatus) async {
    switch (newStatus) {
      case FeedbackFlowStatus.none:
        _feedbackFlowStatus = newStatus;
        notifyListeners();
        break;
      case FeedbackFlowStatus.message:
        _feedbackFlowStatus = newStatus;
        notifyListeners();
        break;
      case FeedbackFlowStatus.labels:
        _feedbackFlowStatus = newStatus;
        notifyListeners();
        break;
      case FeedbackFlowStatus.screenshotsOverview:
        _feedbackFlowStatus = newStatus;
        notifyListeners();

        await _wiredashState.backdropController.animateToOpen();
        break;
      case FeedbackFlowStatus.screenshotNavigating:
        _feedbackFlowStatus = newStatus;
        _wiredashState.picassoController.isActive = false;
        notifyListeners();

        await _wiredashState.backdropController.animateToCentered();
        break;
      case FeedbackFlowStatus.screenshotCapturing:
        _feedbackFlowStatus = newStatus;
        _wiredashState.picassoController.isActive = false;
        notifyListeners();

        await _wiredashState.screenCaptureController.captureScreen();
        await goToStep(FeedbackFlowStatus.screenshotDrawing);
        break;
      case FeedbackFlowStatus.screenshotDrawing:
        _feedbackFlowStatus = newStatus;
        _wiredashState.picassoController.isActive = true;
        notifyListeners();
        break;
      case FeedbackFlowStatus.screenshotSaving:
        _feedbackFlowStatus = newStatus;
        _wiredashState.picassoController.isActive = false;
        notifyListeners();

        _screenshot =
            await _wiredashState.picassoController.paintDrawingOntoImage(
          _wiredashState.screenCaptureController.screenshot!,
        );
        notifyListeners();

        await _wiredashState.backdropController.animateToOpen();
        _wiredashState.screenCaptureController.releaseScreen();

        await goToStep(FeedbackFlowStatus.screenshotsOverview);
        break;
      case FeedbackFlowStatus.email:
        _feedbackFlowStatus = newStatus;
        notifyListeners();
        break;
      case FeedbackFlowStatus.submitting:
        _feedbackFlowStatus = newStatus;
        notifyListeners();
        break;
    }
  }

  Future<void> submitFeedback() async {
    _submitting = true;
    notifyListeners();
    goToStep(FeedbackFlowStatus.submitting);
    bool fakeSubmit = false;
    assert(
      () {
        fakeSubmit = false;
        return true;
      }(),
    );
    try {
      _submitDelay?.dispose();
      _submitDelay = Delay(const Duration(seconds: 2));
      if (fakeSubmit) {
        // ignore: avoid_print
        if (kDebugMode) print('Submitting feedback (fake)');
        await _submitDelay!.future;
        _submitted = true;
        _submitting = false;
        notifyListeners();
      } else {
        // ignore: avoid_print
        if (kDebugMode) print('Submitting feedback');
        try {
          final Future<void> feedback = () async {
            final item = await createFeedback();
            await _wiredashState.feedbackSubmitter.submit(item, _screenshot);
          }();
          await Future.wait([feedback, _submitDelay!.future]);
          _submitted = true;
          notifyListeners();
        } catch (e) {
          // TODO show error UI
          rethrow;
        }
      }
    } finally {
      _submitting = false;
      notifyListeners();
    }
    _closeDelay?.dispose();
    _closeDelay = Delay(const Duration(seconds: 1));
    await _closeDelay!.future;
    await returnToAppPostSubmit();
  }

  Future<void> returnToAppPostSubmit() async {
    if (submitted == false) return;
    await _wiredashState.backdropController.animateToClosed();
    _wiredashState.discardFeedback();
  }

  Future<PersistedFeedbackItem> createFeedback() async {
    final deviceId = await _wiredashState.deviceIdGenerator.deviceId();

    return PersistedFeedbackItem(
      deviceId: deviceId,
      appInfo: AppInfo(
        appLocale: _wiredashState.options.currentLocale.toLanguageTag(),
      ),
      buildInfo: _wiredashState.buildInfoManager.buildInfo,
      deviceInfo: _wiredashState.deviceInfoGenerator.generate(),
      email: userEmail,
      message: _feedbackMessage!,
      // TODO collect labels
      type: 'bug',
      // TODO use real user id
      userId: 'test',
    );
  }

  @override
  void dispose() {
    _submitDelay?.dispose();
    _closeDelay?.dispose();
    super.dispose();
  }
}
