import 'dart:async';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/feedback/ui/slider/stroke_width_slider_widget.dart';

class ColorPalette extends StatefulWidget {
  const ColorPalette({
    super.key,
    required this.colors,
    this.initialSelection = const Color(0xff6B46C1),
    this.initialStrokeWidth = 8.0,
    this.onNewColorSelected,
    this.onNewStrokeWidthSelected,
    this.onUndo,
  });

  static const _borderRadius = 20.0;

  final List<Color> colors;
  final Color initialSelection;
  final double initialStrokeWidth;
  final Function()? onUndo;
  final Function(Color)? onNewColorSelected;
  final Function(double)? onNewStrokeWidthSelected;

  @override
  State<ColorPalette> createState() => _ColorPaletteState();
}

class _ColorPaletteState extends State<ColorPalette>
    with SingleTickerProviderStateMixin {
  late Color selectedColor;
  late double selectedWidth;

  late AnimationController _controller;
  late CurvedAnimation _animation;
  late Tween<Offset> firstPaneTween;
  late Tween<Offset> secondPaneTween;

  Timer? _autoCloseTimer;

  @override
  void initState() {
    super.initState();
    selectedColor = widget.initialSelection;
    selectedWidth = widget.initialStrokeWidth;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 350),
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOutCubic,
    );
    firstPaneTween = Tween(begin: Offset.zero, end: const Offset(0, 1));
    secondPaneTween = Tween(begin: const Offset(0, -1), end: Offset.zero);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      clipBehavior: Clip.antiAlias,
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(ColorPalette._borderRadius),
          topRight: Radius.circular(ColorPalette._borderRadius),
        ),
        color: context.theme.primaryBackgroundColor,
      ),
      child: SafeArea(
        left: false,
        top: false,
        right: false,
        child: Stack(
          children: [
            SlideTransition(
              position: firstPaneTween.animate(_animation),
              child: FadeTransition(
                opacity: Tween(begin: 1.0, end: 0.0).animate(_animation),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TronButton(
                      leadingIcon: Wirecons.rewind,
                      label:
                          context.l10n.feedbackStep3ScreenshotBarDrawUndoButton,
                      color: context.theme.secondaryColor,
                      onTap: () => widget.onUndo?.call(),
                    ),
                    const SizedBox(width: 8),
                    Flexible(
                      child: HorizontalColorPicker(
                        colors: widget.colors,
                        selectedColor: selectedColor,
                        onNewColorSelected: (newColor) {
                          setState(() => selectedColor = newColor);
                          widget.onNewColorSelected?.call(selectedColor);
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    StrokeWidthDot(
                      onTap: () {
                        _controller.forward();
                        _autoCloseTimer = Timer(const Duration(seconds: 3), () {
                          _controller.reverse();
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                  ],
                ),
              ),
            ),
            Positioned.fill(
              child: SlideTransition(
                position: secondPaneTween.animate(_animation),
                child: FadeTransition(
                  opacity: Tween(begin: 0.0, end: 1.0).animate(_animation),
                  child: Row(
                    children: [
                      const SizedBox(width: 10),
                      AnimatedShape(
                        color: selectedColor,
                        shape: const StadiumBorder(),
                        child: const SizedBox(
                          width: 8,
                          height: 8,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: StrokeWidthSlider(
                          onInteract: () {
                            _autoCloseTimer?.cancel();
                          },
                          currentWidth: selectedWidth,
                          color: selectedColor,
                          minWidth: 5,
                          maxWidth: 32,
                          onNewWidthSelected: (newWidth) {
                            _controller.reverse();
                            selectedWidth = newWidth;
                            widget.onNewStrokeWidthSelected
                                ?.call(selectedWidth);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      AnimatedShape(
                        color: selectedColor,
                        shape: const StadiumBorder(),
                        child: const SizedBox(
                          width: 32,
                          height: 32,
                        ),
                      ),
                      const SizedBox(width: 10),
                    ],
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
  void dispose() {
    _autoCloseTimer?.cancel();
    super.dispose();
  }
}

class HorizontalColorPicker extends StatelessWidget {
  const HorizontalColorPicker({
    super.key,
    required this.colors,
    this.selectedColor,
    this.onNewColorSelected,
  });

  final List<Color> colors;
  final Color? selectedColor;
  final Function(Color)? onNewColorSelected;

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(
      behavior: ScrollConfiguration.of(context).copyWith(
        dragDevices: {
          PointerDeviceKind.touch,
          PointerDeviceKind.mouse,
        },
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            ...colors.map((color) {
              return Padding(
                padding: const EdgeInsets.only(left: 2),
                child: AnimatedColorDot(
                  color: color,
                  isSelected: color == selectedColor,
                  onTap: () => onNewColorSelected?.call(color),
                ),
              );
            }),
          ],
        ),
      ),
    );
  }
}

class StrokeWidthDot extends StatefulWidget {
  const StrokeWidthDot({super.key, this.onTap});

  final VoidCallback? onTap;

  @override
  State<StrokeWidthDot> createState() => _StrokeWidthDotState();
}

class _StrokeWidthDotState extends State<StrokeWidthDot> {
  bool _hovered = false;

  void _updateHoveredState(bool isHovered) {
    setState(() {
      _hovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => widget.onTap?.call(),
      behavior: HitTestBehavior.translucent,
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => _updateHoveredState(true),
        onExit: (_) => _updateHoveredState(false),
        child: SizedBox(
          width: 30,
          height: 30,
          child: Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 16,
                  height: 2,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    height: _hovered ? 4.5 : 3,
                  ),
                ),
                Container(
                  width: 16,
                  height: 3,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                AnimatedSize(
                  duration: const Duration(milliseconds: 150),
                  curve: Curves.easeOut,
                  child: SizedBox(
                    height: _hovered ? 4.5 : 3,
                  ),
                ),
                Container(
                  width: 16,
                  height: 4,
                  decoration: BoxDecoration(
                    color: context.theme.primaryColor,
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class AnimatedColorDot extends StatefulWidget {
  const AnimatedColorDot({
    super.key,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  State<AnimatedColorDot> createState() => _AnimatedColorDotState();
}

class _AnimatedColorDotState extends State<AnimatedColorDot>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Tween<double> _scaleTween;

  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _scaleTween = Tween(begin: 0.8, end: 1.0);

    if (widget.isSelected) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(covariant AnimatedColorDot oldWidget) {
    if (oldWidget.isSelected != widget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
    super.didUpdateWidget(oldWidget);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _updateHoveredState(bool isHovered) {
    setState(() {
      _hovered = isHovered;
    });
  }

  @override
  Widget build(BuildContext context) {
    final luminance = widget.color.computeLuminance();
    final colorBrightness =
        luminance > 0.5 ? Brightness.light : Brightness.dark;

    final Color color;
    if (widget.isSelected) {
      color = widget.color;
    } else if (_hovered) {
      // ignore: deprecated_member_use
      color = Color.alphaBlend(widget.color.withOpacity(0.85), Colors.white);
    } else {
      // ignore: deprecated_member_use
      color = Color.alphaBlend(widget.color.withOpacity(0.7), Colors.white);
    }

    Color outerCircleColor = color;
    // for light color add a darker circle
    if (luminance > 0.7) {
      outerCircleColor = widget.color.darken(0.16);
    }

    return ScaleTransition(
      scale: _scaleTween.animate(
        CurvedAnimation(
          parent: _controller,
          curve: Curves.easeOut,
          reverseCurve: Curves.easeIn,
        ),
      ),
      child: GestureDetector(
        onTap: widget.isSelected ? null : widget.onTap,
        behavior: HitTestBehavior.translucent,
        child: MouseRegion(
          cursor: widget.isSelected
              ? SystemMouseCursors.basic
              : SystemMouseCursors.click,
          onEnter: (_) => _updateHoveredState(true),
          onExit: (_) => _updateHoveredState(false),
          // outer ring
          child: AnimatedShape(
            color: widget.isSelected
                // ignore: deprecated_member_use
                ? outerCircleColor.withOpacity(0.5)
                : outerCircleColor,
            shape: const StadiumBorder(),
            child: Padding(
              padding: const EdgeInsets.all(1),
              // inner ring
              child: AnimatedShape(
                color: color,
                shape: const StadiumBorder(),
                child: SizedBox(
                  width: 34,
                  height: 34,
                  child: AnimatedOpacity(
                    duration: const Duration(milliseconds: 150),
                    opacity: widget.isSelected ? 1 : 0,
                    child: Icon(
                      Wirecons.check,
                      size: 20,
                      color: colorBrightness == Brightness.dark
                          ? Colors.white
                          : Colors.black,
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
}
