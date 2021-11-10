import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/wiredash_model.dart';

class WiredashModelProvider extends InheritedNotifier<WiredashModel> {
  const WiredashModelProvider({
    Key? key,
    required WiredashModel wiredashModel,
    required Widget child,
  }) : super(key: key, notifier: wiredashModel, child: child);

  static WiredashModel of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<WiredashModelProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<WiredashModelProvider>()!
          .notifier!;
    }
  }
}

extension WiredashExtensions on BuildContext {
  WiredashModel get wiredashModel => WiredashModelProvider.of(this);
}
