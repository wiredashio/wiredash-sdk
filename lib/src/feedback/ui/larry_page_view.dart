import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/measure.dart';

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

  double get _childOffset => _childScrollController.position.pixels;

  late ScrollController _childScrollController;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      value: 0,
      lowerBound: -double.maxFinite,
      upperBound: double.maxFinite,
    )..addListener(_onOffsetChanged);
    _childScrollController = ScrollController();
  }

  @override
  void dispose() {
    _controller.dispose();
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
                    child: SingleChildScrollView(
                      controller: _childScrollController,
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          }

          Widget child = boxed(
            index: _page,
            child: Builder(builder: (context) {
              return widget.builder(context, _page);
            }),
          );

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

  void _onVerticalDragEnd(DragEndDetails details) {
    final primaryVelocity = details.primaryVelocity!;
    print("child scroll offset: $_childOffset");
    print("velocity: $primaryVelocity ${primaryVelocity < 0 ? "UP" : "DOWN"} ");

    bool jumpToZero = false;

    if (primaryVelocity.abs() > 1000) {
      if (primaryVelocity < 0) {
        // scroll up
        if (_page + 1 < widget.stepCount) {
          print("anim out top");
          final sim = FrictionSimulation(1, -primaryVelocity, _offset);
          _controller.animateWith(sim);
          _animatingPageOut = true;
        } else {
          jumpToZero = true;
        }
      }
      if (primaryVelocity > 0) {
        if (_page > 0) {
          print("anim out bottom");
          final sim = ClampingScrollSimulation(
              velocity: -primaryVelocity, position: _offset);
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
        SpringDescription(mass: 30, stiffness: 1, damping: 1),
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
      final spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
      final delay = Duration(milliseconds: 150);
      final double inVelocity = 3000;
      if (_offset > _switchDistance) {
        if (_page + 1 < widget.stepCount) {
          print("SpringSimulation to 0 (> 200)");
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
          print("SpringSimulation to 0 (< -200)");
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

extension _IterableTakeLast<E> on Iterable<E> {
  List<E> takeLast(int n) {
    final list = this is List<E> ? this as List<E> : toList();
    return list.sublist(length - n);
  }
}
