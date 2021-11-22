import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/utils/color_ext.dart';

const _lightBlue = Color(0xFFC6D5F6);

class LabeledButton extends ImplicitlyAnimatedWidget {
  const LabeledButton({
    Key? key,
    required this.child,
    this.onTap,
    this.padding,
  }) : super(
          key: key,
          curve: Curves.easeInOutCirc,
          duration: const Duration(milliseconds: 150),
        );

  final Widget child;
  final void Function()? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  AnimatedWidgetBaseState<LabeledButton> createState() => _BigBlueButtonState();
}

class _BigBlueButtonState extends AnimatedWidgetBaseState<LabeledButton> {
  ColorTween? _colorTween;
  Tween<double>? _iconScaleTween;
  Tween<double>? _buttonScaleTween;

  bool _focused = false;

  bool _pressed = false;

  bool _hovered = false;

  bool get _enabled => widget.onTap != null;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (event) {
        _hovered = true;
        didUpdateWidget(widget);
      },
      onExit: (event) {
        _hovered = false;
        didUpdateWidget(widget);
      },
      child: Focus(
        onFocusChange: (focused) {
          _focused = focused;
          didUpdateWidget(widget);
        },
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              height: 32,
              child: PhysicalShape(
                color: _colorTween!.evaluate(animation)!,
                elevation: _focused ? 2 : 0,
                clipper: ShapeBorderClipper(
                  shape: const StadiumBorder(),
                  textDirection: Directionality.maybeOf(context),
                ),
                child: GestureDetector(
                  onTap: widget.onTap,
                  onTapDown: (_) {
                    if (!_enabled) return;
                    _pressed = true;
                    didUpdateWidget(widget);
                  },
                  onTapUp: (_) {
                    _pressed = false;
                    didUpdateWidget(widget);
                  },
                  onTapCancel: () {
                    _pressed = false;
                    didUpdateWidget(widget);
                  },
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: IconTheme(
                    data: const IconThemeData(color: Color(0xffffffff)),
                    child: ScaleTransition(
                      scale: _iconScaleTween!.animate(animation),
                      child: DefaultTextStyle(
                        style: const TextStyle(
                          color: Color(0xFF1A56DB),
                          fontSize: 14,
                          height: 1,
                          // TODO add Inter font?
                          fontWeight: FontWeight.w800,
                        ),
                        child: Center(
                          widthFactor: 1,
                          child: Padding(
                            padding: widget.padding ??
                                const EdgeInsets.symmetric(horizontal: 16),
                            child: widget.child,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
      _colorTween,
      () {
        if (widget.onTap == null) {
          return _lightBlue.lighten(0.3);
        }
        if (_pressed) {
          // ignore: avoid_redundant_argument_values
          return _lightBlue.darken(0.1);
        }
        if (_hovered) {
          return _lightBlue.darken(0.05);
        }
        return _lightBlue;
      }(),
      (dynamic value) => ColorTween(begin: value as Color?),
    ) as ColorTween?;
    _iconScaleTween = visitor(
      _iconScaleTween,
      _pressed ? 1.1 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;
    _buttonScaleTween = visitor(
      _buttonScaleTween,
      _pressed ? 2.0 : 0.0,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;
  }
}
