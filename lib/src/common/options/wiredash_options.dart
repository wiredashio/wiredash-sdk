import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/wiredash_options_data.dart';

class WiredashOptions extends StatelessWidget {
  const WiredashOptions({@required this.data, @required this.child, Key key})
      : super(key: key);

  final WiredashOptionsData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedWiredashOptions(
      options: this,
      child: child,
    );
  }

  static WiredashOptionsData of(BuildContext context) {
    final _InheritedWiredashOptions inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedWiredashOptions>();
    return inheritedTheme.options.data;
  }
}

class _InheritedWiredashOptions extends InheritedWidget {
  const _InheritedWiredashOptions({
    Key key,
    @required this.options,
    @required Widget child,
  })  : assert(options != null),
        super(key: key, child: child);

  final WiredashOptions options;

  @override
  bool updateShouldNotify(_InheritedWiredashOptions oldWidget) =>
      options != oldWidget.options;
}
