import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/data/feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

class WiredashModel with ChangeNotifier {
  WiredashModel(
    this._feedbackSubmitter,
  );

  final FeedbackSubmitter _feedbackSubmitter;

  bool _isActive = false;

  /// `true` when wiredash is active
  bool get isActive => _isActive;

  set isActive(bool isActive) {
    _isActive = isActive;
    notifyListeners();
  }

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
