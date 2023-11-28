import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class FeedbackModelProvider extends InheritedNotifier<FeedbackModel> {
  const FeedbackModelProvider({
    super.key,
    required FeedbackModel feedbackModel,
    required super.child,
  }) : super(notifier: feedbackModel);
}

extension FeedbackModelExtension on BuildContext {
  FeedbackModel get watchFeedbackModel =>
      dependOnInheritedWidgetOfExactType<FeedbackModelProvider>()!.notifier!;

  FeedbackModel get readFeedbackModel =>
      findAncestorWidgetOfExactType<FeedbackModelProvider>()!.notifier!;
}
