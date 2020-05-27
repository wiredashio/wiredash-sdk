import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

class WiredashTheme extends StatelessWidget {
  const WiredashTheme({@required this.data, @required this.child, Key key})
      : super(key: key);

  final WiredashThemeData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedWiredashTheme(theme: this, child: child);
  }

  static WiredashThemeData of(BuildContext context) {
    final _InheritedWiredashTheme inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedWiredashTheme>();
    return inheritedTheme.theme.data;
  }
}

class _InheritedWiredashTheme extends InheritedWidget {
  const _InheritedWiredashTheme({
    Key key,
    @required this.theme,
    @required Widget child,
  })  : assert(theme != null),
        super(key: key, child: child);

  final WiredashTheme theme;

  @override
  bool updateShouldNotify(_InheritedWiredashTheme oldWidget) =>
      theme != oldWidget.theme;
}
