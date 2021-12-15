import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';

enum CloseDirection {
  upwards,
  downwards,
}

/// Enables a pull to close gesture for the minimized app while
/// [WiredashBackdrop] is open
class PullToCloseDetector extends StatefulWidget {
  const PullToCloseDetector({
    Key? key,
    required this.child,
    // required this.distanceToEdge,
    // required this.openedPosition,
    this.onPullStart,
    required this.onPull,
    required this.startCloseSimulation,
    required this.startReopenSimulation,
    this.closeDirection = CloseDirection.downwards,
  }) : super(key: key);

  final Widget child;

  final CloseDirection closeDirection;

  // /// The remaining distance to the edge of the screen to be fully closed
  // final double distanceToEdge;
  //
  // /// The position of the draggable at the fully opened position.
  // final double openedPosition;

  final void Function(double delta) onPull;

  final void Function()? onPullStart;

  final void Function(double velocity) startCloseSimulation;

  final void Function(double velocity) startReopenSimulation;

  @override
  State<PullToCloseDetector> createState() => _PullToCloseDetectorState();
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
  }

  @override
  void dispose() {
    _recognizer.dispose();
    super.dispose();
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onPullStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    var delta = details.delta.dy;
    if (widget.closeDirection == CloseDirection.downwards) {
      delta *= -1;
    }
    widget.onPull(delta);
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    final velocity = details.primaryVelocity ?? 0;

    if (widget.closeDirection == CloseDirection.downwards && velocity > 0 ||
        widget.closeDirection == CloseDirection.upwards && velocity < 0) {
      widget.startCloseSimulation(velocity);

      // final sim = SpringSimulation(
      //   const SpringDescription(mass: 30, stiffness: 1, damping: 1),
      //   widget.animController.value,
      //   0.0,
      //   -velocity / widget.openedPosition,
      // );
    } else {
      widget.startReopenSimulation(velocity);
    }
  }

  Future<void> _handleDragCancel() async {
    widget.startReopenSimulation(0);
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
