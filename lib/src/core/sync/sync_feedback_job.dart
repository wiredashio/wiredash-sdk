import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/core/sync/sync_engine.dart';

class UploadPendingFeedbackJob extends Job {
  final FeedbackSubmitter Function() feedbackSubmitterProvider;

  UploadPendingFeedbackJob({
    required this.feedbackSubmitterProvider,
  });

  @override
  bool shouldExecute(SdkEvent event) {
    return [
      SdkEvent.appStartDelayed,
      SdkEvent.appMovedToBackground,
    ].contains(event);
  }

  @override
  Future<void> execute(SdkEvent event) async {
    final submitter = feedbackSubmitterProvider();
    if (submitter is! RetryingFeedbackSubmitter) {
      return;
    }

    await submitter.submitPendingFeedbackItems();

    if (kDevMode) {
      await submitter.deletePendingFeedbacks();
    }
  }
}
