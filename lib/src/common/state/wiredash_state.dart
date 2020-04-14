import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/state/wiredash_state_data.dart';

class WiredashState extends StatelessWidget {
  const WiredashState({@required this.data, @required this.child});

  final WiredashStateData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedWiredashState(state: this, child: child);
  }

  static WiredashStateData of(BuildContext context, {bool listen = true}) {
    final _InheritedWiredashState inheritedState = listen
        ? context.dependOnInheritedWidgetOfExactType<_InheritedWiredashState>()
        : context.findAncestorWidgetOfExactType<_InheritedWiredashState>();
    return inheritedState.state.data;
  }
}

class _InheritedWiredashState extends InheritedWidget {
  const _InheritedWiredashState({
    Key key,
    @required this.state,
    @required Widget child,
  })  : assert(state != null),
        super(key: key, child: child);

  final WiredashState state;

  @override
  bool updateShouldNotify(_InheritedWiredashState oldWidget) =>
      state != oldWidget.state;
}
