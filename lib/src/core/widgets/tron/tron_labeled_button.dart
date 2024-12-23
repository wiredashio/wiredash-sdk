import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_ui.dart';

/// Clickable text
class TronLabeledButton extends ImplicitlyAnimatedWidget {
  const TronLabeledButton({
    super.key,
    required this.child,
    this.onTap,
    this.padding,
  }) : super(
          curve: Curves.easeInOutCirc,
          duration: const Duration(milliseconds: 150),
        );

  final Widget child;
  final void Function()? onTap;
  final EdgeInsetsGeometry? padding;

  @override
  AnimatedWidgetBaseState<TronLabeledButton> createState() =>
      _LabeledButtonState();
}

class _LabeledButtonState extends AnimatedWidgetBaseState<TronLabeledButton> {
  ColorTween? _colorTween;
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
              height: 24,
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
                  child: ScaleTransition(
                    scale: _buttonScaleTween!.animate(animation),
                    child: DefaultTextStyle(
                      style: context.text.caption.onBackground,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      child: Center(
                        widthFactor: 1,
                        child: Padding(
                          padding: widget.padding ??
                              const EdgeInsets.symmetric(horizontal: 8),
                          child: widget.child,
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

  late Color color = const Color(0x00000000);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    color = WiredashTheme.of(context)!.secondaryColor;
  }

  @override
  void forEachTween(TweenVisitor<dynamic> visitor) {
    _colorTween = visitor(
      _colorTween,
      () {
        if (widget.onTap == null) {
          // ignore: deprecated_member_use
          return color.withOpacity(0);
        }
        if (_pressed) {
          // ignore: avoid_redundant_argument_values, deprecated_member_use
          return color.withOpacity(0.4);
        }
        if (_hovered) {
          // ignore: deprecated_member_use
          return color.withOpacity(0.2);
        }
        // ignore: deprecated_member_use
        return color.withOpacity(0);
      }(),
      (dynamic value) => ColorTween(begin: value as Color?),
    ) as ColorTween?;
    _buttonScaleTween = visitor(
      _buttonScaleTween,
      _pressed ? 1.05 : 1.0,
      (dynamic value) => Tween<double>(begin: value as double?),
    ) as Tween<double>?;
  }
}
