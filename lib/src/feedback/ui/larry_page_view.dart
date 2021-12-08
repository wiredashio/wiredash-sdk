import 'dart:async';

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
    required this.stepCount,
    required this.builder,
    this.onPageChanged,
    this.initialPage = 0,
    this.pageIndex = 0,
  }) : super(key: key);

  final Widget Function(BuildContext context) builder;

  /// called when the page changes
  final void Function(int index)? onPageChanged;

  /// Number of items to be returned by [builder]
  final int stepCount;

  final int initialPage;

  /// The index of the current page
  final int pageIndex;

  @override
  State<LarryPageView> createState() => LarryPageViewState();
}

class LarryPageViewState extends State<LarryPageView>
    with TickerProviderStateMixin<LarryPageView> {
  /// Drives the scroll animation once the finger leaves the screen
  late final AnimationController _controller;

  /// The Y scroll position, the [Offset] the [ViewPort] is moved
  double _offset = 0;

  /// [true] while the page is ballistic scrolling outwards (after the finger
  /// left the screen), waiting for [_pageSwitchDistance] to be reached switching
  /// the page.
  bool _animatingPageOut = false;

  /// Controls the inner [SingleChildScrollView] of the current page
  ScrollController _childScrollController = ScrollController();

  /// Calculates the velocity of the inner [SingleChildScrollView] during
  /// overscroll
  final VelocityTracker _innerVelocityTracker =
      VelocityTracker.withKind(PointerDeviceKind.touch);

  /// The distance a page has to be moved before it switches to the next page
  static const double _pageSwitchDistance = 200;

  /// Spring used when switching pages
  static const _pageSpring =
      SpringDescription(mass: 30, stiffness: 1, damping: 1);

  /// Fixed velocity for pages animating in
  static const double _pageEnterVelocity = 3000;

  /// Acceleration when
  static const double _pageExitAcceleration = 10;

  /// delay between fading out a page and entering the new one
  static const _pageEnterDelay = Duration(milliseconds: 150);

  /// Timer used to delay the entry of the incoming page by [_pageEnterDelay]
  Timer? _nextPageTimer;

  /// Distance the page has to travel to be fully invisible
  ///
  /// Should be smaller than [_pageSwitchDistance]
  static const _fadeDistance = 160.0;

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
    _nextPageTimer?.cancel();
    super.dispose();
  }

  // @override
  // void didUpdateWidget(covariant LarryPageView oldWidget) {
  //   if (oldWidget.stepCount < widget.stepCount) {
  //     _page
  //   }
  //   super.didUpdateWidget(oldWidget);
  // }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragStart: _onVerticalDragStart,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          Widget child = Builder(
            builder: (context) {
              return widget.builder(context);
            },
          );

          final widgetHeight = constraints.maxHeight;
          final _minItemHeight = widgetHeight;

          // constrain content area to a fixed size
          child = SizedBox(
            height: _minItemHeight,
            child: child,
          );

          final double opacity = () {
            if (_nextPageTimer != null) {
              // hide next page, while delaying in-animation
              return 0.0;
            }
            if (widget.pageIndex == 0 && _offset < 0) {
              // first item
              return 1.0;
            }
            if (widget.pageIndex == widget.stepCount - 1 && _offset > 0) {
              // last item
              return 1.0;
            }
            return 1 - _offset.abs().clamp(0, _fadeDistance) / _fadeDistance;
          }();

          child = KeyedSubtree(
            key: ValueKey(widget.pageIndex),
            child: StepInheritedWidget(
              data: StepInformation(
                index: widget.pageIndex,
                animation: AlwaysStoppedAnimation<double>(opacity),
                pageView: this,
                innerScrollController: _childScrollController,
              ),
              child: Opacity(
                opacity: opacity,
                child: NotificationListener<ScrollNotification>(
                  onNotification: _onInnerScroll,
                  child: ScrollConfiguration(
                    // BouncingScrollPhysics is required on all platforms or
                    // the overscroll detection wouldn't work
                    behavior: const ScrollBehavior()
                        .copyWith(physics: const BouncingScrollPhysics()),
                    child: child,
                  ),
                ),
              ),
            ),
          );

          // ignore: join_return_with_assignment
          child = Viewport(
            clipBehavior: Clip.none,
            offset: ViewportOffset.fixed(_offset),
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
      // TODO allow scrolling with mouse wheel only on desktop
      // if (n.dragDetails?.kind != PointerDeviceKind.touch) {
      //  // only allow outer scroll when using the touch screen
      //  // return false;
      // }
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
      return true;
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
        // TODO check where the double jump is coming from
        // scroll up
        if (widget.pageIndex + 1 < widget.stepCount) {
          final sim = FrictionSimulation(1, -primaryVelocity, _offset);
          _controller.animateWith(sim);
          _animatingPageOut = true;
        } else {
          jumpToZero = true;
        }
      }
      if (primaryVelocity > 0) {
        if (widget.pageIndex > 0) {
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
      if (_offset > _pageSwitchDistance) {
        if (widget.pageIndex + 1 < widget.stepCount) {
          // _page++;
          _childScrollController.dispose();
          _childScrollController = ScrollController();
          _offset = -_pageSwitchDistance;
          _animatingPageOut = false;
          widget.onPageChanged?.call(widget.pageIndex + 1);
          final sim =
              SpringSimulation(_pageSpring, _offset, 0, _pageEnterVelocity);
          _nextPageTimer?.cancel();
          _nextPageTimer = Timer(_pageEnterDelay, () {
            _controller.animateWith(sim);
            _nextPageTimer = null;
          });
        }
      } else if (_offset < -_pageSwitchDistance) {
        if (widget.pageIndex > 0) {
          // _page--;
          _childScrollController.dispose();
          _childScrollController = ScrollController();
          _offset = _pageSwitchDistance;
          _animatingPageOut = false;
          widget.onPageChanged?.call(widget.pageIndex - 1);
          final sim =
              SpringSimulation(_pageSpring, _offset, 0, -_pageEnterVelocity);
          _nextPageTimer?.cancel();
          _nextPageTimer = Timer(_pageEnterDelay, () {
            _controller.animateWith(sim);
            _nextPageTimer = null;
          });
        }
      }
    }
  }

  void moveToNextPage() {
    if (widget.pageIndex + 1 >= widget.stepCount) {
      return;
    }
    setState(() {
      _animatingPageOut = true;
    });
    final outSim = GravitySimulation(
      _pageExitAcceleration,
      0,
      _pageSwitchDistance,
      _pageEnterVelocity,
    );
    _controller.animateWith(outSim);
  }

  void moveToPreviousPage() {
    if (widget.pageIndex <= 0) {
      return;
    }
    setState(() {
      _animatingPageOut = true;
    });
    final outSim = GravitySimulation(
      -_pageExitAcceleration,
      0,
      _pageSwitchDistance,
      _pageEnterVelocity,
    );
    _controller.animateWith(outSim);
  }

  void moveToPage(int index) {
    if (index > widget.pageIndex) {
      moveToNextPage();
      return;
    }
    if (index < widget.pageIndex) {
      moveToPreviousPage();
      return;
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
  final Animation<double> animation;
  final int index;
  final LarryPageViewState pageView;
  final ScrollController innerScrollController;

  const StepInformation({
    required this.animation,
    required this.index,
    required this.pageView,
    required this.innerScrollController,
  });

  static StepInformation of(BuildContext context) {
    final StepInheritedWidget? widget =
        context.dependOnInheritedWidgetOfExactType<StepInheritedWidget>();
    return widget!.data;
  }
}
