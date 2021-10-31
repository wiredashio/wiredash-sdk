import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';

/// A vertical [PageView] that fades items out and in
///
/// Use [viewInsets] to move the page into a fully visible area
class LarryPageView extends StatefulWidget {
  const LarryPageView({
    Key? key,
    this.viewInsets = EdgeInsets.zero,
    required this.stepCount,
    required this.builder,
  }) : super(key: key);

  final Widget Function(BuildContext context, int index) builder;

  /// Number of items to be returned by [builder]
  final int stepCount;

  /// The area which the page should *not* cover
  ///
  /// The item, when animating out/in still uses that space
  final EdgeInsets viewInsets;

  @override
  State<LarryPageView> createState() => LarryPageViewState();
}

class LarryPageViewState extends State<LarryPageView>
    with TickerProviderStateMixin<LarryPageView> {
  /// Drives the scroll animation once the finger leaves the screen
  late final AnimationController _controller;

  /// The index of the current [page]
  ///
  /// starting at 0 up to `widget.stepCount - 1`
  int _page = 0;

  /// The Y scroll position, the [Offset] the [ViewPort] is moved
  double _offset = 0;

  /// The distance the page has to be scrolled before it switches to the next page
  static const double _switchDistance = 200;

  /// [true] while the page is ballistic scrolling outwards (after the finger
  /// left the screen), waiting for [_switchDistance] to be reached switching
  /// the page.
  bool _animatingPageOut = false;

  /// Controls the inner [SingleChildScrollView] of the current page
  ScrollController _childScrollController = ScrollController();

  /// Calculates the velocity of the inner [SingleChildScrollView] during
  /// overscroll
  final VelocityTracker _innerVelocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: -double.maxFinite,
      upperBound: double.maxFinite,
    )..addListener(_onOffsetChanged);
  }

  @override
  void dispose() {
    _controller.dispose();
    _childScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widgetHeight = constraints.maxHeight;
          final _minItemHeight =
              widgetHeight - widget.viewInsets.top - widget.viewInsets.bottom;

          Widget boxed({required Widget child, required int index}) {
            const fadeDistance = 160.0;

            final opacity =
                1 - _offset.abs().clamp(0, fadeDistance) / fadeDistance;

            return KeyedSubtree(
              key: ValueKey(index),
              child: StepInheritedWidget(
                data: StepInformation(
                  active: index == _page,
                  animation: AlwaysStoppedAnimation<double>(opacity),
                ),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    minHeight: _minItemHeight,
                    maxHeight: _minItemHeight,
                  ),
                  child: Opacity(
                    opacity: opacity,
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onInnerScroll,
                      child: SingleChildScrollView(
                        controller: _childScrollController,
                        child: child,
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          Widget child = boxed(
            index: _page,
            child: Builder(
              builder: (context) => widget.builder(context, _page),
            ),
          );

          // ignore: join_return_with_assignment
          child = Viewport(
            offset: ViewportOffset.fixed(_offset),
            anchor: widget.viewInsets.top / widgetHeight,
            slivers: [
              SliverToBoxAdapter(
                child: child,
              ),
            ],
          );

          return child;
        },
      ),
    );
  }

  void moveToNextPage() {
    // TODO
  }

  bool _startedInnerScrollOnTopEdge = false;
  bool _startedInnerScrollOnBottomEdge = false;
  bool _outerScrollUp = false;
  bool _outerScrollDown = false;
  bool _waitForEnd = false;

  /// Called when the inner scrollview scrolls
  ///
  /// Drives [_controller] on overscroll
  bool _onInnerScroll(n) {
    // 1. the start event has to happen on the top or bottom edge to trigger
    // the outer scroll
    if (n is ScrollStartNotification) {
      if (n.dragDetails?.kind != PointerDeviceKind.touch) {
        // only allow outer scroll when using the touch screen
        return false;
      }
      if (n.metrics.pixels <= n.metrics.minScrollExtent) {
        // start at very top
        _startedInnerScrollOnTopEdge = true;
      }
      if (n.metrics.pixels >= n.metrics.maxScrollExtent) {
        // start at very bottom
        _startedInnerScrollOnBottomEdge = true;
      }

      final details = n.dragDetails;
      if (details != null && details.sourceTimeStamp != null) {
        _innerVelocityTracker.addPosition(
          details.sourceTimeStamp!,
          details.localPosition,
        );
        _onVerticalDragStart(details);
      }
      return false;
    }
    // 2. The direction of the scroll must immediately face towards overscroll
    // later direction changes are ignored
    if (n is UserScrollNotification) {
      if (_outerScrollUp || _outerScrollDown) {
        return false;
      }
      if (_startedInnerScrollOnTopEdge &&
          n.direction == ScrollDirection.forward) {
        _outerScrollUp = true;
      }
      if (_startedInnerScrollOnBottomEdge &&
          n.direction == ScrollDirection.reverse) {
        _outerScrollDown = true;
      }
    }
    // 3. forward overscroll events to pageview
    if (n is ScrollUpdateNotification) {
      if (_waitForEnd == true) {
        // already detected that the user started a fling, called _onVerticalDragEnd
        return false;
      }

      final details = n.dragDetails;
      if (details == null) {
        // when there are no details, this even is not from a user scroll event
        // but from a simulation. This happens after the user lifted the finger
        _waitForEnd = true;
        // calculate current velocity and drive the pageview with a simulation
        final velocity = _innerVelocityTracker.getVelocity();
        final end = DragEndDetails(
          velocity: velocity,
          primaryVelocity: velocity.pixelsPerSecond.dy,
        );
        _onVerticalDragEnd(end);
      } else {
        // with details just behave normally when scrolled inside the scrollview.

        // detect overscroll event and forward those to the pageview scroll mechanism
        if (_outerScrollUp && n.metrics.pixels <= n.metrics.minScrollExtent) {
          // Keep visual position of inner scroll view at top
          _childScrollController.position
              .correctPixels(n.metrics.minScrollExtent);
          // scroll outer scrollview and keep track of the velocity
          _onVerticalDragUpdate(details);
          _innerVelocityTracker.addPosition(
            details.sourceTimeStamp!,
            details.localPosition,
          );
        }
        if (_outerScrollDown && n.metrics.pixels >= n.metrics.maxScrollExtent) {
          // Keep visual position of inner scroll view at bottom
          _childScrollController.position
              .correctPixels(n.metrics.maxScrollExtent);
          // scroll outer scrollview and keep track of the velocity
          _onVerticalDragUpdate(details);
          _innerVelocityTracker.addPosition(
            details.sourceTimeStamp!,
            details.localPosition,
          );
        }
      }
      return false;
    }

    if (n is ScrollEndNotification) {
      // reset all values as they where before the touch
      _startedInnerScrollOnBottomEdge = false;
      _startedInnerScrollOnTopEdge = false;
      _outerScrollUp = false;
      _outerScrollDown = false;
      _waitForEnd = false;
      return false;
    }

    return false;
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final primaryVelocity = details.primaryVelocity!;

    bool jumpToZero = false;

    if (primaryVelocity.abs() > 1000) {
      if (primaryVelocity < 0) {
        // scroll up
        if (_page + 1 < widget.stepCount) {
          final sim = FrictionSimulation(1, -primaryVelocity, _offset);
          _controller.animateWith(sim);
          _animatingPageOut = true;
        } else {
          jumpToZero = true;
        }
      }
      if (primaryVelocity > 0) {
        if (_page > 0) {
          final sim = ClampingScrollSimulation(
            velocity: -primaryVelocity,
            position: _offset,
          );
          _controller.animateWith(sim);
          _animatingPageOut = true;
        } else {
          jumpToZero = true;
        }
      }
    } else {
      // jump back to 0
      jumpToZero = true;
    }

    if (jumpToZero) {
      _animatingPageOut = false;
      final sim = SpringSimulation(
        const SpringDescription(mass: 30, stiffness: 1, damping: 1),
        _offset,
        0,
        -primaryVelocity,
      );
      _controller.animateWith(sim);
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    _controller.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Account for finger movement
    setState(() {
      _offset = _offset - details.delta.dy;
    });
  }

  /// Called when the [_controller] is animating, meaning the [_offset] changes
  /// based on a [Simulation]
  void _onOffsetChanged() {
    setState(() {
      _offset = _controller.value;
    });

    if (_animatingPageOut) {
      const spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
      const delay = Duration(milliseconds: 150);
      const double inVelocity = 3000;
      if (_offset > _switchDistance) {
        if (_page + 1 < widget.stepCount) {
          _page++;
          _childScrollController.dispose();
          _childScrollController = ScrollController();
          _offset = -_switchDistance;
          _animatingPageOut = false;
          final sim = SpringSimulation(spring, _offset, 0, inVelocity);
          // TODO cancel on touch...
          Future.delayed(delay).then((value) {
            _controller.animateWith(sim);
          });
        }
      } else if (_offset < -_switchDistance) {
        if (_page > 0) {
          _page--;
          _childScrollController.dispose();
          _childScrollController = ScrollController();
          _offset = _switchDistance;
          _animatingPageOut = false;
          final sim = SpringSimulation(spring, _offset, 0, -inVelocity);
          // TODO cancel on touch...
          Future.delayed(delay).then((value) {
            _controller.animateWith(sim);
          });
        }
      }
    }
  }
}

class StepInheritedWidget extends InheritedWidget {
  const StepInheritedWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final StepInformation data;

  @override
  bool updateShouldNotify(StepInheritedWidget old) => data != old.data;
}

class StepInformation {
  final bool active;
  final Animation<double> animation;

  const StepInformation({
    required this.active,
    required this.animation,
  });

  static StepInformation of(BuildContext context) {
    final StepInheritedWidget? widget =
        context.dependOnInheritedWidgetOfExactType<StepInheritedWidget>();
    return widget!.data;
  }
}
