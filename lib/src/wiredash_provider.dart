import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/wiredash_model.dart';

class WiredashProvider extends InheritedWidget {
  const WiredashProvider({
    Key? key,
    required this.wiredashModel,
    required Widget child,
  }) : super(key: key, child: child);

  final WiredashModel wiredashModel;

  static WiredashProvider? of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<WiredashProvider>();
  }

  @override
  bool updateShouldNotify(WiredashProvider old) {
    return wiredashModel != old.wiredashModel;
  }
}

extension WiredashExtensions on BuildContext {
  WiredashModel? get wiredashModel => WiredashProvider.of(this)?.wiredashModel;
}
