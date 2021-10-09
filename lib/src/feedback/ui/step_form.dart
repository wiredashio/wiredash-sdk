import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/measure.dart';

class StepForm extends StatefulWidget {
  const StepForm({
    Key? key,
    this.topOffset = 240,
    required this.stepCount,
    required this.builder,
  }) : super(key: key);

  final Widget Function(int index) builder;

  final int stepCount;
  final double topOffset;

  @override
  State<StepForm> createState() => StepFormState();
}

class StepFormState extends State<StepForm>
    with TickerProviderStateMixin<StepForm>
    implements ScrollContext {
  final List<Rect> _sizes = [];

  late final ScrollController controller;
  late final ScrollPosition scrollPosition;
  int _activeIndex = 0;

  @override
  void initState() {
    super.initState();
    controller = ScrollController(initialScrollOffset: -widget.topOffset);
    scrollPosition = controller.createScrollPosition(
        const BouncingScrollPhysics(), this, null);
    scrollPosition.addListener(() {
      setState(() {
        // continuously update the viewport offset when the scroll position changes
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.opaque,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widgetHeight = constraints.maxHeight;
          final itemHeight = widgetHeight - widget.topOffset;

          Widget boxed({required Widget child, required int index}) {
            final topHeight = index <= _activeIndex
                ? 0
                : _sizes
                    .skip(max(0, index - 1))
                    .take(1)
                    .fold<double>(0, (sum, item) => sum + item.bottom);

            final double distanceToCenterTop =
                scrollPosition.pixels - topHeight;

            if (index < 2) {
              print(
                  "#$index $distanceToCenterTop = ${scrollPosition.pixels} + $topHeight");
            }
            final double animValue = () {
              return 1.0 -
                  max(0.0, min(1.0, (distanceToCenterTop / 200.0).abs()));
            }();

            // print("anim #$index: $animValue");
            double alignAtBottomY = 0;
            if (distanceToCenterTop > 0) {
              // scrolled beyond distanceToCenterTop, item should align to bottom
              // alignAtBottomY = distanceToCenterTop / 2;
            }

            return KeyedSubtree(
              key: ValueKey(index),
              child: SliverToBoxAdapter(
                child: Container(
                  color: _activeIndex == index
                      ? Colors.green.withAlpha(20)
                      : Colors.transparent,
                  child: StepInheritedWidget(
                    data: StepInformation(
                      active: index == _activeIndex,
                      animation: animValue != null
                          ? AlwaysStoppedAnimation<double>(animValue.abs())
                          : const AlwaysStoppedAnimation(1),
                    ),
                    child: Container(
                      // alignment: Alignment.lerp(
                      //     Alignment.topCenter,
                      //     Alignment.bottomCenter,
                      //     -distanceToCenterTop.clamp(0.0, 100.0) / 100),
                      constraints: BoxConstraints(minHeight: itemHeight),
                      // duration: const Duration(milliseconds: 200),
                      // curve: Curves.easeInOutCubic,
                      child: Transform.translate(
                        offset: Offset(0, alignAtBottomY),
                        child: MeasureSize(
                          child: child,
                          onChange: (size, rect) {
                            setState(() {
                              final missingRects = index + 1 - _sizes.length;
                              if (missingRects > 0) {
                                _sizes.addAll(Iterable.generate(
                                    missingRects, (_) => Rect.zero));
                              }
                              _sizes[index] = rect;
                            });
                          },
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            );
          }

          Iterable<Widget> buildChildren() sync* {
            Widget? last;
            int index = 0;
            while (index < widget.stepCount) {
              last = widget.builder(index);
              if (last != null) {
                yield boxed(child: last, index: index);
                index++;
              }
            }

            // add one last item at the bottom
            yield boxed(
              index: index,
              child: Container(
                color: Colors.transparent,
                height: widgetHeight / 2,
              ),
            );
          }

          final children = buildChildren().toList();

          return Viewport(
            offset: scrollPosition,
            anchor: widget.topOffset / widgetHeight,
            center: ValueKey(_activeIndex),
            slivers: children,
          );
        },
      ),
    );
  }

  void moveToNextPage() {
    if (_activeIndex < widget.stepCount) {
      setState(() {
        final oldTopItemsHeight = _calculateTopItemsHeight();
        _activeIndex++;
        _animateToNextPage(oldTopItemsHeight, 305);
      });
    }
  }

  double _positionForIndex(int index) {
    return _sizes
        .take(max(index, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    final oldTopItemsHeight = _calculateTopItemsHeight();

    final primaryVelocity = details.primaryVelocity!;
    if (primaryVelocity < -300) {
      _activeIndex = min(widget.stepCount - 1, _activeIndex + 1);
    } else if (primaryVelocity > 300) {
      _activeIndex = max(0, _activeIndex - 1);
    }

    _animateToNextPage(oldTopItemsHeight, primaryVelocity);
  }

  double _calculateTopItemsHeight() {
    return _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);
  }

  void _animateToNextPage(double oldTopItemsHeight, double velocity) {
    final newTopItemsHeight = _calculateTopItemsHeight();

    final diff = oldTopItemsHeight - newTopItemsHeight;

    scrollPosition.jumpTo(scrollPosition.pixels + diff);

    try {
      final sim = scrollPosition.physics
          .createBallisticSimulation(scrollPosition, velocity);
      // null == idle
      final x = sim?.x(1000);
      print("Sim $x");
    } catch (e, stack) {
      print(e);
      print(stack);
    }

    // TODO account for velocity, only eventually move to next item, allow
    //  scrolling in the current item (i.e. when the summery gets long)
    scrollPosition.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeOutExpo,
    );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final oldTopItemsHeight = _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);

    // Account for finger movement
    scrollPosition.jumpTo(scrollPosition.pixels - details.delta.dy);

    final activeHeight = _sizes[_activeIndex].bottom;
    final offset = scrollPosition.pixels;
    if (offset < 0) {
      _activeIndex = max(0, _activeIndex);
    }
    if (offset > activeHeight) {
      _activeIndex = min(widget.stepCount - 1, _activeIndex + 1);
    }

    final newTopItemsHeight = _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);

    var diff = oldTopItemsHeight - newTopItemsHeight;
    if (diff > 0) {
      // diff -= _activeItemHeight;
    }
    if (diff < 0) {
      // diff += _activeItemHeight;
    }

    // keep scroll position now that the _activeIndex, and the center item of the Viewport changed
    scrollPosition.jumpTo(scrollPosition.pixels + diff);
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
