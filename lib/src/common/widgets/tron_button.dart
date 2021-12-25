import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/color_ext.dart';
import 'package:wiredash/src/common/widgets/animated_shape.dart';
import 'package:wiredash/src/common/widgets/tron_icon.dart';

class TronButton extends StatefulWidget {
  const TronButton({
    required this.icon,
    required this.label,
    this.onTap,
    this.color,
    this.iconOffset = Offset.zero,
    Key? key,
  }) : super(key: key);

  final Color? color;
  final IconData icon;
  final Offset iconOffset;
  final String label;
  final VoidCallback? onTap;

  @override
  State<TronButton> createState() => _TronButtonState();
}

class _TronButtonState extends State<TronButton>
    with SingleTickerProviderStateMixin {
  static const _duration = Duration(milliseconds: 150);
  late AnimationController _controller;

  late Animation<double> _buttonScaleAnimation;
  late Animation<double> _iconScaleAnimation;

  // ignore: unused_field
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
    final buttonColor = widget.color ?? context.theme.primaryColor;

    if (!_enabled) {
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
    final buttonColor = _buttonColor;
    final luminance = buttonColor.computeLuminance();
    final hsl = HSLColor.fromColor(buttonColor);
    final blackOrWhite = luminance < 0.4 ? Colors.white : Colors.black;

    return blackOrWhite.withOpacity(math.max(hsl.saturation, 0.6));
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
          enabled: _enabled,
          label: widget.label,
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
                    child: _AnimatedSlideBackport(
                      duration: _duration,
                      offset: widget.iconOffset,
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

/// Backport of [AnimatedSlide], which was added in Flutter 2.5
class _AnimatedSlideBackport extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its offset translation implicitly.
  ///
  /// The [offset] and [duration] arguments must not be null.
  const _AnimatedSlideBackport({
    Key? key,
    this.child,
    required this.offset,
    Curve curve = Curves.linear,
    required Duration duration,
    VoidCallback? onEnd,
  }) : super(key: key, curve: curve, duration: duration, onEnd: onEnd);

  /// The widget below this widget in the tree.
  ///
  /// {@macro flutter.widgets.ProxyWidget.child}
  final Widget? child;

  /// The target offset.
  /// The child will be translated horizontally by `width * dx` and vertically
  /// by `height * dy`
  ///
  /// The offset must not be null.
  final Offset offset;

  @override
  ImplicitlyAnimatedWidgetState<_AnimatedSlideBackport> createState() =>
      _AnimatedSlideBackportState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<Offset>('offset', offset));
  }
}

class _AnimatedSlideBackportState
    extends ImplicitlyAnimatedWidgetState<_AnimatedSlideBackport> {
  Tween<Offset>? _offset;
  late Animation<Offset> _offsetAnimation;

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _offset = visitor(
      _offset,
      widget.offset,
      (dynamic value) => Tween<Offset>(begin: value as Offset),
    ) as Tween<Offset>?;
  }

  @override
  void didUpdateTweens() {
    _offsetAnimation = animation.drive(_offset!);
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _offsetAnimation,
      child: widget.child,
    );
  }
}
