import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:http/http.dart';
import 'package:wiredash/src/capture/capture_widget.dart';
import 'package:wiredash/src/common/network/api_client.dart';
import 'package:wiredash/src/common/utils/device_info.dart';
import 'package:wiredash/src/common/widgets/dismissible_page_route.dart';
import 'package:wiredash/src/feedback/feedback_sheet.dart';

class WiredashStateData with ChangeNotifier {
  WiredashStateData(
    GlobalKey<CaptureWidgetState> _captureKey,
    GlobalKey<NavigatorState> navigatorKey,
    String projectId,
    String projectSecret,
  ) {
    _apiClient = _apiClient = ApiClient(
      httpClient: Client(),
      projectId: projectId,
      secret: projectSecret,
    );
    _appCaptureKey = _captureKey;
    _appNavigatorKey = navigatorKey;

    DeviceInfo.getDeviceID().then((id) => deviceId = id);
  }

  ApiClient _apiClient;
  GlobalKey<NavigatorState> _appNavigatorKey;
  GlobalKey<CaptureWidgetState> _appCaptureKey;

  String appVersion;
  String deviceId;
  String userId;
  String userEmail;

  FeedbackType feedbackType = FeedbackType.bug;
  String feedbackMessage;
  Uint8List feedbackScreenshot;

  FeedbackState _feedbackState = FeedbackState.hidden;
  FeedbackState _prevFeedbackState = FeedbackState.hidden;

  FeedbackState get feedbackState => _feedbackState;
  FeedbackState get previousUiState => _prevFeedbackState;
  set feedbackState(FeedbackState newValue) {
    if (_feedbackState == newValue) return;
    _prevFeedbackState = _feedbackState;
    _feedbackState = newValue;
    _triggerStateChangeActions();
    notifyListeners();
  }

  bool _loading = false;
  bool get loading => _loading;

  void _triggerStateChangeActions() {
    switch (_feedbackState) {
      case FeedbackState.intro:
        _clearFeedback();
        break;
      case FeedbackState.capture:
        _appCaptureKey.currentState.show();
        break;
      case FeedbackState.feedback:
        if (previousUiState != FeedbackState.capture) return;
        _appNavigatorKey.currentState.push(
          DismissiblePageRoute(
            builder: (context) => FeedbackSheet(),
            background: feedbackScreenshot,
          ),
        );
        break;
      case FeedbackState.success:
        _sendFeedback();
        break;
      default:
      // do nothing
    }
  }

  void _clearFeedback() {
    feedbackMessage = null;
    feedbackScreenshot = null;
  }

  void _sendFeedback() {
    _apiClient.sendFeedback(
      deviceInfo: DeviceInfo.generate(appVersion, deviceId),
      email: userEmail,
      message: feedbackMessage,
      picture: feedbackScreenshot,
      type: feedbackType.label,
      user: userId,
      onDataStateChanged: (state) {
        if (_loading != state.isLoading) {
          _loading = state.isLoading;
          notifyListeners();
        }
      },
    );

    _clearFeedback();
  }

  void show() {
    if (feedbackState == FeedbackState.capture) return;
    feedbackState = FeedbackState.intro;
    _appNavigatorKey.currentState
        .push(DismissiblePageRoute(builder: (context) => FeedbackSheet()));
  }
}

enum FeedbackType { bug, improvement, praise }

extension FeedbackTypeMembers on FeedbackType {
  String get label => const {
        FeedbackType.bug: "bug",
        FeedbackType.improvement: "improvement",
        FeedbackType.praise: "praise",
      }[this];
}

enum FeedbackState { hidden, intro, capture, feedback, email, success }
