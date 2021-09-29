import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/measure.dart';

class StepForm extends StatefulWidget {
  const StepForm({
    Key? key,
    this.topOffset = 240,
    required this.builder,
  }) : super(key: key);

  final Widget? Function(int index) builder;

  final double topOffset;

  @override
  State<StepForm> createState() => _StepFormState();
}

class _StepFormState extends State<StepForm>
    with TickerProviderStateMixin<StepForm>
    implements ScrollContext {
  final List<Rect> _sizes = [];

  late final ScrollController controller;
  late final ViewportOffset vpOffset;
  // double _offset = 0;
  int _activeIndex = 0;
  double _centerOffset = 0;

  double _line2 = 0.0;

  List<Widget> children = [];

  @override
  void initState() {
    super.initState();
    // _offset = widget.topOffset;
    controller = ScrollController(initialScrollOffset: -widget.topOffset);
    vpOffset =
        controller.createScrollPosition(BouncingScrollPhysics(), this, null);
    vpOffset.addListener(() {
      setState(() {
        // print("vpOffset $vpOffset");
      });
    });
    // vpOffset.correctBy(-widget.topOffset);
  }

  @override
  void didUpdateWidget(covariant StepForm oldWidget) {
    if (widget.topOffset != oldWidget.topOffset) {
      // _offset = _offset - oldWidget.topOffset + widget.topOffset;
      // vpOffset.jumpTo(vpOffset.pixels + oldWidget.topOffset - widget.topOffset);
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  Widget build(BuildContext context) {
    int? veryTopIndex = _activeIndex - 2;
    int? topIndex = _activeIndex - 1;
    int bottomIndex = _activeIndex + 1;
    final missingRects = bottomIndex + 1 - _sizes.length;
    if (missingRects > 0) {
      _sizes.addAll(Iterable.generate(missingRects, (_) => Rect.zero));
    }

    // Widget? veryTop;
    // if (veryTopIndex >= 0) {
    //   veryTop = widget.builder(veryTopIndex);
    // }
    // Widget? top;
    // if (topIndex >= 0) {
    //   top = widget.builder(topIndex);
    // }
    // Widget? center = widget.builder(_activeIndex);
    // Widget? bottom = widget.builder(bottomIndex);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTapUp: _onTapUp,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      onVerticalDragEnd: _onVerticalDragEnd,
      behavior: HitTestBehavior.translucent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          print("_activeIndex: $_activeIndex");
          // print("sizes: ${_sizes.map((e) => e.height)}");

          final activeIndexOffset = _sizes
              .take(_activeIndex)
              .fold<double>(0, (sum, item) => sum + item.bottom);
          final activeHeight = _sizes[_activeIndex].height;
          // print(
          //     "activeIndexOffset $activeIndexOffset, activeHeight $activeHeight");

          // _centerOffset = () {
          //   if (activeHeight == 0) {
          //     // prevent division by zero
          //     return 0.0;
          //   }
          //   return (_offset - widget.topOffset + activeIndexOffset) /
          //       activeHeight;
          // }();

          // final activeOffset = _offset - widget.topOffset + activeIndexOffset;

          // print("offset $_offset");
          // final topItemsOutOfView = _sizes
          //     .take(max(_activeIndex - 1, 0))
          //     .fold<double>(0, (sum, item) => sum + item.bottom);

          // print("topItemsOutOfView $topItemsOutOfView");

          final widgetHeight = constraints.maxHeight;
          final topHeight = widget.topOffset;
          final bottomHeight = widgetHeight - topHeight;

          Widget boxed({required Widget child, required int index}) {
            final topHeight = _sizes
                .take(index)
                .fold<double>(0, (sum, item) => sum + item.bottom);

            final double distanceToTopPosition =
                vpOffset.pixels + topHeight - widget.topOffset;
            // print("#${index} $distanceToTopPosition ="
            //     " $_offset + $topHeight - ${widget.topOffset}");

            final double animValue = () {
              return 1.0 -
                  max(0.0, min(1.0, (distanceToTopPosition / 100.0).abs()));
            }();

            // print("anim #$index: $animValue");

            return KeyedSubtree(
              key: ValueKey(index),
              child: SliverToBoxAdapter(
                child: StepInheritedWidget(
                  data: StepInformation(
                    active: index == _activeIndex,
                    animation: animValue != null
                        ? AlwaysStoppedAnimation<double>(animValue.abs())
                        : AlwaysStoppedAnimation(1),
                  ),
                  child: Container(
                    color: index == _activeIndex
                        ? Colors.green.withAlpha(20)
                        : Colors.transparent,
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
                          if (index == 2) {
                            print("size changed to $size");
                          }
                        });
                      },
                    ),
                  ),
                ),
              ),
            );
          }

          // print("_offset $_offset");
          final topItemsHeight = _sizes
              .take(max(_activeIndex, 0))
              .fold<double>(0, (sum, item) => sum + item.bottom);

          Iterable<Widget> buildChildren() sync* {
            Widget? last;
            int index = 0;
            do {
              last = widget.builder(index);
              if (last != null) {
                yield boxed(child: last, index: index);
                index++;
              }
            } while (last != null);

            // add one last item at the bottom
            yield SliverToBoxAdapter(
              key: ValueKey(index),
              child: Container(
                color: Colors.yellow,
                height: widgetHeight / 2,
              ),
            );
          }

          children = buildChildren().toList();
          // print("topItemsHeight $topItemsHeight");
          // final vpoffset = ViewportOffset.fixed(
          //     -_offset - topItemsHeight + widget.topOffset);
          // print(vpoffset);
          return Stack(
            children: [
              Viewport(
                offset: vpOffset,
                anchor: 0.26,
                center: ValueKey(_activeIndex),
                slivers: children,
              ),
              Positioned(
                top: widget.topOffset,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.black,
                ),
              ),
              Positioned(
                top: _line2,
                left: 0,
                right: 0,
                child: Container(
                  height: 1,
                  color: Colors.red,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    // print(details);
  }

  void _onTapCancel() {
    // print('cancel');
  }

  void _onTapUp(TapUpDetails details) {
    // print(details);

    final topItemsHeight = _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);

    // vpOffset.animateTo(
    //   topItemsHeight,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.easeOutExpo,
    // );
  }

  double positionForIndex(int index) {
    return _sizes
        .take(max(index, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);
  }

  void _onVerticalDragEnd(DragEndDetails details) {
    // print(details);
    print(
        Iterable.generate(_sizes.length, (i) => positionForIndex(i)).toList());

    final topItemsHeight = positionForIndex(_activeIndex);

    print(
        "animate from ${vpOffset.pixels} to ${-topItemsHeight - widget.topOffset}");
    // vpOffset.animateTo(
    //   -topItemsHeight - widget.topOffset,
    //   duration: Duration(milliseconds: 500),
    //   curve: Curves.easeOutExpo,
    // );
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // print(details);
    final oldTopItemsHeight = _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);

    vpOffset.jumpTo(vpOffset.pixels - details.delta.dy);
    print('vpOffset.pixels: ${vpOffset.pixels}');
    // controller.position;
    // _offset += details.delta.dy;
    // print("_offset: $_offset");
    print("vpOffset: $vpOffset");
    print("sizes: ${_sizes.map((e) => e.height)}");

    var index = 0;
    final activeHeight = _sizes[_activeIndex].bottom;
    final offset = vpOffset.pixels;
    if (offset < 0) {
      _activeIndex = max(0, _activeIndex - 1);
    }
    if (offset > activeHeight) {
      _activeIndex = min(children.length - 1, _activeIndex + 1);
    }

    final pos = positionForIndex(_activeIndex);
    // _line2 = pos;

    print("breakpoint #$_activeIndex: ${pos}");
    // _activeIndex = min(index, children.length - 1);
    // print("Next index = $_activeIndex");

    final newTopItemsHeight = _sizes
        .take(max(_activeIndex, 0))
        .fold<double>(0, (sum, item) => sum + item.bottom);

    final diff = oldTopItemsHeight - newTopItemsHeight;
    print("jump 1 item ($diff)");

    vpOffset.jumpTo(vpOffset.pixels + diff);
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
    // TODO
  }

  @override
  void setIgnorePointer(bool value) {
    // TODO
  }

  @override
  void setSemanticsActions(Set<SemanticsAction> actions) {
    // TODO
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
