import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
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
    this.onClosed,
    this.onClosing,
    this.onOpening,
    this.onOpened,
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

  final void Function()? onClosed;

  final void Function()? onOpened;

  final void Function()? onOpening;

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
      print("update _distanceToClosed $_distanceToClosed");
    }
    super.didUpdateWidget(oldWidget);
  }

  void _handleDragStart(DragStartDetails details) {
    widget.onPullStart?.call();
  }

  void _handleDragUpdate(DragUpdateDetails details) {
    assert(mounted);

    print("anim ${widget.animController.value}");
    print(" widget.openedPosition ${widget.openedPosition}");
    print("_distanceToClosed = $_distanceToClosed");
    final delta = details.delta.dy;
    final newDistanceToBottom = () {
      return _distanceToClosed - delta;
      if (widget.closeDirection == CloseDirection.downwards) {
        return _distanceToClosed - delta;
      } else {}
    }();
    print("newDistanceToBottom = $newDistanceToBottom");
    final diff = newDistanceToBottom / widget.openedPosition;
    print("diff = $diff");
    widget.animController.value = diff;
    print("new anim ${widget.animController.value}");
    _distanceToClosed = newDistanceToBottom;
  }

  Future<void> _handleDragEnd(DragEndDetails details) async {
    final velocity = details.primaryVelocity ?? 0;

    if (widget.closeDirection == CloseDirection.downwards && velocity > 0 ||
        widget.closeDirection == CloseDirection.upwards && velocity < 0) {
      widget.onClosing?.call();
      final sim = SpringSimulation(
        const SpringDescription(mass: 30, stiffness: 1, damping: 1),
        widget.animController.value,
        0.0,
        -velocity / widget.openedPosition,
      );
      // widget.animController.stop(canceled: true);
      print("close with simulation");
      widget.animController.animateWith(sim).then((value) {
        // TODO cancel eventually
        widget.onClosed?.call();
      });
    } else {
      print("open again");
      widget.onOpening?.call();
      final completeDuration = widget.animController.duration!;
      await widget.animController.animateTo(
        1.0,
        duration: completeDuration * (1 - widget.animController.value),
        curve: Curves.easeOut,
      );
      widget.onOpened?.call();
    }
  }

  Future<void> _handleDragCancel() async {
    assert(mounted);
    // TODO solve with simulation
    await widget.animController.animateBack(
      1.0,
      duration: widget.animController.duration,
      curve: Curves.easeOut,
    );
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
