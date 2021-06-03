import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(
    this._feedbackSubmitter,
  );

  final FeedbackSubmitter _feedbackSubmitter;

  /// `true` when wiredash is active
  bool get isWiredashActive => _isWiredashActive;
  bool _isWiredashActive = false;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  /// Deletes pending feedbacks
  ///
  /// Usually only relevant for debug builds
  Future<void> clearPendingFeedbacks() async {
    debugPrint("Deleting pending feedbacks");
    final submitter = _feedbackSubmitter;
    if (submitter is RetryingFeedbackSubmitter) {
      await submitter.deletePendingFeedbacks();
    }
  }

  void show() {
    _isWiredashActive = true;
    _isAppInteractive = false;
    notifyListeners();
  }

  void hide() {
    _isWiredashActive = false;
    _isAppInteractive = true;
    notifyListeners();
  }

  // Future<void> _sendFeedback() async {
  //   final item = FeedbackItem(
  //     deviceInfo: _deviceInfoGenerator.generate(),
  //     email: _userManager.userEmail,
  //     message: feedbackMessage!,
  //     type: feedbackType.label,
  //     user: _userManager.userId,
  //   );
  //
  //   try {
  //     await _feedbackSubmitter.submit(item, screenshot);
  //   } catch (e) {
  //   }
  // }
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
