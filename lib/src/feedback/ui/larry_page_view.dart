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
  /// The true natural sizes of each item
  final List<Rect> _intrinsicItemSizes = [];

  /// The item size with min height [_minItemHeight]
  final List<Rect> _expandedItemSizes = [];

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
    )..addListener(() {
        setState(() {
          // _offset = ?
          _offset = controller.value;
          print("offset: ${_offset}");

          if (!_animToZero) {
            print("_animToZero = $_animToZero");
            final spring =
                SpringDescription(mass: 30, stiffness: 1, damping: 1);
            if (_offset > 200) {
              if (_activeIndex + 1 < widget.stepCount) {
                print("SpringSimulation to 0 (> 200)");
                _activeIndex++;
                _offset = -400;
                _animToZero = true;
                final sim =
                    SpringSimulation(spring, _offset, 0, controller.velocity);
                controller.animateWith(sim);
              }
            } else if (_offset < -200) {
              if (_activeIndex > 0) {
                print("SpringSimulation to 0 (< -200)");
                _activeIndex--;
                _offset = 400;
                _animToZero = true;
                final sim =
                    SpringSimulation(spring, _offset, 0, controller.velocity);
                controller.animateWith(sim);
              }
            }
          }
        });
      });
  }

  void _rebuild() {
    setState(() {
      // continuously update the viewport offset when the scroll position changes
    });
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
            final activePos = _positionForIndex(_activeIndex);
            final indexPos = _positionForIndex(index);
            final indexOffset = indexPos - activePos;
            // print(
            //     "#$index${index == _activeIndex ? "A" : ""} $indexOffset = $indexPos - $activePos");

            final double distanceToCenterTop = _offset - indexOffset;

            final intrinsicItemHeight = () {
              if (distanceToCenterTop < 0) {
                return 0;
              }
              if (_intrinsicItemSizes.length - 1 < index) {
                return 0;
              }
              return _intrinsicItemSizes[index].bottom;
            }();
            const fadeDistance = 200.0;
            final double distanceToCenterBottom =
                distanceToCenterTop - intrinsicItemHeight + fadeDistance;

            final opacity = 1 - _offset.abs().clamp(0, 200) / 200.0;

            return KeyedSubtree(
              key: ValueKey(index),
              child: Container(
                // color: kDebugMode && _activeIndex == index
                //     ? Colors.green.withAlpha(20)
                //     : Colors.transparent,
                child: StepInheritedWidget(
                  data: StepInformation(
                    active: index == _activeIndex,
                    animation: AlwaysStoppedAnimation<double>(opacity),
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
                      child: Opacity(
                        opacity: opacity,
                        child: MeasureSize(
                          child: child,
                          onChange: (size, rect) {
                            setState(() {
                              final missingRects =
                                  index + 1 - _intrinsicItemSizes.length;
                              if (missingRects > 0) {
                                _intrinsicItemSizes.addAll(Iterable.generate(
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
    final scrollOffsetY = _offset;
    final activeHeight = _expandedItemSizes[_activeIndex].bottom;
    final intrinsicActiveHeight = _intrinsicItemSizes[_activeIndex].bottom;
    // print(
    //     "START: ${scrollOffsetY} (${scrollOffsetY + activePosition}), top: $activePosition");
    print(
        "prev: ${prevPosition}, active: ${activePosition} ($intrinsicActiveHeight/$activeHeight), next: ${nextPosition}");

    final primaryVelocity = details.primaryVelocity!;
    print("velocity: $primaryVelocity ${primaryVelocity < 0 ? "UP" : "DOWN"} ");

    Duration scrollDuration = Duration(milliseconds: 600);
    // final double? simulatedY = () {
    //   try {
    //     final sim = scrollPosition.physics
    //         .createBallisticSimulation(scrollPosition, -primaryVelocity);
    //     // print("x0.1: ${sim?.x(0.1)}");
    //     // print("x0.2: ${sim?.x(0.2)}");
    //     // print("x0.3: ${sim?.x(0.3)}");
    //     // print("x0.4: ${sim?.x(0.4)}");
    //     // print("x1: ${sim?.x(1)}");
    //     // print("x1000: ${sim?.x(1000)}");
    //     // print("x100000: ${sim?.x(100000)}");
    //
    //     for (int i = 0; i < 15; i++) {
    //       final t = 0.1 * pow(1.3, i);
    //       final done = sim?.isDone(t);
    //       print("$i $t $done");
    //       if (done == null) {
    //         break;
    //       }
    //       if (done) {
    //         final ms = (t * 1000).toInt();
    //         scrollDuration = Duration(milliseconds: ms);
    //         print("$scrollDuration ");
    //         break;
    //       }
    //     }
    //
    //     final x = sim?.x(scrollDuration.inMilliseconds / 1000);
    //
    //     // null == idle
    //     return x;
    //   } catch (e, stack) {
    //     print(e);
    //     print(stack);
    //     return null;
    //   }
    // }();

    // print("simulatedY: $simulatedY");

    bool jumpToNext = false;
    bool jumpToPrev = false;
    bool jumpToCurrentTop = false;

    if (primaryVelocity.abs() > 1000) {
      if (primaryVelocity < 0) {
        // scroll up
        jumpToNext = true;
        if (_activeIndex + 1 < widget.stepCount) {
          print("anim out top");
          final sim = ClampingScrollSimulation(
              velocity: -primaryVelocity, position: _offset);
          controller.animateWith(sim);
          _animToZero = false;
        }
      }
      if (primaryVelocity > 0) {
        jumpToPrev = true;
        if (_activeIndex > 0) {
          print("anim out bottom");
          final sim = ClampingScrollSimulation(
              velocity: -primaryVelocity, position: _offset);
          controller.animateWith(sim);
          _animToZero = false;
        }
      }
    } else {
      // jump back to 0
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

    // if (primaryVelocity == 0) {
    //   if (scrollOffsetY < 0) {
    //     // currently at top of active item. Not matter what, never jump to next item.
    //     // At this point it's only possible to go back to the current or up to
    //     // the previous item. Since an up scroll is detected, always jump back to current.
    //     jumpToCurrentTop = true;
    //     print("jumpToCurrentTop");
    //   }
    // } else if (primaryVelocity < 0) {
    //   // scroll up
    //   if (_activeIndex + 1 < widget.stepCount) {
    //     final nextItemTop = _positionForIndex(_activeIndex + 1);
    //     print(
    //         "UP top: $activePosition, next: $nextItemTop, y: ${scrollOffsetY}");
    //     print(
    //         "$simulatedY > $intrinsicActiveHeight = ${simulatedY != null && simulatedY > intrinsicActiveHeight}");
    //     if (scrollOffsetY < 0) {
    //       // currently at top of active item. Not matter what, never jump to next item.
    //       // At this point it's only possible to go back to the current or up to
    //       // the previous item. Since an up scroll is detected, always jump back to current.
    //       jumpToCurrentTop = true;
    //       print("jumpToCurrentTop up gesture");
    //     } else if (simulatedY != null && simulatedY > intrinsicActiveHeight) {
    //       jumpToNext = true;
    //       setState(() {
    //         _activeIndex = _activeIndex + 1;
    //       });
    //       print("jumpToNext $_activeIndex");
    //     }
    //   }
    // } else if (primaryVelocity > 0) {
    //   // scroll down
    //   print("_dragStartScrollPosition $_dragStartScrollPosition");
    //
    //   if (_activeIndex > 0) {
    //     final prevItemTop = _positionForIndex(_activeIndex - 1);
    //     print(
    //         "DOWN top: $activePosition, prev: $prevItemTop, y: ${scrollOffsetY}");
    //     if (_dragStartScrollPosition == activeHeight) {
    //       // last item, at bottom, jump back to top
    //       jumpToCurrentTop = true;
    //     } else if (simulatedY != null && simulatedY < 0) {
    //       jumpToPrev = true;
    //       print("jumpToPrev");
    //       setState(() {
    //         _activeIndex = _activeIndex - 1;
    //       });
    //     }
    //   }
    // }

    // if (primaryVelocity < -300) {
    //   _activeIndex = min(widget.stepCount - 1, _activeIndex + 1);
    // } else if (primaryVelocity > 300) {
    //   _activeIndex = max(0, _activeIndex - 1);
    // }

    final newTopItemsHeight = _calculateTopItemsHeight();
    final diff = activePosition - newTopItemsHeight;
    setState(() {
      _offset = _offset + diff;
    });

    // if (jumpToPrev || jumpToNext || jumpToCurrentTop) {
    //   print("END: 0 (index change $_activeIndex)");
    //   // scrollPosition.animateTo(
    //   //   0,
    //   //   duration: Duration(milliseconds: 800),
    //   //   curve: Curves.easeOut,
    //   // );
    // } else if (simulatedY != null) {
    //   final end = simulatedY;
    //   print("END: $end");
    //   // scrollPosition.animateTo(
    //   //   end,
    //   //   duration: scrollDuration,
    //   //   curve: Curves.easeOut,
    //   // );
    // } else {
    //   print("No end scroll");
    // }
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

    _offset = _offset + diff;

    try {
      // final sim = scrollPosition.physics
      //     .createBallisticSimulation(scrollPosition, velocity);
      // null == idle
      // final x = sim?.x(double.infinity);
      // print("Sim $x");
    } catch (e, stack) {
      print(e);
      print(stack);
    }

    // TODO account for velocity, only eventually move to next item, allow
    //  scrolling in the current item (i.e. when the summery gets long)
    // scrollPosition.animateTo(
    //   0,
    //   duration: const Duration(milliseconds: 800),
    //   curve: Curves.easeOutQuad,
    // );
  }

  double _dragStartScrollPosition = 0.0;
  void _onVerticalDragStart(DragStartDetails details) {
    controller.stop();
    _dragStartScrollPosition = _offset;
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    final oldTopItemsHeight = _calculateTopItemsHeight();

    // Account for finger movement
    _offset = _offset - details.delta.dy;

    if (_offset < 0) {
      _activeIndex = max(0, _activeIndex);
    }
    if (_offset > 0) {
      final nextIndex = _activeIndex + 1;
      print("nextIndex $nextIndex, ${widget.stepCount}");
      if (nextIndex < widget.stepCount) {
        final next = _positionForIndex(nextIndex);
        print("next: $next, offset $_offset");
        if (_offset + oldTopItemsHeight > next) {
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
    setState(() {
      _offset = _offset + diff;
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
