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
          final activeHeight = _sizes[_activeIndex].height;

          _centerOffset = () {
            if (activeHeight == 0) {
              // prevent division by zero
              return 0.0;
            }
            final activeIndexOffset = _sizes
                .take(_activeIndex)
                .fold<double>(0, (sum, item) => sum + item.bottom);

            return (_offset - widget.topOffset + activeIndexOffset) /
                activeHeight;
          }();
          print("centerOffset $_centerOffset");

          final widgetHeight = constraints.maxHeight;
          final topHeight = widget.topOffset;
          final bottomHeight = widgetHeight - topHeight;

          Widget boxed({required Widget child, required int index}) {
            return KeyedSubtree(
              key: ValueKey(index),
              child: SliverToBoxAdapter(
                child: MeasureSize(
                  child: child,
                  onChange: (size, rect) {
                    setState(() {
                      _sizes[index] = rect;
                    });
                  },
                ),
              ),
            );
          }

          return Viewport(
            offset: ViewportOffset.fixed(-_offset),
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
      if (_centerOffset < -1) {
        // mark next item as active
        _activeIndex++;
        _centerOffset = 0;
      }
      if (_centerOffset > 1 && _activeIndex > 0) {
        _activeIndex--;
        _centerOffset = 0;
      }
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
