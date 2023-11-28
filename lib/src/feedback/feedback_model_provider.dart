import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class FeedbackModelProvider extends InheritedNotifier<FeedbackModel> {
  const FeedbackModelProvider({
    super.key,
    required FeedbackModel feedbackModel,
    required super.child,
  }) : super(notifier: feedbackModel);

  static FeedbackModel of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<FeedbackModelProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<FeedbackModelProvider>()!
          .notifier!;
    }
  }
}

extension FeedbackModelExtension on BuildContext {
  FeedbackModel get watchFeedbackModel => FeedbackModelProvider.of(this);
  FeedbackModel get readFeedbackModel =>
      FeedbackModelProvider.of(this, listen: false);
}
