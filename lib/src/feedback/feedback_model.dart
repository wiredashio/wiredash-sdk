import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/network/network_manager.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/widgets/dismissible_page_route.dart';

import 'feedback_sheet.dart';

class FeedbackModel with ChangeNotifier {
  FeedbackModel(this._captureKey, this._navigatorKey, this._networkManager,
      this._userManager);

  final GlobalKey<CaptureState> _captureKey;
  final GlobalKey<NavigatorState> _navigatorKey;
  final NetworkManager _networkManager;
  final UserManager _userManager;

  FeedbackType feedbackType = FeedbackType.bug;
  String feedbackMessage;
  Uint8List screenshot;

  FeedbackUiState _feedbackUiState = FeedbackUiState.hidden;
  FeedbackUiState get feedbackUiState => _feedbackUiState;
  set feedbackUiState(FeedbackUiState newValue) {
    if (_feedbackUiState == newValue) return;
    _feedbackUiState = newValue;
    _handleUiChange();
    notifyListeners();
  }

  bool _error = false;
  bool get error => _error;
  set error(bool newValue) {
    if (_error == newValue) return;
    _error = newValue;
    notifyListeners();
  }

  bool _loading = false;
  set loading(bool newValue) {
    if (_loading == newValue) return;
    _loading = newValue;
    notifyListeners();
  }

  bool get loading => _loading;

  void _handleUiChange() {
    switch (_feedbackUiState) {
      case FeedbackUiState.intro:
        _clearFeedback();
        break;
      case FeedbackUiState.capture:
        _captureKey.currentState.show().then((image) {
          screenshot = image;
          _feedbackUiState = FeedbackUiState.feedback;
          _navigatorKey.currentState.push(
            DismissiblePageRoute(
              builder: (context) => FeedbackSheet(),
              background: image,
            ),
          );
        });
        break;
      case FeedbackUiState.success:
        _sendFeedback();
        break;
      default:
      // do nothing
    }
  }

  void _clearFeedback() {
    feedbackMessage = null;
  }

  void _sendFeedback() {
    error = false;
    loading = true;

    _networkManager
        .sendFeedback(
      deviceInfo: _userManager.deviceInfo,
      email: _userManager.userEmail,
      message: feedbackMessage,
      picture: screenshot,
      type: feedbackType.label,
      user: _userManager.userId,
    )
        .catchError((_) {
      error = true;
    }).then((value) {
      _clearFeedback();
    }).whenComplete(() {
      loading = false;
    });
  }

  void show() {
    if (feedbackUiState == FeedbackUiState.capture) return;
    feedbackUiState = FeedbackUiState.intro;
    _navigatorKey.currentState
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

enum FeedbackUiState { hidden, intro, capture, feedback, email, success }
