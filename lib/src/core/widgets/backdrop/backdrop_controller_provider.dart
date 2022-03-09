import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/widgets/backdrop/wiredash_backdrop.dart';

class BackdropControllerProvider extends InheritedNotifier<BackdropController> {
  const BackdropControllerProvider({
    Key? key,
    required BackdropController backdropController,
    required Widget child,
  }) : super(key: key, notifier: backdropController, child: child);

  static BackdropController of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<BackdropControllerProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<BackdropControllerProvider>()!
          .notifier!;
    }
  }
}

extension WiredashExtensions on BuildContext {
  BackdropController get backdropController =>
      BackdropControllerProvider.of(this);
}
