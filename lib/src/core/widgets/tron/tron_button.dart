import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

class TronButton extends StatefulWidget {
  const TronButton({
    this.leadingIcon,
    this.trailingIcon,
    this.label,
    this.child,
    this.onTap,
    this.color,
    this.textColor,
    this.iconOffset = Offset.zero,
    this.maxWidth,
    Key? key,
  })  : assert(
          label != null || child != null,
          'Set label or child, one is required',
        ),
        super(key: key);

  final Color? color;
  final Color? textColor;
  final IconData? leadingIcon;
  final IconData? trailingIcon;
  final Offset iconOffset;
  final String? label;
  final Widget? child;
  final VoidCallback? onTap;
  final double? maxWidth;

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
    _controller = AnimationController(
      vsync: this,
      duration: _duration,
      debugLabel: 'TronButton',
    );

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
      return buttonColor.lighten(0.03);
    }

    if (_pressed) {
      // ignore: avoid_redundant_argument_values
      return buttonColor.darken(0.02);
    }

    if (_hovered) {
      return buttonColor.lighten(0.02);
    }

    return buttonColor;
  }

  Color get _iconColor {
    final textColor = widget.textColor;
    if (textColor != null) {
      if (!_enabled) {
        return textColor.withOpacity(0.3);
      }
      return textColor;
    }
    final buttonColor = _buttonColor;
    final luminance = buttonColor.computeLuminance();
    final hsl = HSLColor.fromColor(buttonColor);
    final blackOrWhite =
        luminance < 0.4 ? const Color(0xffffffff) : const Color(0xff000000);

    if (!_enabled) {
      return blackOrWhite.withOpacity(0.3);
    }

    return blackOrWhite.withOpacity(math.max(hsl.saturation, 0.9));
  }

  @override
  Widget build(BuildContext context) {
    final semanticsLabel = widget.label ??
        (widget.child is Text ? (widget.child as Text?)?.data : null);
    return Focus(
      onFocusChange: _handleFocusUpdate,
      child: MouseRegion(
        cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
        onEnter: _handleMouseEnter,
        onExit: _handleMouseExit,
        child: Semantics(
          button: true,
          enabled: _enabled,
          label: semanticsLabel,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              minWidth: 48,
              maxWidth: widget.maxWidth ?? 200,
              minHeight: 38,
              maxHeight: 48,
            ),
            child: ScaleTransition(
              scale: _buttonScaleAnimation,
              child: AnimatedShape(
                color: _buttonColor,
                shape: const StadiumBorder(),
                child: GestureDetector(
                  onTapDown: _handleTapDown,
                  onTapCancel: _handleTapCancel,
                  onTapUp: _handleTapUp,
                  behavior: HitTestBehavior.opaque,
                  excludeFromSemantics: true,
                  child: ScaleTransition(
                    scale: _iconScaleAnimation,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (widget.leadingIcon != null)
                            TronIcon(
                              widget.leadingIcon!,
                              color: _iconColor,
                            ),
                          if (widget.leadingIcon != null)
                            const SizedBox(width: 8),
                          if (widget.trailingIcon != null)
                            const SizedBox(width: 4),
                          Flexible(
                            child: DefaultTextStyle(
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: context.theme.textTheme.button
                                  .copyWith(color: _iconColor),
                              child: widget.child ?? Text(widget.label!),
                            ),
                          ),
                          if (widget.leadingIcon != null)
                            const SizedBox(width: 4),
                          if (widget.trailingIcon != null)
                            const SizedBox(width: 8),
                          if (widget.trailingIcon != null)
                            TronIcon(
                              widget.trailingIcon!,
                              color: _iconColor,
                            ),
                        ],
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
    widget.onTap!.call();
    setState(() {
      _pressed = false;
    });
    _controller.forward().then((value) => _controller.reverse());
  }

  void _handleTapCancel() {
    setState(() {
      _pressed = false;
    });
    _controller.forward().then((value) => _controller.reverse());
  }
}

/// Backport of [AnimatedSlide], which was added in Flutter 2.5
class _AnimatedSlideBackport extends ImplicitlyAnimatedWidget {
  /// Creates a widget that animates its offset translation implicitly.
  ///
  /// The [offset] and [duration] arguments must not be null.
  const _AnimatedSlideBackport({
    Key? key,
    // ignore: unused_element
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
