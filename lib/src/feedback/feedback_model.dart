import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/build_info/build_info_manager.dart';
import 'package:wiredash/src/common/utils/delay.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/services.dart';
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
  submitting
}

class FeedbackModel with ChangeNotifier {
  FeedbackModel(WiredashServices services) : _services = services;

  final WiredashServices _services;
  FeedbackFlowStatus _feedbackFlowStatus = FeedbackFlowStatus.message;

  FeedbackFlowStatus get feedbackFlowStatus => _feedbackFlowStatus;

  final BuildInfoManager buildInfoManager = BuildInfoManager();

  String? get feedbackMessage => _feedbackMessage;
  String? _feedbackMessage;

  Uint8List? _screenshot;

  String? get userEmail => _userEmail ?? _metaData?.userEmail;
  String? _userEmail;

  List<Label> get selectedLabels => List.unmodifiable(_selectedLabels);
  List<Label> _selectedLabels = [];

  List<Label> get labels =>
      _services.wiredashWidget.feedbackOptions?.labels ?? [];

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

  CustomizableWiredashMetaData? _metaData;
  DeviceInfo? _deviceInfo;
  BuildInfo? _buildInfo;

  List<FeedbackFlowStatus> get steps {
    if (submitted) {
      return [FeedbackFlowStatus.submitting];
    }

    final stack = [FeedbackFlowStatus.message];

    if (_feedbackMessage != null) {
      if (labels.isNotEmpty) stack.add(FeedbackFlowStatus.labels);
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

  int? get currentStepIndex {
    final state = feedbackFlowStatus;
    final index = steps.indexOf(state);
    if (index == -1) {
      return null;
    }
    return index;
  }

  Future<void> goToNextStep() async {
    final index = currentStepIndex;
    if (index == null) {
      throw StateError('Unknown step index');
    }
    final nextStepIndex = index + 1;
    if (nextStepIndex <= steps.length) {
      final step = steps[nextStepIndex];
      await goToStep(step);
    } else {
      throw StateError('reached the end of the stack (length ${steps.length})');
    }
  }

  Future<void> goToPreviousStep() async {
    final index = currentStepIndex;
    if (index == null) {
      throw StateError('Unknown step index');
    }
    final prevStepIndex = index - 1;
    if (prevStepIndex > 0) {
      final step = steps[prevStepIndex];
      await goToStep(step);
    } else {
      throw StateError('Already at first item');
    }
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

        await _services.backdropController.animateToOpen();
        break;
      case FeedbackFlowStatus.screenshotNavigating:
        _feedbackFlowStatus = newStatus;
        _services.picassoController.isActive = false;
        notifyListeners();

        await _services.backdropController.animateToCentered();
        break;
      case FeedbackFlowStatus.screenshotCapturing:
        _feedbackFlowStatus = newStatus;
        _services.picassoController.isActive = false;
        notifyListeners();

        await _services.screenCaptureController.captureScreen();
        // TODO show loading indicator?
        _deviceInfo = _services.deviceInfoGenerator.generate();
        final metaData = _services.wiredashModel.metaData;
        // Allow devs to collect additional information
        await _services.wiredashWidget.feedbackOptions?.collectMetaData
            ?.call(metaData);
        _buildInfo = _services.buildInfoManager.buildInfo;
        _metaData = metaData;
        notifyListeners();

        await goToStep(FeedbackFlowStatus.screenshotDrawing);
        break;
      case FeedbackFlowStatus.screenshotDrawing:
        _feedbackFlowStatus = newStatus;
        _services.picassoController.isActive = true;
        notifyListeners();
        break;
      case FeedbackFlowStatus.screenshotSaving:
        _feedbackFlowStatus = newStatus;
        _services.picassoController.isActive = false;
        notifyListeners();

        _screenshot = await _services.picassoController.paintDrawingOntoImage(
          _services.screenCaptureController.screenshot!,
        );
        notifyListeners();

        await _services.backdropController.animateToOpen();
        _services.screenCaptureController.releaseScreen();

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
            await _services.feedbackSubmitter.submit(item, _screenshot);
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
    await _services.backdropController.animateToClosed();
    _services.discardFeedback();
  }

  Future<PersistedFeedbackItem> createFeedback() async {
    final deviceId = await _services.deviceIdGenerator.deviceId();
    _buildInfo ??= _services.buildInfoManager.buildInfo;
    _deviceInfo ??= _services.deviceInfoGenerator.generate();

    if (_metaData == null) {
      final metaData = _services.wiredashModel.metaData;
      // Allow devs to collect additional information
      await _services.wiredashWidget.feedbackOptions?.collectMetaData
          ?.call(metaData);
      _metaData = metaData;
    }

    return PersistedFeedbackItem(
      deviceId: deviceId,
      appInfo: AppInfo(
        appLocale: _services.wiredashOptions.currentLocale.toLanguageTag(),
      ),
      buildInfo: _buildInfo!.copyWith(
        buildCommit: _metaData?.buildCommit,
        buildNumber: _metaData?.buildNumber,
        buildVersion: _metaData?.buildVersion,
      ),
      deviceInfo: _deviceInfo!,
      email: userEmail,
      message: _feedbackMessage!,
      labels: _selectedLabels.map((it) => it.id).toList(),
      customMetaData: _metaData?.custom,
      userId: _metaData?.userId,
    );
  }

  @override
  void dispose() {
    _submitDelay?.dispose();
    _closeDelay?.dispose();
    super.dispose();
  }
}
