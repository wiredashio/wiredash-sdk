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

          final centerOffset = () {
            if (activeHeight == 0) {
              // prevent division by zero
              return 0.0;
            }
            return (_offset - widget.topOffset) / activeHeight;
          }();
          print("centerOffset $centerOffset");

          final widgetHeight = constraints.maxHeight;
          final topHeight = widget.topOffset;
          final bottomHeight = widgetHeight - topHeight;

          return Viewport(
            offset: ViewportOffset.fixed(-_offset),
            slivers: [
              if (veryTop != null) SliverToBoxAdapter(child: veryTop),
              if (top != null) SliverToBoxAdapter(child: top),
              if (center != null)
                SliverToBoxAdapter(
                    child: MeasureSize(
                  child: Container(
                    child: center,
                    color: Colors.green,
                  ),
                  onChange: (size, rect) {
                    setState(() {
                      _sizes[_activeIndex] = rect;
                      print("center height: ${rect.height}");
                    });
                  },
                )),
              if (bottom != null)
                SliverToBoxAdapter(
                  child: MeasureSize(
                    child: bottom,
                    onChange: (size, rect) {
                      setState(() {
                        _sizes[bottomIndex] = rect;
                        print("bottom height: ${rect.height}");
                      });
                    },
                  ),
                ),
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
