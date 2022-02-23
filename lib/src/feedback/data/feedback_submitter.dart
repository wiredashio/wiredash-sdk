import 'package:wiredash/src/feedback/data/direct_feedback_submitter.dart';
import 'package:wiredash/src/feedback/data/persisted_feedback_item.dart';
import 'package:wiredash/src/feedback/data/retrying_feedback_submitter.dart';

/// Interface which allows submission of feedback to the backend
///
/// Known subtypes
/// - [RetryingFeedbackSubmitter]
/// - [DirectFeedbackSubmitter]
abstract class FeedbackSubmitter {
  /// Submits the feedback item to the backend
  Future<SubmissionState> submit(PersistedFeedbackItem item);
}

enum SubmissionState {
  /// The feedback is transmitted to the backend
  submitted,

  /// The feedback is stored locally and will be retried later. The first
  /// attempt did not succeed.
  ///
  /// But nothing to worry, it will be transmitted later
  pending,
}
