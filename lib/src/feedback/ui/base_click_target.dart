import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const buttonBlue = Color(0xFF1A56DB);

class BaseClickTarget extends StatefulWidget {
  const BaseClickTarget({
    Key? key,
    this.onTap,
    required this.builder,
    this.child,
    this.selected,
  }) : super(key: key);

  final void Function()? onTap;
  final Widget Function(BuildContext context, TargetState state, Widget? child)
      builder;
  final Widget? child;
  final bool? selected;

  @override
  State<BaseClickTarget> createState() => _BaseClickTargetState();
}

class _BaseClickTargetState extends State<BaseClickTarget> {
  bool _focused = false;

  bool _pressed = false;

  bool _hovered = false;

  bool get _enabled => widget.onTap != null;

  TargetState get state {
    return TargetState(
      focused: _focused,
      pressed: _pressed,
      hovered: _hovered,
      enabled: _enabled,
      selected: widget.selected ?? false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: _enabled ? SystemMouseCursors.click : SystemMouseCursors.basic,
      onEnter: (event) {
        setState(() {
          _hovered = true;
        });
      },
      onExit: (event) {
        setState(() {
          _hovered = false;
        });
      },
      child: Focus(
        onFocusChange: (focused) {
          setState(() {
            _focused = focused;
          });
        },
        child: GestureDetector(
          onTap: widget.onTap,
          onTapDown: (_) {
            if (!_enabled) return;
            setState(() {
              _pressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              _pressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              _pressed = false;
            });
          },
          child: widget.builder(context, state, widget.child),
        ),
      ),
    );
  }
}

class TargetState {
  final bool focused;
  final bool pressed;
  final bool hovered;
  final bool enabled;
  final bool selected;

  const TargetState({
    required this.focused,
    required this.pressed,
    required this.hovered,
    required this.enabled,
    required this.selected,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetState &&
          runtimeType == other.runtimeType &&
          focused == other.focused &&
          pressed == other.pressed &&
          hovered == other.hovered &&
          enabled == other.enabled &&
          selected == other.selected;

  @override
  int get hashCode =>
      focused.hashCode ^
      pressed.hashCode ^
      hovered.hashCode ^
      enabled.hashCode ^
      selected.hashCode;

  @override
  String toString() {
    return 'TargetState{'
        'focused: $focused, '
        'pressed: $pressed, '
        'hovered: $hovered, '
        'enabled: $enabled, '
        'selected: $selected'
        '}';
  }
}

class TargetStateAnimations {
  final Animation<double> focusedAnim;
  final Animation<double> pressedAnim;
  final Animation<double> hoveredAnim;
  final Animation<double> enabledAnim;
  final Animation<double> selectedAnim;

  const TargetStateAnimations({
    required this.focusedAnim,
    required this.pressedAnim,
    required this.hoveredAnim,
    required this.enabledAnim,
    required this.selectedAnim,
  });
}

class AnimatedClickTarget extends StatefulWidget {
  const AnimatedClickTarget({
    Key? key,
    this.focusNode,
    this.onTap,
    required this.builder,
    this.duration = const Duration(milliseconds: 200),
    this.selected,
  }) : super(key: key);

  final FocusNode? focusNode;
  final void Function()? onTap;
  final Widget Function(
    BuildContext context,
    TargetState state,
    TargetStateAnimations anims,
  ) builder;
  final Duration duration;
  final bool? selected;

  @override
  State<AnimatedClickTarget> createState() => _AnimatedClickTargetState();
}

class _AnimatedClickTargetState extends State<AnimatedClickTarget>
    with TickerProviderStateMixin {
  late AnimationController _focusedController;
  late AnimationController _pressedController;
  late AnimationController _hoveredController;
  late AnimationController _enabledController;
  late AnimationController _selectedController;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _focusedController =
        AnimationController(vsync: this, duration: widget.duration);
    _pressedController =
        AnimationController(vsync: this, duration: widget.duration);
    _hoveredController =
        AnimationController(vsync: this, duration: widget.duration);
    _enabledController =
        AnimationController(vsync: this, duration: widget.duration);
    _selectedController =
        AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant AnimatedClickTarget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selected != widget.selected) {
      if (widget.selected == true) _selectedController.forward();
      if (widget.selected == false) _selectedController.reverse();
    }
  }

  @override
  void dispose() {
    _focusedController.dispose();
    _pressedController.dispose();
    _hoveredController.dispose();
    _enabledController.dispose();
    _selectedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anims = TargetStateAnimations(
      focusedAnim: _focusedController,
      pressedAnim: _pressedController,
      hoveredAnim: _hoveredController,
      enabledAnim: _enabledController,
      selectedAnim: _selectedController,
    );

    return BaseClickTarget(
      onTap: widget.onTap,
      selected: widget.selected,
      builder: (context, state, child) {
        if (state.focused) {
          _focusedController.forward();
        }
        if (!state.focused) {
          _focusedController.reverse();
        }

        if (state.pressed) {
          _pressedController.forward();
        }
        if (!state.pressed) {
          _pressedController.reverse();
        }

        if (state.hovered) {
          _hoveredController.forward();
        }
        if (!state.hovered) {
          _hoveredController.reverse();
        }

        if (state.enabled) {
          _enabledController.forward();
        }
        if (!state.enabled) {
          _enabledController.reverse();
        }
        return AnimatedBuilder(
          animation: Listenable.merge([
            _focusedController,
            _pressedController,
            _hoveredController,
            _enabledController,
            _selectedController,
          ]),
          builder: (context, _) {
            return widget.builder(context, state, anims);
          },
        );
      },
    );
  }
}
