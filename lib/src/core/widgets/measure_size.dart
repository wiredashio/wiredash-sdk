import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

/// from https://stackoverflow.com/a/60868972/669294
class MeasureSize extends SingleChildRenderObjectWidget {
  final void Function(Size size, Rect bounds) onChange;

  const MeasureSize({
    Key? key,
    required this.onChange,
    required Widget child,
  }) : super(key: key, child: child);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return _MeasureSizeRenderObject(onChange);
  }
}

class _MeasureSizeRenderObject extends RenderProxyBox {
  Size? oldSize;
  Rect? oldBounds;
  final void Function(Size size, Rect bounds) onChange;

  _MeasureSizeRenderObject(this.onChange);

  @override
  void performLayout() {
    super.performLayout();
    final Rect newBounds = child!.paintBounds;
    final Size newSize = child!.size;
    if (oldSize == newSize && oldBounds == newBounds) return;

    oldBounds = newBounds;
    oldSize = newSize;
    widgetsBindingInstance.addPostFrameCallback((_) {
      onChange(newSize, newBounds);
    });
  }
}
