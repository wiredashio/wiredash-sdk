import 'package:wiredash/src/core/wiredash_controller.dart';

/// The result of [WiredashController.show]
class FeedbackResult {
  /// True when the user has submitted feedback
  final bool hasSubmittedFeedback;

  /// Constructs a new [FeedbackResult]
  FeedbackResult({
    required this.hasSubmittedFeedback,
  });
}
