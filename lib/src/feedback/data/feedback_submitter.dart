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
  Future<void> submit(PersistedFeedbackItem item);
}
