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
  /// The true natural sizes of each item
  final List<Rect> _intrinsicItemSizes = [];

  /// The item size with min height [_minItemHeight]
  final List<Rect> _expandedItemSizes = [];

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
          final _minItemHeight = widgetHeight - widget.topOffset;

          Widget boxed({required Widget child, required int index}) {
            final activePos = _positionForIndex(_activeIndex);
            final indexPos = _positionForIndex(index);
            final indexOffset = indexPos - activePos;
            // print(
            //     "#$index${index == _activeIndex ? "A" : ""} $indexOffset = $indexPos - $activePos");

            final double distanceToCenterTop =
                scrollPosition.pixels - indexOffset;
            final double animValue = () {
              return 1.0 -
                  max(0.0, min(1.0, (distanceToCenterTop / 200.0).abs()));
            }();

            double alignAtBottomY = 0;
            if (distanceToCenterTop > 0) {
              // scrolled beyond distanceToCenterTop, item should align to bottom
              // alignAtBottomY = distanceToCenterTop / 2;
              final actualItemHeight = _intrinsicItemSizes[index].bottom;
              final floatingSpace = _minItemHeight - actualItemHeight;

              if (distanceToCenterTop < actualItemHeight) {
                // just scroll
              } else {
                alignAtBottomY = distanceToCenterTop - actualItemHeight;
                if (distanceToCenterTop > _minItemHeight) {
                  alignAtBottomY -= distanceToCenterTop - _minItemHeight;
                }
              }
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
                    child: MeasureSize(
                      onChange: (size, rect) {
                        setState(() {
                          final missingRects =
                              index + 1 - _expandedItemSizes.length;
                          if (missingRects > 0) {
                            _expandedItemSizes.addAll(Iterable.generate(
                                missingRects, (_) => Rect.zero));
                          }
                          _expandedItemSizes[index] = rect;
                        });
                      },
                      child: ConstrainedBox(
                        constraints: BoxConstraints(minHeight: _minItemHeight),
                        child: Transform.translate(
                          offset: Offset(0, alignAtBottomY),
                          child: Align(
                            alignment: Alignment.topCenter,
                            child: MeasureSize(
                              child: child,
                              onChange: (size, rect) {
                                setState(() {
                                  final missingRects =
                                      index + 1 - _intrinsicItemSizes.length;
                                  if (missingRects > 0) {
                                    _intrinsicItemSizes.addAll(
                                        Iterable.generate(
                                            missingRects, (_) => Rect.zero));
                                  }
                                  _intrinsicItemSizes[index] = rect;
                                });
                              },
                            ),
                          ),
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

  void _onVerticalDragEnd(DragEndDetails details) {
    final prevPosition = _positionForIndex(_activeIndex - 1);
    final activePosition = _positionForIndex(_activeIndex);
    final nextPosition = _positionForIndex(_activeIndex + 1);
    final scrollOffsetY = scrollPosition.pixels;
    final activeHeight = _expandedItemSizes[_activeIndex].bottom;
    final intrinsicHeight = _intrinsicItemSizes[_activeIndex].bottom;
    print(
        "START: ${scrollOffsetY} (${scrollOffsetY + activePosition}), top: $activePosition");
    print(
        "prev: ${prevPosition}, active: ${activePosition} ($intrinsicHeight/$activeHeight), next: ${nextPosition}");

    final primaryVelocity = details.primaryVelocity!;
    print("velocity: $primaryVelocity ${primaryVelocity < 0 ? "UP" : "DOWN"} ");

    final double scrollTo = () {
      try {
        final sim = scrollPosition.physics
            .createBallisticSimulation(scrollPosition, -primaryVelocity);
        // print("x0.1: ${sim?.x(0.1)}");
        // print("x0.2: ${sim?.x(0.2)}");
        // print("x0.3: ${sim?.x(0.3)}");
        // print("x0.4: ${sim?.x(0.4)}");
        // print("x1: ${sim?.x(1)}");
        // print("x1000: ${sim?.x(1000)}");
        // print("x100000: ${sim?.x(100000)}");

        // 0.4s
        final x = sim?.x(0.4);

        // null == idle
        return x ?? 0.0;
      } catch (e, stack) {
        print(e);
        print(stack);
      }
      return 0.0;
    }();

    final simulatedY = scrollTo;
    print("simulatedY: ${simulatedY} ($simulatedY)");

    bool jumpToNext = false;
    bool jumpToPrev = false;
    if (primaryVelocity < 0) {
      // scroll up
      if (_activeIndex + 1 < widget.stepCount) {
        final nextItemTop = _positionForIndex(_activeIndex + 1);
        print(
            "UP top: $activePosition, next: $nextItemTop, y: ${scrollOffsetY}");
        if (simulatedY > intrinsicHeight) {
          jumpToNext = true;
          setState(() {
            _activeIndex = _activeIndex + 1;
          });
        }
      }
    } else if (primaryVelocity > 0) {
      // scroll down
      if (_activeIndex > 0) {
        final prevItemTop = _positionForIndex(_activeIndex - 1);
        print(
            "DOWN top: $activePosition, prev: $prevItemTop, y: ${scrollOffsetY}");
        if (simulatedY < 0) {
          jumpToPrev = true;
          setState(() {
            _activeIndex = _activeIndex - 1;
          });
        }
      }
    }

    // if (primaryVelocity < -300) {
    //   _activeIndex = min(widget.stepCount - 1, _activeIndex + 1);
    // } else if (primaryVelocity > 300) {
    //   _activeIndex = max(0, _activeIndex - 1);
    // }

    final newTopItemsHeight = _calculateTopItemsHeight();
    final diff = activePosition - newTopItemsHeight;
    scrollPosition.jumpTo(scrollPosition.pixels + diff);

    if (jumpToPrev || jumpToNext) {
      print("END: 0 (index change $_activeIndex)");
      scrollPosition.animateTo(
        0,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeOutExpo,
      );
    } else {
      final end = simulatedY;
      print("END: $end");
      scrollPosition.animateTo(
        end,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOutExpo,
      );
    }
  }

  double _calculateTopItemsHeight() => _positionForIndex(_activeIndex);

  double _positionForIndex(int index) {
    return _expandedItemSizes
        .take(max(index, 0))
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
      final x = sim?.x(double.infinity);
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
    final oldTopItemsHeight = _calculateTopItemsHeight();
    print("top: ${oldTopItemsHeight}");

    // Account for finger movement
    scrollPosition.jumpTo(scrollPosition.pixels - details.delta.dy);

    final offset = scrollPosition.pixels;
    if (offset < 0) {
      _activeIndex = max(0, _activeIndex);
    }
    if (offset > 0) {
      final nextIndex = _activeIndex + 1;
      print("nextIndex $nextIndex, ${widget.stepCount}");
      if (nextIndex < widget.stepCount) {
        final next = _positionForIndex(nextIndex);
        print("next: $next, offset $offset");
        if (offset + oldTopItemsHeight > next) {
          _activeIndex = min(widget.stepCount - 1, nextIndex);
        }
      }
    }

    final newTopItemsHeight = _calculateTopItemsHeight();

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
