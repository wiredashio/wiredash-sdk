import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/utils/color_ext.dart';
import 'package:wiredash/src/common/widgets/animated_shape.dart';
import 'package:wiredash/src/common/widgets/tron_icon.dart';

class TronButton extends StatefulWidget {
  const TronButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    Key? key,
  }) : super(key: key);

  final Color? color;
  final IconData icon;
  final String label;
  final VoidCallback? onTap;

  @override
  _TronButtonState createState() => _TronButtonState();
}

class _TronButtonState extends State<TronButton>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 150);
  late AnimationController _controller;

  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _iconScaleAnimation;

  bool _focused = false; // TODO implement
  bool _pressed = false;
  bool _hovered = false;

  bool get _enabled => widget.onTap != null;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: _duration);

    _buttonScaleAnimation = Tween(begin: 1.0, end: 0.9).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
    _iconScaleAnimation = Tween(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color get _buttonColor {
    final buttonColor = widget.color ?? const Color(0xff1A56DB);

    if (widget.onTap == null) {
      return buttonColor.lighten(0.3);
    }

    if (_pressed) {
      // ignore: avoid_redundant_argument_values
      return buttonColor.darken(0.1);
    }

    if (_hovered) {
      return buttonColor.darken(0.05);
    }

    return buttonColor;
  }

  Color get _iconColor {
    // TODO define bright / dark icon colors in theme
    if (_buttonColor.brightness == Brightness.light) {
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
              scale: _buttonScaleAnimation,
              child: AnimatedShape(
                color: _buttonColor,
                shape: const StadiumBorder(),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTap: _simulateTap,
                  onTapCancel: _handleTapCancel,
                  onTapUp: _handleTapUp,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: ScaleTransition(
                    scale: _iconScaleAnimation,
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
    if (widget.onTap == null || _controller.isAnimating) return;
    widget.onTap!.call();

    setState(() {
      _pressed = true;
      _controller.forward();
    });

    await Future.delayed(_duration);

    setState(() {
      _pressed = false;
      _controller.reverse();
    });
  }

  void _handleFocusUpdate(bool focused) {
    setState(() {
      _focused = focused;
    });
  }

  void _handleMouseEnter(PointerEnterEvent event) {
    setState(() {
      _hovered = true;
    });
  }

  void _handleMouseExit(PointerExitEvent event) {
    setState(() {
      _hovered = false;
    });
  }

  void _handleTapDown(TapDownDetails details) {
    if (!_enabled) return;

    setState(() {
      _pressed = true;
      _controller.forward();
    });
  }

  void _handleTapUp(TapUpDetails details) {
    if (!_enabled) return;
    widget.onTap?.call();

    setState(() {
      _pressed = false;
      _controller.reverse();
    });
  }

  void _handleTapCancel() {
    setState(() {
      _pressed = false;
      _controller.reverse();
    });
  }
}
