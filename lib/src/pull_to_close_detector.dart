import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/wiredash_backdrop.dart';

/// Enables a pull to close gesture for the minimized app while
/// [WiredashBackdrop] is open
class PullToCloseDetector extends StatefulWidget {
  const PullToCloseDetector({
    Key? key,
    required this.animController,
    required this.child,
    required this.distanceToBottom,
    required this.topPosition,
    this.onPullStart,
    this.onPullEnd,
  }) : super(key: key);

  final Widget child;

  final AnimationController animController;

  // the remaining distance to bottom (closed)
  final double distanceToBottom;

  final double topPosition;

  final void Function()? onPullStart;

  final void Function()? onPullEnd;

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

    _distanceToBottom = widget.distanceToBottom;
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  // internal cache because the touch events update faster than the widgetTree rebuilds
  double _distanceToBottom = 0.0;

  @override
  void didUpdateWidget(covariant PullToCloseDetector oldWidget) {
    if (oldWidget.distanceToBottom != widget.distanceToBottom) {
      _distanceToBottom = widget.distanceToBottom;
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onPullStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);

    final delta = details.delta.dy;
    final newDistanceToBottom = _distanceToBottom - delta;
    final diff = newDistanceToBottom / widget.topPosition;
    widget.animController.value = diff;
    _distanceToBottom = newDistanceToBottom;
  }

  void _handleDragEnd(DragEndDetails details) async {
    final velocity = details.primaryVelocity ?? 0;

    if (velocity > 0) {
      final completeDuration = widget.animController.reverseDuration!;
      await widget.animController.animateBack(
        0.0,
        duration: completeDuration * widget.animController.value,
        curve: Curves.easeOut,
      );
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

  void _handleDragCancel() async {
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
