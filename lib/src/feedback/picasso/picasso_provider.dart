import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';

class PicassoControllerProvider extends InheritedNotifier<PicassoController> {
  const PicassoControllerProvider({
    super.key,
    required PicassoController picassoController,
    required super.child,
  }) : super(notifier: picassoController);

  static PicassoController of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<PicassoControllerProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<PicassoControllerProvider>()!
          .notifier!;
    }
  }
}

extension WiredashExtensions on BuildContext {
  PicassoController get picasso => PicassoControllerProvider.of(this);
}
