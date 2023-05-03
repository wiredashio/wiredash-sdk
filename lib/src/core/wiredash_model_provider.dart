import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/wiredash_model.dart';

class WiredashModelProvider extends InheritedNotifier<WiredashModel> {
  const WiredashModelProvider({
    super.key,
    required WiredashModel wiredashModel,
    required super.child,
  }) : super(notifier: wiredashModel);

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

extension WiredashModelExtension on BuildContext {
  WiredashModel get wiredashModel => WiredashModelProvider.of(this);
}
