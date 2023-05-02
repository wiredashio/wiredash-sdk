import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';

/// A better version of [AnimatedSwitcher] that fades the old child completely
/// out before showing the new one
class AnimatedFadeWidgetSwitcher extends StatefulWidget {
  const AnimatedFadeWidgetSwitcher({
    super.key,
    this.child,
    this.duration,
    this.alignment,
    this.fadeInOnEnter,
    this.initialWidgetBuilder,
    this.zoomFactor,
    this.onSwitch,
    this.clipBehavior,
  });

  final Widget? child;
  final Duration? duration;
  final Alignment? alignment;
  final double? zoomFactor;
  final Clip? clipBehavior;

  /// Called when the widget switches from old to new child
  final void Function()? onSwitch;

  /// defaults to [true], draws [initialWidgetBuilder] at first frame or nothing
  final bool? fadeInOnEnter;

  /// The widget that is drawn at the first frame before [child] will be faded
  /// in.
  final Widget Function()? initialWidgetBuilder;

  @override
  State<AnimatedFadeWidgetSwitcher> createState() =>
      _AnimatedFadeWidgetSwitcherState();
}

class _AnimatedFadeWidgetSwitcherState
    extends State<AnimatedFadeWidgetSwitcher> {
  bool _firstBuild = true;

  Widget? _lastChild;

  @override
  Widget build(BuildContext context) {
    if (_firstBuild) {
      widgetsBindingInstance.addPostFrameCallback((timeStamp) {
        if (mounted) {
          setState(() {
            _firstBuild = false;
          });
        } else {
          _firstBuild = false;
        }
      });
    }

    Widget? child = widget.child;
    if (_firstBuild && widget.fadeInOnEnter != false) {
      child = widget.initialWidgetBuilder?.call();
    }

    if (child != null &&
            _lastChild != null &&
            _lastChild != child &&
            !Widget.canUpdate(_lastChild!, child) ||
        child == null && _lastChild != null) {
      widget.onSwitch?.call();
    }
    return PageTransitionSwitcher(
      duration: widget.duration ?? const Duration(milliseconds: 300),
      layoutBuilder: (List<Widget> entries) {
        return Stack(
          alignment: widget.alignment ?? Alignment.center,
          clipBehavior: widget.clipBehavior ?? Clip.none,
          children: entries,
        );
      },
      transitionBuilder: (child, a1, a2) {
        return FadeSwapTransition(
          animation: a1,
          secondaryAnimation: a2,
          zoomFactor: widget.zoomFactor,
          child: child,
        );
      },
      child: _lastChild = child,
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty('child', widget.child));
    properties.add(DiagnosticsProperty('lastChild', _lastChild));
    properties.add(
      FlagProperty(
        'fadeInOnEnter',
        value: widget.fadeInOnEnter,
        defaultValue: true,
        ifTrue: 'fade in on enter',
        ifFalse: 'do not fade in on enter',
      ),
    );
  }
}

class FadeSwapTransition extends StatelessWidget {
  const FadeSwapTransition({
    super.key,
    required this.animation,
    required this.secondaryAnimation,
    this.zoomFactor,
    this.child,
  });

  /// The animation that drives the [child]'s entrance and exit.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.animate], which is the value given to this property
  ///    when the [FadeThroughTransition] is used as a page transition.
  final Animation<double> animation;

  /// The animation that transitions [child] when new content is pushed on top
  /// of it.
  ///
  /// See also:
  ///
  ///  * [TransitionRoute.secondaryAnimation], which is the value given to this
  //     property when the [FadeThroughTransition] is used as a page transition.
  final Animation<double> secondaryAnimation;

  final double? zoomFactor;

  /// The widget below this widget in the tree.
  ///
  /// This widget will transition in and out as driven by [animation] and
  /// [secondaryAnimation].
  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return _ZoomedFadeInFadeOut(
      zoomFactor: zoomFactor,
      animation: animation,
      child: _ZoomedFadeInFadeOut(
        zoomFactor: zoomFactor,
        animation: ReverseAnimation(secondaryAnimation),
        child: child,
      ),
    );
  }
}

class _ZoomedFadeInFadeOut extends StatelessWidget {
  const _ZoomedFadeInFadeOut({
    required this.animation,
    this.zoomFactor,
    this.child,
  });

  final Animation<double> animation;
  final Widget? child;
  final double? zoomFactor;

  @override
  Widget build(BuildContext context) {
    return DualTransitionBuilder(
      animation: animation,
      forwardBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return _ZoomedFadeIn(
          animation: animation,
          zoomFactor: zoomFactor,
          child: child,
        );
      },
      reverseBuilder: (
        BuildContext context,
        Animation<double> animation,
        Widget? child,
      ) {
        return _FadeOut(
          animation: animation,
          child: child,
        );
      },
      child: child,
    );
  }
}

class _ZoomedFadeIn extends StatelessWidget {
  const _ZoomedFadeIn({
    required this.animation,
    this.zoomFactor,
    this.child,
  });

  final Animation<double> animation;
  final double? zoomFactor;
  final Widget? child;

  static final CurveTween _inCurve = CurveTween(
    curve: const Cubic(0.0, 0.0, 0.2, 1.0),
  );
  static final TweenSequence<double> _fadeInOpacity = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 6 / 20,
      ),
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 0.0, end: 1.0).chain(_inCurve),
        weight: 14 / 20,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    final TweenSequence<double> scaleIn = TweenSequence<double>(
      <TweenSequenceItem<double>>[
        TweenSequenceItem<double>(
          tween: ConstantTween<double>(zoomFactor ?? 1.0),
          weight: 6 / 20,
        ),
        TweenSequenceItem<double>(
          tween:
              Tween<double>(begin: zoomFactor ?? 1.0, end: 1.0).chain(_inCurve),
          weight: 14 / 20,
        ),
      ],
    );
    return FadeTransition(
      opacity: _fadeInOpacity.animate(animation),
      child: ScaleTransition(
        scale: scaleIn.animate(animation),
        child: child,
      ),
    );
  }
}

class _FadeOut extends StatelessWidget {
  const _FadeOut({
    this.child,
    required this.animation,
  });

  final Widget? child;
  final Animation<double> animation;

  static final CurveTween _outCurve = CurveTween(
    curve: const Cubic(0.4, 0.0, 1.0, 1.0),
  );
  static final TweenSequence<double> _fadeOutOpacity = TweenSequence<double>(
    <TweenSequenceItem<double>>[
      TweenSequenceItem<double>(
        tween: Tween<double>(begin: 1.0, end: 0.0).chain(_outCurve),
        weight: 6 / 20,
      ),
      TweenSequenceItem<double>(
        tween: ConstantTween<double>(0.0),
        weight: 14 / 20,
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeOutOpacity.animate(animation),
      child: child,
    );
  }
}
