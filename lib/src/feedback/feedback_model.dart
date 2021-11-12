import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/wiredash_widget.dart';

enum FeedbackScreenshotStatus {
  none,
  navigating,
  screenshotting,
  drawing,
}

class FeedbackModel with ChangeNotifier {
  FeedbackModel(WiredashState state) : _wiredashState = state;

  final WiredashState _wiredashState;
  FeedbackScreenshotStatus _screenshotStatus = FeedbackScreenshotStatus.none;
  FeedbackScreenshotStatus get screenshotStatus => _screenshotStatus;

  final BuildInfoManager buildInfoManager = BuildInfoManager();

  // ignore: unused_field
  final List<Uint8List> _screenshots = [];

  String? get feedbackMessage => _feedbackMessage;
  String? _feedbackMessage;

  String? get userEmail => _userEmail;
  String? _userEmail;

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

  Future<void> enterCaptureMode() async {
    _screenshotStatus = FeedbackScreenshotStatus.navigating;
    notifyListeners();

    await _wiredashState.backdropController.animateToCentered();

    // TODO Show dialog help screenshot
  }

  Future<void> takeScreenshot() async {
    _screenshotStatus = FeedbackScreenshotStatus.screenshotting;
    notifyListeners();

    // TODO GRAB SCREENSHOT

    _screenshotStatus = FeedbackScreenshotStatus.drawing;
    notifyListeners();

    // TODO Show dialog help drawing
  }

  Future<void> saveScreenshot() async {
    // TODO merge screenshot & drawing

    _screenshotStatus = FeedbackScreenshotStatus.none;
    // _screenshots.add(value);
    notifyListeners();
  }

  Future<void> submitFeedback() async {
    // during development
    // TODO remove afterwards

    _feedbackMessage = null;
    _userEmail = null;
    // await hide();
    // return;

    final deviceId = await _wiredashState.deviceIdGenerator.deviceId();

    final item = PersistedFeedbackItem(
      deviceId: deviceId,
      appInfo: AppInfo(
        appLocale: _wiredashState.options.currentLocale.toLanguageTag(),
      ),
      buildInfo: _wiredashState.buildInfoManager.buildInfo,
      deviceInfo: _wiredashState.deviceInfoGenerator.generate(),
      email: userEmail,
      // TODO collect message and labels
      message: _feedbackMessage!,
      type: 'bug',
      userId: 'test', // TODO use real user id
    );

    try {
      // TODO add screenshot
      await _wiredashState.feedbackSubmitter.submit(item, null);
    } catch (e) {
      // TODO show error UI
    }
  }
}
