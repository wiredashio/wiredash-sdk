import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';

enum CloseDirection {
  upwards,
  downwards,
}

/// Enables a pull to close gesture for the minimized app while
/// [WiredashBackdrop] is open
class PullToCloseDetector extends StatefulWidget {
  const PullToCloseDetector({
    Key? key,
    required this.animController,
    required this.child,
    required this.distanceToEdge,
    required this.openedPosition,
    this.onPullStart,
    this.onPullEnd,
    this.onClosed,
    this.onClosing,
    this.closeDirection = CloseDirection.downwards,
  }) : super(key: key);

  final Widget child;

  final AnimationController animController;

  final CloseDirection closeDirection;

  /// The remaining distance to the edge of the screen to be fully closed
  final double distanceToEdge;

  /// The position of the draggable at the fully opened position.
  final double openedPosition;

  final void Function()? onPullStart;

  final void Function()? onPullEnd;

  final void Function()? onClosed;

  /// called when the pull to close is detected and the controller will be
  /// forwarded to the final close state.
  final void Function()? onClosing;

  @override
  _PullToCloseDetectorState createState() => _PullToCloseDetectorState();
}

class _PullToCloseDetectorState extends State<PullToCloseDetector> {
  late final VerticalDragGestureRecognizer _recognizer =
      VerticalDragGestureRecognizer(debugOwner: this)
        ..onStart = _handleDragStart
        ..onUpdate = _handleDragUpdate
        ..onEnd = _handleDragEnd
        ..onCancel = _handleDragCancel;

  @override
  void initState() {
    super.initState();

    _distanceToClosed = widget.distanceToEdge;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  // internal cache because the touch events update faster than the widgetTree rebuilds
  double _distanceToClosed = 0.0;

  @override
  void didUpdateWidget(covariant PullToCloseDetector oldWidget) {
    if (oldWidget.distanceToEdge != widget.distanceToEdge) {
      _distanceToClosed = widget.distanceToEdge;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onPullStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);

    final delta = details.delta.dy;
    final newDistanceToBottom = () {
      if (widget.closeDirection == CloseDirection.downwards) {
        return _distanceToClosed - delta;
      } else {
        return _distanceToClosed + delta;
      }
    }();
    final diff = newDistanceToBottom / widget.openedPosition;
    widget.animController.value = diff;
    _distanceToClosed = newDistanceToBottom;
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    final velocity = details.primaryVelocity ?? 0;

    print(velocity);
    if (widget.closeDirection == CloseDirection.downwards && velocity > 0 ||
        widget.closeDirection == CloseDirection.upwards && velocity < 0) {
      final completeDuration = widget.animController.reverseDuration!;
      widget.onClosing?.call();
      // TODO replace with simulation
      await widget.animController.animateBack(
        0.0,
        duration: completeDuration * widget.animController.value,
        curve: Curves.easeOut,
      );
      widget.onClosed?.call();
    } else {
      final completeDuration = widget.animController.duration!;
      await widget.animController.animateTo(
        1.0,
        duration: completeDuration * (1 - widget.animController.value),
        curve: Curves.easeOut,
      );
    }
    widget.onPullEnd?.call();
  }

  Future<void> _handleDragCancel() async {
    assert(mounted);
    await widget.animController.animateBack(
      1.0,
      duration: widget.animController.duration,
      curve: Curves.easeOut,
    );
    widget.onPullEnd?.call();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      onPointerDown: _recognizer.addPointer,
      behavior: HitTestBehavior.translucent,
      child: widget.child,
    );
  }
}
