import 'package:flutter/widgets.dart';
import 'package:wiredash/src/nps/nps_model.dart';

class NpsModelProvider extends InheritedNotifier<NpsModel> {
  const NpsModelProvider({
    Key? key,
    required NpsModel npsModel,
    required Widget child,
  }) : super(key: key, notifier: npsModel, child: child);

  static NpsModel of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<NpsModelProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<NpsModelProvider>()!
          .notifier!;
    }
  }
}

extension FeedbackModelExtension on BuildContext {
  NpsModel get npsModel => NpsModelProvider.of(this);
}
