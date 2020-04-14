import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/state/capture_state_data.dart';

class CaptureState extends StatelessWidget {
  const CaptureState({@required this.data, @required this.child});

  final CaptureStateData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedCaptureState(state: this, child: child);
  }

  static CaptureStateData of(BuildContext context) {
    final _InheritedCaptureState inheritedState =
        context.dependOnInheritedWidgetOfExactType<_InheritedCaptureState>();
    return inheritedState.state.data;
  }
}

class _InheritedCaptureState extends InheritedWidget {
  const _InheritedCaptureState({
    Key key,
    @required this.state,
    @required Widget child,
  })  : assert(state != null),
        super(key: key, child: child);

  final CaptureState state;

  @override
  bool updateShouldNotify(_InheritedCaptureState oldWidget) =>
      state != oldWidget.state;
}
