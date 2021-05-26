import 'dart:math';
import 'dart:typed_data';
import 'dart:ui' show lerpDouble;

import 'package:flutter/animation.dart' show Curves;
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

const double _kMinFlingVelocity = 0.5;
const int _kMaxDroppedSwipePageForwardAnimationTime = 1000;
const int _kMaxPageBackAnimationTime = 1000;

final Animatable<Offset> _kRightMiddleTween = Tween<Offset>(
  begin: const Offset(0.0, 1.0),
  end: Offset.zero,
);

final Animatable<Offset> _kMiddleLeftTween = Tween<Offset>(
  begin: Offset.zero,
  end: const Offset(0.0, -1.0 / 3.0),
);

class DismissiblePageRoute<T> extends PageRoute<T> {
  DismissiblePageRoute({
    required this.builder,
    this.background,
    this.onPagePopped,
    RouteSettings? settings,
  }) : super(settings: settings);

  final WidgetBuilder builder;
  final VoidCallback? onPagePopped;
  final Uint8List? background;
  bool _didUserPop = false;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => const Duration(milliseconds: 400);

  @override
  bool get opaque => background != null;

  @override
  Color? get barrierColor => null;

  @override
  String? get barrierLabel => null;

  @override
  bool canTransitionTo(TransitionRoute<dynamic> nextRoute) {
    return nextRoute is DismissiblePageRoute && !nextRoute.fullscreenDialog;
  }

  static bool isPopGestureInProgress(PageRoute<dynamic> route) {
    return route.navigator?.userGestureInProgress ?? false;
  }

  bool get popGestureInProgress => isPopGestureInProgress(this);

  @override
  Widget buildPage(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation) {
    final Widget child = builder(context);
    final Widget result = Semantics(
      scopesRoute: true,
      explicitChildNodes: true,
      child: child,
    );
    return result;
  }

  static _DownGestureController<T> _startPopGesture<T>(
    PageRoute<T> route, {
    VoidCallback? onPagePopped,
  }) {
    return _DownGestureController<T>(
      navigator: route.navigator!,
      controller: route.controller!,
      onPagePopped: onPagePopped,
    );
  }

  @override
  Widget buildTransitions(BuildContext context, Animation<double> animation,
      Animation<double> secondaryAnimation, Widget child) {
    return Semantics(
      container: true,
      child: WillPopScope(
        onWillPop: () async {
          onPagePopped?.call();
          return true;
        },
        child: Stack(
          children: <Widget>[
            GestureDetector(
              onTap: () {
                if (!_didUserPop && !navigator!.userGestureInProgress) {
                  navigator!.pop();
                  _didUserPop = true;
                }
                if (onPagePopped != null) {
                  onPagePopped?.call();
                }
              },
              child: FadeTransition(
                opacity: animation,
                child: Container(
                  color: const Color(0x90000000),
                  child: (background != null)
                      ? Image.memory(
                          background!,
                          color: const Color(0xff8b8b8d),
                          colorBlendMode: BlendMode.multiply,
                        )
                      : const SizedBox.expand(),
                ),
              ),
            ),
            DismissablePageTransition(
              primaryRouteAnimation: animation,
              secondaryRouteAnimation: secondaryAnimation,
              linearTransition: isPopGestureInProgress(this),
              child: _DownGestureDetector<T>(
                onStartPopGesture: () =>
                    _startPopGesture<T>(this, onPagePopped: onPagePopped),
                child: child,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  String get debugLabel => '${super.debugLabel}(${settings.name})';
}

class DismissablePageTransition extends StatelessWidget {
  DismissablePageTransition({
    Key? key,
    required Animation<double> primaryRouteAnimation,
    required Animation<double> secondaryRouteAnimation,
    required this.child,
    required bool linearTransition,
  })  : _primaryPositionAnimation = (linearTransition
                ? primaryRouteAnimation
                : CurvedAnimation(
                    parent: primaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kRightMiddleTween),
        _secondaryPositionAnimation = (linearTransition
                ? secondaryRouteAnimation
                : CurvedAnimation(
                    parent: secondaryRouteAnimation,
                    curve: Curves.linearToEaseOut,
                    reverseCurve: Curves.easeInToLinear,
                  ))
            .drive(_kMiddleLeftTween),
        super(key: key);

  final Animation<Offset> _primaryPositionAnimation;
  final Animation<Offset> _secondaryPositionAnimation;

  final Widget child;

  @override
  Widget build(BuildContext context) {
    assert(debugCheckHasDirectionality(context));
    final TextDirection textDirection = Directionality.of(context);
    return SlideTransition(
      position: _secondaryPositionAnimation,
      textDirection: textDirection,
      transformHitTests: false,
      child: SlideTransition(
        position: _primaryPositionAnimation,
        textDirection: textDirection,
        child: child,
      ),
    );
  }
}

class _DownGestureDetector<T> extends StatefulWidget {
  const _DownGestureDetector({
    Key? key,
    required this.onStartPopGesture,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final ValueGetter<_DownGestureController<T>> onStartPopGesture;

  @override
  _DownGestureDetectorState<T> createState() => _DownGestureDetectorState<T>();
}

class _DownGestureDetectorState<T> extends State<_DownGestureDetector<T>>
    with WidgetsBindingObserver {
  _DownGestureController<T>? _downGestureController;

  late VerticalDragGestureRecognizer _recognizer;

  @override
  void didChangeMetrics() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    _recognizer = VerticalDragGestureRecognizer(debugOwner: this)
      ..onStart = _handleDragStart
      ..onUpdate = _handleDragUpdate
      ..onEnd = _handleDragEnd
      ..onCancel = _handleDragCancel;
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void dispose() {
    _recognizer.dispose();
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    assert(mounted);
    assert(_downGestureController == null);
    _downGestureController = widget.onStartPopGesture();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);
    _downGestureController!
        .dragUpdate((details.primaryDelta ?? 0) / (context.size?.height ?? 1));
  }

  void _handleDragEnd(DragEndDetails details) {
    assert(mounted);
    _downGestureController!.dragEnd(
        details.velocity.pixelsPerSecond.dx / (context.size?.height ?? 1));
    _downGestureController = null;
  }

  void _handleDragCancel() {
    assert(mounted);
    _downGestureController?.dragEnd(0.0);
    _downGestureController = null;
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      alignment: Alignment.bottomCenter,
      margin: EdgeInsets.only(
          bottom: WidgetsBinding.instance!.window.viewInsets.bottom /
              WidgetsBinding.instance!.window.devicePixelRatio),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: SingleChildScrollView(
          padding: EdgeInsets.only(top: MediaQuery.of(context).padding.top),
          child: Stack(
            fit: StackFit.passthrough,
            children: <Widget>[
              widget.child,
              Positioned(
                left: 0,
                top: 0,
                right: 0,
                height: 148,
                child: Listener(
                  onPointerDown: _recognizer.addPointer,
                  behavior: HitTestBehavior.translucent,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DownGestureController<T> {
  _DownGestureController({
    required this.navigator,
    required this.controller,
    this.onPagePopped,
  }) {
    navigator.didStartUserGesture();
  }

  final AnimationController controller;
  final NavigatorState navigator;
  final VoidCallback? onPagePopped;

  void dragUpdate(double delta) {
    controller.value -= delta;
  }

  void dragEnd(double velocity) {
    const Curve animationCurve = Curves.fastLinearToSlowEaseIn;
    bool animateForward;

    if (velocity >= _kMinFlingVelocity && controller.value != 1.0) {
      animateForward = velocity <= 0.5;
    } else {
      animateForward = controller.value > 0.75;
    }

    if (animateForward) {
      final time = lerpDouble(
          _kMaxDroppedSwipePageForwardAnimationTime, 0, controller.value);
      final int droppedPageForwardAnimationTime =
          min(time?.floor() ?? 0, _kMaxPageBackAnimationTime);
      controller.animateTo(1.0,
          duration: Duration(milliseconds: droppedPageForwardAnimationTime),
          curve: animationCurve);
    } else {
      navigator.pop();
      onPagePopped?.call();
      if (controller.isAnimating) {
        final time = lerpDouble(
            0, _kMaxDroppedSwipePageForwardAnimationTime, controller.value);
        final droppedPageBackAnimationTime = time?.floor() ?? 0;
        controller.animateBack(0.0,
            duration: Duration(milliseconds: droppedPageBackAnimationTime),
            curve: animationCurve);
      }
    }

    if (controller.isAnimating) {
      late AnimationStatusListener animationStatusCallback;
      animationStatusCallback = (AnimationStatus status) {
        navigator.didStopUserGesture();
        controller.removeStatusListener(animationStatusCallback);
      };
      controller.addStatusListener(animationStatusCallback);
    } else {
      navigator.didStopUserGesture();
    }
  }
}
