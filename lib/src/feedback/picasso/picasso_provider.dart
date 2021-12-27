import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';

class PicassoControllerProvider extends InheritedNotifier<PicassoController> {
  const PicassoControllerProvider({
    Key? key,
    required PicassoController picassoController,
    required Widget child,
  }) : super(key: key, notifier: picassoController, child: child);

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
