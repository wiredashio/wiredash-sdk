import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

const buttonBlue = Color(0xFF1A56DB);

// TODO document
class BaseClickTarget extends StatefulWidget {
  const BaseClickTarget({
    Key? key,
    this.onTap,
    required this.builder,
    this.child,
  }) : super(key: key);

  final void Function()? onTap;
  final Widget Function(BuildContext context, TargetState state, Widget? child)
      builder;
  final Widget? child;

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

  const TargetState({
    required this.focused,
    required this.pressed,
    required this.hovered,
    required this.enabled,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TargetState &&
          runtimeType == other.runtimeType &&
          focused == other.focused &&
          pressed == other.pressed &&
          hovered == other.hovered &&
          enabled == other.enabled;

  @override
  int get hashCode =>
      focused.hashCode ^ pressed.hashCode ^ hovered.hashCode ^ enabled.hashCode;

  @override
  String toString() {
    return 'TargetState{focused: $focused, pressed: $pressed, hovered: $hovered, enabled: $enabled}';
  }
}

class TargetStateAnimations {
  final Animation<double> focusedAnim;
  final Animation<double> pressedAnim;
  final Animation<double> hoveredAnim;
  final Animation<double> enabledAnim;

  const TargetStateAnimations({
    required this.focusedAnim,
    required this.pressedAnim,
    required this.hoveredAnim,
    required this.enabledAnim,
  });
}

// TODO document
class AnimatedClickTarget extends StatefulWidget {
  const AnimatedClickTarget({
    Key? key,
    this.focusNode,
    this.onTap,
    required this.builder,
    this.duration = const Duration(milliseconds: 200),
  }) : super(key: key);

  final FocusNode? focusNode;
  final void Function()? onTap;
  final Widget Function(
          BuildContext context, TargetState state, TargetStateAnimations anims)
      builder;
  final Duration duration;

  @override
  _AnimatedClickTargetState createState() => _AnimatedClickTargetState();
}

class _AnimatedClickTargetState extends State<AnimatedClickTarget>
    with TickerProviderStateMixin {
  late AnimationController _focusedController;
  late AnimationController _pressedController;
  late AnimationController _hoveredController;
  late AnimationController _enabledController;

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
  }

  @override
  void dispose() {
    _focusedController.dispose();
    _pressedController.dispose();
    _hoveredController.dispose();
    _enabledController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final anims = TargetStateAnimations(
      focusedAnim: _focusedController,
      pressedAnim: _pressedController,
      hoveredAnim: _hoveredController,
      enabledAnim: _enabledController,
    );

    return BaseClickTarget(
      onTap: widget.onTap,
      builder: (context, state, child) {
        if (state.focused && _focusedController.isDismissed) {
          _focusedController.forward();
        }
        if (!state.focused && _focusedController.isCompleted) {
          _focusedController.reverse();
        }

        if (state.pressed && _pressedController.isDismissed) {
          _pressedController.forward();
        }
        if (!state.pressed && _pressedController.isCompleted) {
          _pressedController.reverse();
        }

        if (state.hovered && _hoveredController.isDismissed) {
          _hoveredController.forward();
        }
        if (!state.hovered && _hoveredController.isCompleted) {
          _hoveredController.reverse();
        }

        if (state.enabled && _enabledController.isDismissed) {
          _enabledController.forward();
        }
        if (!state.enabled && _enabledController.isCompleted) {
          _enabledController.reverse();
        }
        return AnimatedBuilder(
          animation: Listenable.merge([
            _focusedController,
            _pressedController,
            _hoveredController,
            _enabledController
          ]),
          builder: (context, _) {
            return widget.builder(context, state, anims);
          },
        );
      },
    );
  }
}
