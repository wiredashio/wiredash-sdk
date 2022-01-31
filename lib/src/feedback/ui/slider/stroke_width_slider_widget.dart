import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/ui/slider/stroke_width_slider_painter.dart';

class StrokeWidthSlider extends StatefulWidget {
  const StrokeWidthSlider({
    Key? key,
    required this.color,
    required this.minWidth,
    required this.maxWidth,
    required this.currentWidth,
    this.onNewWidthSelected,
  }) : super(key: key);

  final Color color;
  final double minWidth;
  final double maxWidth;
  final double currentWidth;
  final Function(double)? onNewWidthSelected;

  @override
  State<StrokeWidthSlider> createState() => _StrokeWidthSliderState();
}

class _StrokeWidthSliderState extends State<StrokeWidthSlider> {
  Offset _dragPosition = Offset.zero;
  double _progress = -1;
  double _widgetWidth = 0;

  @override
  void initState() {
    super.initState();
  }

  void _capDragPosition(Offset position) {
    final halfMaxWidth = widget.maxWidth / 2;
    if (position.dx >= _widgetWidth - halfMaxWidth) {
      _dragPosition = Offset(_widgetWidth - halfMaxWidth, position.dy);
    } else if (position.dx <= 2) {
      _dragPosition = Offset(0, position.dy);
    } else {
      _dragPosition = position;
    }

    setState(() {});
  }

  void _reportNewWidth() {
    final newWidth =
        widget.minWidth + (widget.maxWidth - widget.minWidth) * _progress;
    widget.onNewWidthSelected?.call(newWidth);
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        _widgetWidth = constraints.maxWidth;

        if (_dragPosition == Offset.zero) {
          _progress = (widget.currentWidth - widget.minWidth) /
              (widget.maxWidth - widget.minWidth);
        } else {
          _progress = _dragPosition.dx / _widgetWidth;
        }

        return MouseRegion(
          cursor: SystemMouseCursors.click,
          child: Container(
            color: context.theme.primaryBackgroundColor,
            child: GestureDetector(
              onPanDown: (value) => _capDragPosition(value.localPosition),
              onPanUpdate: (value) => _capDragPosition(value.localPosition),
              onPanEnd: (value) => _reportNewWidth(),
              onPanCancel: () => _reportNewWidth(),
              child: CustomPaint(
                painter: StrokeWidthSliderPainter(
                  minWidth: widget.minWidth,
                  maxWidth: widget.maxWidth,
                  progress: _progress,
                  color: widget.color,
                ),
                child: const SizedBox.expand(),
              ),
            ),
          ),
        );
      },
    );
  }
}
