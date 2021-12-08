import 'dart:ui' as ui;

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/feedback/data/label.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
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
  email
}

class FeedbackModel with ChangeNotifier {
  FeedbackModel(WiredashState state) : _wiredashState = state;

  final WiredashState _wiredashState;
  FeedbackFlowStatus _feedbackFlowStatus = FeedbackFlowStatus.message;

  FeedbackFlowStatus get feedbackFlowStatus => _feedbackFlowStatus;

  PicassoController get picassoController => _wiredashState.picassoController;

  final BuildInfoManager buildInfoManager = BuildInfoManager();

  String? get feedbackMessage => _feedbackMessage;
  String? _feedbackMessage;

  ui.Image? _screenshot;

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

  List<FeedbackFlowStatus> get steps {
    final stack = [FeedbackFlowStatus.message];

    if (_feedbackMessage != null) {
      stack.add(FeedbackFlowStatus.labels);
      stack.add(FeedbackFlowStatus.screenshotsOverview);
      stack.add(FeedbackFlowStatus.email);
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
    print("nextStep $newStatus");
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
        picassoController.isActive = false;
        notifyListeners();

        await _wiredashState.backdropController.animateToCentered();
        break;
      case FeedbackFlowStatus.screenshotCapturing:
        _feedbackFlowStatus = newStatus;
        picassoController.isActive = false;
        notifyListeners();

        await _wiredashState.screenCaptureController.captureScreen();
        await goToStep(FeedbackFlowStatus.screenshotDrawing);
        break;
      case FeedbackFlowStatus.screenshotDrawing:
        _feedbackFlowStatus = newStatus;
        picassoController.isActive = true;
        notifyListeners();
        break;
      case FeedbackFlowStatus.screenshotSaving:
        _feedbackFlowStatus = newStatus;
        picassoController.isActive = false;
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
    }
  }

  Future<void> submitFeedback() async {
    // TODO remove before release
    bool fakeSubmit = true;
    // assert(
    //   () {
    //     fakeSubmit = false;
    //     return true;
    //   }(),
    // );
    if (fakeSubmit) {
      print("Submitting feedback (fake)");
      await _wiredashState.backdropController.animateToClosed();
      _wiredashState.discardFeedback();
      return;
    } else {
      print("Submitting feedback");
      try {
        final item = await createFeedback();
        await _wiredashState.feedbackSubmitter.submit(item, null);
      } catch (e) {
        // TODO show error UI
      }
    }
  }

  Future<PersistedFeedbackItem> createFeedback() async {
    final deviceId = await _wiredashState.deviceIdGenerator.deviceId();

    return PersistedFeedbackItem(
      deviceId: deviceId,
      appInfo: AppInfo(
        appLocale: _wiredashState.options.currentLocale.toLanguageTag(),
      ),
      // TODO add screenshot
      buildInfo: _wiredashState.buildInfoManager.buildInfo,
      deviceInfo: _wiredashState.deviceInfoGenerator.generate(),
      email: userEmail,
      // TODO collect message and labels
      message: _feedbackMessage!,
      type: 'bug',
      userId: 'test', // TODO use real user id
    );
  }
}
