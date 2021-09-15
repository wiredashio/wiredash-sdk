import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

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
  double _offset = 0;
  int _activeIndex = 0;

  @override
  Widget build(BuildContext context) {
    int? veryTopIndex = _activeIndex - 2;
    int? topIndex = _activeIndex - 1;
    int nextIndex = _activeIndex + 1;

    Widget? veryTop;
    if (veryTopIndex >= 0) {
      veryTop = widget.builder(veryTopIndex);
    }
    Widget? top;
    if (topIndex >= 0) {
      top = widget.builder(topIndex);
    }
    Widget? center = widget.builder(_activeIndex);
    Widget? bottom = widget.builder(nextIndex);

    return GestureDetector(
      onTapDown: _onTapDown,
      onTapCancel: _onTapCancel,
      onTapUp: _onTapUp,
      onVerticalDragUpdate: _onVerticalDragUpdate,
      behavior: HitTestBehavior.translucent,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final widgetHeight = constraints.maxHeight;
          final topHeight = widget.topOffset;
          final bottomHeight = widgetHeight - topHeight;

          final veryTopRect =
              Rect.fromLTWH(0, -topHeight, constraints.maxWidth, topHeight);
          final topRect = Rect.fromLTWH(0, 0, constraints.maxWidth, topHeight);
          final centerRect =
              Rect.fromLTWH(0, topHeight, constraints.maxWidth, bottomHeight);
          final bottomRect = Rect.fromLTWH(
              0, widgetHeight, constraints.maxWidth, bottomHeight);

          final centerRectLerp = Rect.lerp(centerRect, topRect, 0)!;

          return Stack(
            children: [
              if (veryTop != null)
                Positioned.fromRect(
                  rect: veryTopRect,
                  child: Transform.translate(
                    offset: Offset(0, _offset),
                    child: Container(
                      color: Colors.green,
                      child: veryTop,
                    ),
                  ),
                ),
              if (top != null)
                Positioned.fromRect(
                  rect: topRect,
                  child: Transform.translate(
                    offset: Offset(0, _offset),
                    child: Container(
                      color: Colors.yellow,
                      child: top,
                    ),
                  ),
                ),
              if (center != null)
                Positioned.fromRect(
                  rect: centerRectLerp,
                  child: Transform.translate(
                    offset: Offset(0, _offset),
                    child: Container(
                      color: Colors.red,
                      child: center,
                    ),
                  ),
                ),
              if (bottom != null)
                Positioned.fromRect(
                  rect: bottomRect,
                  child: Transform.translate(
                    offset: Offset(0, _offset),
                    child: bottom,
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
    print(details);
    setState(() {
      _offset += details.delta.dy;
      print(_offset);
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
