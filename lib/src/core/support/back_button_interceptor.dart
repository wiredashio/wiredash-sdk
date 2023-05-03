import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

/// Allows intercepting of the Android back button
class BackButtonInterceptor extends StatefulWidget {
  const BackButtonInterceptor({
    super.key,
    required this.onBackPressed,
    required this.child,
  });

  /// Return [BackButtonAction.consumed] when a back action was handles and return
  /// [BackButtonAction.ignored] to give other [BackButtonInterceptor]s the chance
  /// to react
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

/// Observs [WidgetsBinding.instance] and forwards Android Back button actions
/// to [BackButtonInterceptor] in the widget tree
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
    // process listeneres in reverse order, assuming the latest listener added
    // is the furthest down the widget tree. Ignoring that that part of the
    // widget tree might not have the focus
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
    final _BackButtonDispatcherInheritedWidget? result =
        context.dependOnInheritedWidgetOfExactType<
            _BackButtonDispatcherInheritedWidget>();
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

  /// Use this to inject this dispatcher into the widget tree. Children can
  /// access it via [WiredashBackButtonDispatcher.of] or by using the
  /// [BackButtonInterceptor] widget.
  Widget wrap({required Widget child}) {
    return _BackButtonDispatcherInheritedWidget(dispatcher: this, child: child);
  }
}

class _BackButtonDispatcherInheritedWidget extends InheritedWidget {
  const _BackButtonDispatcherInheritedWidget({
    required this.dispatcher,
    required super.child,
  });

  final WiredashBackButtonDispatcher dispatcher;

  @override
  bool updateShouldNotify(_BackButtonDispatcherInheritedWidget old) =>
      dispatcher != old.dispatcher;
}
