import 'dart:math';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:wiredash/src/measure.dart';

class StepForm extends StatefulWidget {
  const StepForm({
    Key? key,
    this.topOffset = 300,
    required this.builder,
  }) : super(key: key);

  final Widget? Function(int index) builder;

  final double topOffset;

  @override
  State<StepForm> createState() => _StepFormState();
}

class _StepFormState extends State<StepForm> {
  final List<Rect> _sizes = [];

  double _offset = 0;
  int _activeIndex = 0;
  double _centerOffset = 0;

  @override
  void initState() {
    super.initState();
    _offset = widget.topOffset;
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

    Widget? veryTop;
    if (veryTopIndex >= 0) {
      veryTop = widget.builder(veryTopIndex);
    }
    Widget? top;
    if (topIndex >= 0) {
      top = widget.builder(topIndex);
    }
    Widget? center = widget.builder(_activeIndex);
    Widget? bottom = widget.builder(bottomIndex);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTapUp: _onTapUp,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      behavior: HitTestBehavior.translucent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          print("_activeIndex: $_activeIndex");
          final activeHeight = _sizes[_activeIndex].height;

          _centerOffset = () {
            if (activeHeight == 0) {
              // prevent division by zero
              return 0.0;
            }

            final activeIndexOffset = _sizes
                .take(_activeIndex)
                .fold<double>(0, (sum, item) => sum + item.bottom);
            print('activeIndexOffset: $activeIndexOffset');

            return (_offset - widget.topOffset + activeIndexOffset) /
                activeHeight;
          }();
          print("sizes: ${_sizes.map((e) => e.height)}");
          print("centerOffset $_centerOffset");

          final topItemsOutOfView = _sizes
              .take(max(_activeIndex - 1, 0))
              .fold<double>(0, (sum, item) => sum + item.bottom);

          print("topItemsOutOfView $topItemsOutOfView");

          final widgetHeight = constraints.maxHeight;
          final topHeight = widget.topOffset;
          final bottomHeight = widgetHeight - topHeight;

          Widget boxed({required Widget child, required int index}) {
            return KeyedSubtree(
              key: ValueKey(index),
              child: SliverToBoxAdapter(
                child: Container(
                  color: index == _activeIndex
                      ? Colors.green.withAlpha(20)
                      : Colors.transparent,
                  child: MeasureSize(
                    child: child,
                    onChange: (size, rect) {
                      setState(() {
                        _sizes[index] = rect;
                      });
                    },
                  ),
                ),
              ),
            );
          }

          print("_offset $_offset");
          final activeIndexOffset = _sizes
              .take(max(_activeIndex - 2, 0))
              .fold<double>(0, (sum, item) => sum + item.bottom);

          return Viewport(
            offset: ViewportOffset.fixed(-_offset - activeIndexOffset),
            slivers: [
              if (veryTop != null) boxed(child: veryTop, index: veryTopIndex),
              if (top != null) boxed(child: top, index: topIndex),
              if (center != null) boxed(child: center, index: _activeIndex),
              if (bottom != null) boxed(child: bottom, index: bottomIndex),
            ],
          );
        },
      ),
    );
  }

  void _onTapDown(TapDownDetails details) {
    print(details);
  }

  void _onTapCancel() {
    print('cancel');
  }

  void _onTapUp(TapUpDetails details) {
    print(details);
  }

  void _onVerticalDragUpdate(DragUpdateDetails details) {
    // print(details);
    setState(() {
      _offset += details.delta.dy;
      print("_offset: $_offset");
      print("sizes: ${_sizes.map((e) => e.height)}");

      var index = 0;
      double sum = 0;
      while (sum >= _offset) {
        index++;
        sum -= _sizes[index].bottom;
      }
      if (_activeIndex != index) {
        _activeIndex = index;
      }
      // if (_centerOffset < -1) {
      //   // mark next item as active
      //   _activeIndex++;
      //   _centerOffset = 0;
      // }
      // if (_centerOffset > 1 && _activeIndex > 0) {
      //   _activeIndex--;
      //   _centerOffset = 0;
      // }
      // print(_offset);
    });
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

  const StepInformation({
    required this.active,
  });
}

extension _IterableTakeLast<E> on Iterable<E> {
  /// Returns a list containing last [n] elements.
  ///
  /// ```dart
  /// val chars = [1, 2, 3, 4, 5, 6, 7, 8, 9];
  /// print(chars.take(3)) // [1, 2, 3]
  /// print(chars.takeWhile((it) => it < 5) // [1, 2, 3, 4]
  /// print(chars.takeLast(2)) // [8, 9]
  /// print(chars.takeLastWhile((it) => it > 5 }) // [6, 7, 8, 9]
  /// ```
  List<E> takeLast(int n) {
    final list = this is List<E> ? this as List<E> : toList();
    return list.sublist(length - n);
  }
}
