import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';

class FeedbackModelProvider extends InheritedNotifier<FeedbackModel> {
  const FeedbackModelProvider({
    Key? key,
    required FeedbackModel feedbackModel,
    required Widget child,
  }) : super(key: key, notifier: feedbackModel, child: child);

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

extension WiredashExtensions on BuildContext {
  FeedbackModel get feedbackModel => FeedbackModelProvider.of(this);
}
