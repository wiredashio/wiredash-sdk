import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/measure.dart';

class LarryPageView extends StatefulWidget {
  const LarryPageView({
    Key? key,
    this.viewPadding = EdgeInsets.zero,
    required this.stepCount,
    required this.builder,
  }) : super(key: key);

  final Widget Function(BuildContext context, int index) builder;

  final int stepCount;
  final EdgeInsets viewPadding;

  @override
  State<LarryPageView> createState() => LarryPageViewState();
}

class LarryPageViewState extends State<LarryPageView>
    with TickerProviderStateMixin<LarryPageView>
    implements ScrollContext {
  late final AnimationController controller;
  int _activeIndex = 0;
  double _offset = 0;

  bool _animToZero = false;

  @override
  void initState() {
    super.initState();
    controller = AnimationController(
      vsync: this,
      lowerBound: -double.infinity,
      upperBound: double.infinity,
    )..addListener(_rebuildOnAutoScroll);
  }

  void _rebuildOnAutoScroll() {
    setState(() {
      _offset = controller.value;
    });

    if (!_animToZero) {
      print("_animToZero = $_animToZero");
      final spring = SpringDescription(mass: 30, stiffness: 1, damping: 1);
      final double switchDistance = 200;
      final delay = Duration(milliseconds: 150);
      final double inVelocity = 3000;
      if (_offset > switchDistance) {
        if (_activeIndex + 1 < widget.stepCount) {
          print("SpringSimulation to 0 (> 200)");
          _activeIndex++;
          _offset = -switchDistance;
          _animToZero = true;
          final sim = SpringSimulation(spring, _offset, 0, inVelocity);
          // TODO cancel on touch...
          Future.delayed(delay).then((value) {
            controller.animateWith(sim);
          });
        }
      } else if (_offset < -switchDistance) {
        if (_activeIndex > 0) {
          print("SpringSimulation to 0 (< -200)");
          _activeIndex--;
          _offset = switchDistance;
          _animToZero = true;
          final sim = SpringSimulation(spring, _offset, 0, -inVelocity);
          // TODO cancel on touch...
          Future.delayed(delay).then((value) {
            controller.animateWith(sim);
          });
        }
      }
    }
  }

  @override
  void dispose() {
    controller.dispose();
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
              widgetHeight - widget.viewPadding.top - widget.viewPadding.bottom;

          Widget boxed({required Widget child, required int index}) {
            const fadeDistance = 160.0;

            final opacity =
                1 - _offset.abs().clamp(0, fadeDistance) / fadeDistance;

            return KeyedSubtree(
              key: ValueKey(index),
              child: StepInheritedWidget(
                data: StepInformation(
                  active: index == _activeIndex,
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
                      child: child,
                    ),
                  ),
                ),
              ),
            );
          }

          Widget child = boxed(
            index: _activeIndex,
            child: Builder(builder: (context) {
              return widget.builder(context, _activeIndex);
            }),
          );

          child = Viewport(
            offset: ViewportOffset.fixed(_offset),
            anchor: widget.viewPadding.top / widgetHeight,
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
    print("velocity: $primaryVelocity ${primaryVelocity < 0 ? "UP" : "DOWN"} ");

    bool jumpToZero = false;

    if (primaryVelocity.abs() > 1000) {
      if (primaryVelocity < 0) {
        // scroll up
        if (_activeIndex + 1 < widget.stepCount) {
          print("anim out top");
          final sim = ClampingScrollSimulation(
              velocity: -primaryVelocity, position: _offset);
          controller.animateWith(sim);
          _animToZero = false;
        } else {
          jumpToZero = true;
        }
      }
      if (primaryVelocity > 0) {
        if (_activeIndex > 0) {
          print("anim out bottom");
          final sim = ClampingScrollSimulation(
              velocity: -primaryVelocity, position: _offset);
          controller.animateWith(sim);
          _animToZero = false;
        } else {
          jumpToZero = true;
        }
      }
    } else {
      // jump back to 0
      jumpToZero = true;
    }

    if (jumpToZero) {
      print("jump to zero");
      _animToZero = true;
      final sim = SpringSimulation(
        SpringDescription(mass: 30, stiffness: 1, damping: 1),
        _offset,
        0,
        -primaryVelocity,
      );
      controller.animateWith(sim);
    }
  }

  void _onVerticalDragStart(DragStartDetails details) {
    controller.stop();
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // Account for finger movement
    setState(() {
      _offset = _offset - details.delta.dy;
    });
  }

  @override
  AxisDirection get axisDirection => AxisDirection.down;

  @override
  BuildContext? get notificationContext => context;

  @override
  void saveOffset(double offset) {
    // no state restauration
  }

  @override
  void setCanDrag(bool value) {
    // don't persist anything
  }

  @override
  void setIgnorePointer(bool value) {
    // don't persist anything
  }

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {
    // don't persist anything
  }

  @override
  BuildContext get storageContext => context;

  @override
  TickerProvider get vsync => this;
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
