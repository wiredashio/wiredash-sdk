import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture.dart';
import 'package:wiredash/src/common/device_info/device_info_generator.dart';
import 'package:wiredash/src/common/user/user_manager.dart';
import 'package:wiredash/src/common/widgets/dismissible_page_route.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';

import 'data/feedback_item.dart';
import 'feedback_sheet.dart';

class FeedbackModel with ChangeNotifier {
  FeedbackModel(
    this._captureKey,
    this._navigatorKey,
    this._userManager,
    this._feedbackSubmitter,
    this._deviceInfoGenerator,
  );

  final GlobalKey<CaptureState> _captureKey;
  final GlobalKey<NavigatorState> _navigatorKey;
  final UserManager _userManager;
  final FeedbackSubmitter _feedbackSubmitter;
  final DeviceInfoGenerator _deviceInfoGenerator;

  FeedbackType feedbackType = FeedbackType.bug;
  String? feedbackMessage;
  Uint8List? screenshot;

  FeedbackUiState _feedbackUiState = FeedbackUiState.hidden;

  FeedbackUiState get feedbackUiState => _feedbackUiState;

  set feedbackUiState(FeedbackUiState newValue) {
    if (_feedbackUiState == newValue) return;
    _feedbackUiState = newValue;
    _handleUiChange();
    notifyListeners();
  }

  bool _loading = false;

  bool get loading => _loading;

  set loading(bool newValue) {
    if (_loading == newValue) return;
    _loading = newValue;
    notifyListeners();
  }

  void _handleUiChange() {
    switch (_feedbackUiState) {
      case FeedbackUiState.intro:
        _clearFeedback();
        break;
      case FeedbackUiState.capture:
        _captureKey.currentState!.show().then((image) {
          screenshot = image;
          _feedbackUiState = FeedbackUiState.feedback;
          _navigatorKey.currentState!.push(
            DismissiblePageRoute(
              builder: (context) => const FeedbackSheet(),
              background: image,
              onPagePopped: () {
                feedbackUiState = FeedbackUiState.hidden;
              },
            ),
          );
        });
        break;
      case FeedbackUiState.submit:
        _sendFeedback();
        break;
      default:
      // do nothing
    }
  }

  void _clearFeedback() {
    feedbackMessage = null;
    screenshot = null;
    notifyListeners();
  }

  Future<void> _sendFeedback() async {
    loading = true;
    notifyListeners();

    final item = FeedbackItem(
      deviceInfo: _deviceInfoGenerator.generate(),
      email: _userManager.userEmail,
      message: feedbackMessage!,
      type: feedbackType.label,
      user: _userManager.userId,
    );

    try {
      await _feedbackSubmitter.submit(item, screenshot);
      _clearFeedback();
      _feedbackUiState = FeedbackUiState.submitted;
    } catch (e) {
      _feedbackUiState = FeedbackUiState.submissionError;
    }
    loading = false;
    notifyListeners();
  }

  void show() {
    assert(_navigatorKey.currentState != null, '''
Wiredash couldn't access your app's root navigator.

This is likely to happen when you forget to add the navigator key to your 
Material- / Cupertino- or WidgetsApp widget. 

To fix this, simply assign the same GlobalKey you assigned to Wiredash 
to your Material- / Cupertino- or WidgetsApp widget, like so:

return Wiredash(
  projectId: "YOUR-PROJECT-ID",
  secret: "YOUR-SECRET",
  navigatorKey: _navigatorKey, // <-- should be the same
  child: MaterialApp(
    navigatorKey: _navigatorKey, // <-- should be the same
    title: 'Flutter Demo',
    home: ...
  ),
);

For more info on how to setup Wiredash, check out 
https://github.com/wiredashio/wiredash-sdk

If this did not fix the issue, please file an issue at 
https://github.com/wiredashio/wiredash-sdk/issues

Thanks!
''');

    if (_navigatorKey.currentState == null ||
        feedbackUiState == FeedbackUiState.capture ||
        feedbackUiState != FeedbackUiState.hidden) return;

    feedbackUiState = FeedbackUiState.intro;
    final route = DismissiblePageRoute(
      builder: (context) => const FeedbackSheet(),
      onPagePopped: () => feedbackUiState = FeedbackUiState.hidden,
    );
    _navigatorKey.currentState!.push(route).then((_) {
      if (_feedbackUiState == FeedbackUiState.capture) {
        // The capture mode pops this route but it stays in capture mode
        // and doesn't switch to hidden
        return;
      }
      _feedbackUiState = FeedbackUiState.hidden;
    });
  }
}

enum FeedbackType { bug, improvement, praise }

extension FeedbackTypeMembers on FeedbackType {
  String get label => const {
        FeedbackType.bug: "bug",
        FeedbackType.improvement: "improvement",
        FeedbackType.praise: "praise",
      }[this]!;
}

enum FeedbackUiState {
  hidden,
  intro,
  capture,
  feedback,
  email,
  submit,
  submitted,
  submissionError,
}
