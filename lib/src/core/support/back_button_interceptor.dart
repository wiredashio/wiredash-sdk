import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

class BackButtonInterceptor extends StatefulWidget {
  const BackButtonInterceptor({
    Key? key,
    required this.onBackPressed,
    required this.child,
  }) : super(key: key);

  final OnBackPressed onBackPressed;
  final Widget child;

  @override
  State<BackButtonInterceptor> createState() => _BackButtonInterceptorState();
}

class _BackButtonInterceptorState extends State<BackButtonInterceptor> {
  Disposable? _disposable;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _disposable?.call();
    _disposable = WiredashBackButtonDispatcher.of(context)
        .addListener(widget.onBackPressed);
  }

  @override
  void didUpdateWidget(covariant BackButtonInterceptor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.onBackPressed != widget.onBackPressed) {
      _disposable?.call();
      _disposable = WiredashBackButtonDispatcher.of(context)
          .addListener(widget.onBackPressed);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _disposable?.call();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }
}

typedef OnBackPressed = FutureOr<BackButtonAction> Function();

typedef Disposable = void Function();

enum BackButtonAction {
  /// When a back button action has been triggered and no further action
  /// should be triggered
  consumed,

  /// No action has been triggered for this event, other consumers can handle it
  ignored,
}

class WiredashBackButtonDispatcher extends WidgetsBindingObserver {
  void initialize() {
    widgetsBindingInstance.addObserver(this);
  }

  @mustCallSuper
  void dispose() {
    widgetsBindingInstance.removeObserver(this);
  }

  @override
  Future<bool> didPopRoute() async {
    print("Intercepted didPopRoute");
    final listeners = _listeners.reversed.toList();
    for (final listener in listeners) {
      final result = listener.call();
      if (result == BackButtonAction.consumed) {
        return true;
      }
    }
    return false;
  }

  static WiredashBackButtonDispatcher of(BuildContext context) {
    final BackButtonDispatcherInheritedWidget? result =
        context.dependOnInheritedWidgetOfExactType<
            BackButtonDispatcherInheritedWidget>();
    assert(result != null, 'No BackButtonDispatcher found in context');
    return result!.dispatcher;
  }

  final List<OnBackPressed> _listeners = [];

  Disposable addListener(OnBackPressed onBackPressed) {
    _listeners.add(onBackPressed);
    return () {
      _listeners.remove(onBackPressed);
    };
  }
}

class BackButtonDispatcherInheritedWidget extends InheritedWidget {
  const BackButtonDispatcherInheritedWidget({
    Key? key,
    required this.dispatcher,
    required Widget child,
  }) : super(key: key, child: child);

  final WiredashBackButtonDispatcher dispatcher;

  @override
  bool updateShouldNotify(BackButtonDispatcherInheritedWidget old) =>
      dispatcher != old.dispatcher;
}
