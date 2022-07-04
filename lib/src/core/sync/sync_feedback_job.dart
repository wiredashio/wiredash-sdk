import 'package:flutter/foundation.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';
import 'package:wiredash/src/feedback/_feedback.dart';

class UploadPendingFeedbackJob extends Job {
  final FeedbackSubmitter Function() feedbackSubmitterProvider;

  UploadPendingFeedbackJob({
    required this.feedbackSubmitterProvider,
  });

  @override
  bool shouldExecute(SdkEvent event) {
    return [SdkEvent.appStart].contains(event);
  }

  @override
  Future<void> execute() async {
    final submitter = feedbackSubmitterProvider();
    if (submitter is! RetryingFeedbackSubmitter) {
      return;
    }

    await submitter.submitPendingFeedbackItems();

    if (kDebugMode) {
      await submitter.deletePendingFeedbacks();
    }
  }
}
