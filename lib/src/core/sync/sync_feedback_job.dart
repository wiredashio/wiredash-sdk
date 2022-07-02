import 'package:flutter/foundation.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

class UploadPendingFeedbackJob extends Job {
  final FeedbackSubmitter feedbackSubmitter;

  UploadPendingFeedbackJob({
    required this.feedbackSubmitter,
  });

  @override
  bool shouldExecute(SdkEvent event) {
    return [SdkEvent.appStart].contains(event);
  }

  @override
  Future<void> execute() async {
    if (feedbackSubmitter is! RetryingFeedbackSubmitter) {
      return;
    }

    final submitter = feedbackSubmitter as RetryingFeedbackSubmitter;
    await submitter.submitPendingFeedbackItems();

    if (kDebugMode) {
      await submitter.deletePendingFeedbacks();
    }
  }
}
