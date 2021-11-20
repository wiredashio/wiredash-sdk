import 'package:flutter/gestures.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/utils/color_ext.dart';
import 'package:wiredash/src/common/widgets/tron_icon.dart';

enum TronButtonStyle { primary, secondary, custom }

class TronButton extends ImplicitlyAnimatedWidget {
  const TronButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color, // TODO discuss TronButtonStyle vs text / icon colors
    this.style = TronButtonStyle.primary,
    Key? key,
  }) : super(
          key: key,
          curve: Curves.easeOutCubic,
          duration: const Duration(milliseconds: 300),
        );

  final Color? color;
  final IconData icon;
  final String label;
  final TronButtonStyle style;
  final VoidCallback? onTap;

  @override
  _TronButtonState createState() => _TronButtonState();
}

class _TronButtonState extends AnimatedWidgetBaseState<TronButton> {
  ColorTween? _buttonColorTween;
  Tween<double>? _iconScaleTween;
  Tween<double>? _buttonScaleTween;

  bool _focused = false;
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onTap != null;

  Color get _buttonColor {
    switch (widget.style) {
      case TronButtonStyle.primary:
        return const Color(0xff1A56DB);
      case TronButtonStyle.secondary:
        return const Color(0xffE8EEFB);
    }

    return widget.color ?? const Color(0xff1A56DB);
  }

  Color get _iconColor {
    switch (widget.style) {
      case TronButtonStyle.primary:
        return const Color(0xffE8EEFB);
      case TronButtonStyle.secondary:
        return const Color(0xff1A56DB);
    }

    return const Color(0xffE8EEFB);
  }

  @override
  Widget build(BuildContext context) {
    return Focus(
      // focusNode: widget.focusNode,
      // canRequestFocus: _canRequestFocus,
      onFocusChange: _handleFocusUpdate,
      // autofocus: widget.autofocus,
      child: MouseRegion(
        cursor:
            _enabled ? SystemMouseCursors.click : SystemMouseCursors.forbidden,
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: Semantics(
          button: true,
          label: widget.label,
          onTap: widget.onTap == null ? null : _simulateTap,
          child: SizedBox(
            height: 48,
            width: 80,
            child: ScaleTransition(
              scale: _buttonScaleTween!.animate(animation),
              child: PhysicalShape(
                color: _buttonColorTween!.evaluate(animation)!,
                elevation: _focused ? 2 : 0,
                clipper: const ShapeBorderClipper(
                  shape: StadiumBorder(),
                ),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTap: _simulateTap,
                  onTapCancel: _handleTapCancel,
                  onTapUp: _handleTapUp,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: ScaleTransition(
                    scale: _iconScaleTween!.animate(animation),
                    child: TronIcon(
                      widget.icon,
                      color: _iconColor,
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

  Future<void> _simulateTap() async {
    if (widget.onTap == null) return;
    widget.onTap!.call();

    _pressed = true;
    didUpdateWidget(widget);
    await Future.delayed(widget.duration);
    _pressed = false;
    didUpdateWidget(widget);
  }

  void _handleFocusUpdate(bool focused) {
    _focused = focused;
    didUpdateWidget(widget);
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    _hovered = true;
    didUpdateWidget(widget);
  }

  void _handleMouseExit(PointerExitEvent event) {
    _hovered = false;
    didUpdateWidget(widget);
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_enabled) return;
    _pressed = true;
    didUpdateWidget(widget);
  }

  void _handleTapUp(TapUpDetails details) {
    _pressed = false;
    widget.onTap?.call();
    didUpdateWidget(widget);
  }

  void _handleTapCancel() {
    _pressed = false;
    didUpdateWidget(widget);
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _buttonColorTween = visitor(
      _buttonColorTween,
      () {
        if (widget.onTap == null) {
          return _buttonColor.lighten(0.3);
        }
        if (_pressed) {
          // ignore: avoid_redundant_argument_values
          return _buttonColor.darken(0.1);
        }
        if (_hovered) {
          return _buttonColor.darken(0.05);
        }
        return _buttonColor;
      }(),
      (dynamic value) => ColorTween(begin: value as Color?),
    ) as ColorTween?;

    _iconScaleTween = visitor(
      _iconScaleTween,
      _pressed ? 1.2 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;

    _buttonScaleTween = visitor(
      _buttonScaleTween,
      _pressed ? .90 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;
  }
}
