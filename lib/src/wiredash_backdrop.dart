import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/measure.dart';
import 'package:wiredash/src/responsive_layout.dart';
import 'package:wiredash/src/snap.dart';
import 'package:wiredash/src/sprung.dart';
import 'package:wiredash/src/wiredash_provider.dart';

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({Key? key, required this.child, this.controller})
      : super(key: key);

  /// The wrapped app
  final Widget child;
  final BackdropController? controller;

  static BackdropController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_WiredashBackdropState>();
    return BackdropController().._state = state;
  }

  @override
  State<WiredashBackdrop> createState() => _WiredashBackdropState();

  static const Duration enterDuration = Duration(milliseconds: 800);
  static const Duration exitDuration = Duration(milliseconds: 400);
}

class BackdropController {
  _WiredashBackdropState? _state;

  Future<void> showWiredash() async {
    if (_state!._backdropAnimationController.status ==
        AnimationStatus.dismissed) {
      // Wiredash is currently not shown

      // 1) start animation, causes app to be rendered on top of stack
      final openFuture = _state!._backdropAnimationController.forward();

      // 2) Wait 1 frame until layout of the app in the list is known
      final completer = Completer();
      WidgetsBinding.instance?.addPostFrameCallback((_) {
        // 3) Switch app from top of stack to be inlined in list
        // ignore: invalid_use_of_protected_member
        _state!.setState(() {
          _state!._isLayoutingCompleted = true;
        });

        completer.complete();
      });
      await completer.future;
      await openFuture;
    } else {
      _state!._backdropAnimationController.forward();
    }
  }

  Future<void> hideWiredash() async {
    await _state!._backdropAnimationController.reverse();
    // ignore: invalid_use_of_protected_member
    _state!.setState(() {
      _state!._isLayoutingCompleted = false;
    });
  }
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  final GlobalKey _childAppKey = GlobalKey<State<StatefulWidget>>();

  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  late final ScrollController _scrollController;

  /// Controls revealing and hiding of Wiredash
  ///
  /// forward() to open, reverse() to close
  late final AnimationController _backdropAnimationController;

  late Animation<double> _scaleAppAnimation;
  late Animation<double> _translateAppAnimation;
  late Animation<BorderRadius?> _appCornerRadiusAnimation;

  /// When opening wiredash layouting has not yet finished and we don't know
  /// the exact location of the app in our layout. This flag is used to show the
  /// app at current position (fully visible, fully expanded) until the first
  /// frame is drawn and the animation can start.
  bool _isLayoutingCompleted = false;

  /// Position of the app relative to the whole backdrop layout
  Rect? savedRect;

  /// The "default" position of app to prevent flickering on first frame
  static const double appStartingTopPosition = 220;

  late Animation<double> _centerAnimation;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _scrollController = ScrollController();
    _backdropAnimationController = AnimationController(
      vsync: this,
      duration: WiredashBackdrop.enterDuration,
      reverseDuration: WiredashBackdrop.exitDuration,
    )..addStatusListener(_animControllerStatusListener);

    final slightlyUnderdumped = Sprung(18);
    _centerAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.0, 1.0, curve: Sprung.overDamped),
      reverseCurve: slightlyUnderdumped.flipped,
    );
    final CurvedAnimation inlineAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.4, 1.0, curve: slightlyUnderdumped),
      reverseCurve: slightlyUnderdumped.flipped,
    );

    _translateAppAnimation =
        Tween<double>(begin: -1, end: 0).animate(inlineAnimation);
    _appCornerRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0),
      end: BorderRadius.circular(20),
    ).animate(_centerAnimation);
  }

  /// returns the scale factor of
  double _calculateScaleFactor() {
    final mediaQueryData =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    final Size screenSize = mediaQueryData.size;

    final double targetContentWidth = screenSize.width -
        mediaQueryData.viewPadding.horizontal -
        2 * context.responsiveLayout.horizontalMargin;

    return targetContentWidth / screenSize.width;
  }

  void _animControllerStatusListener(AnimationStatus status) {
    if (_animationStatus != status) {
      setState(() {
        _animationStatus = _backdropAnimationController.status;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _scaleAppAnimation = Tween<double>(begin: 1, end: _calculateScaleFactor())
        .animate(_centerAnimation);
  }

  @override
  void didUpdateWidget(WiredashBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: _childAppKey,
      child: widget.child,
    );

    if (_animationStatus == AnimationStatus.dismissed) {
      // animation is not yet started, show the app without being wrapped in Transforms
      return child;
    }

    final model = context.wiredashModel;
    child = AbsorbPointer(
      absorbing: !model.isAppInteractive,
      child: child,
    );

    final appTopPosition = savedRect?.top ?? appStartingTopPosition;
    return Material(
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: AlignmentDirectional.topCenter,
            end: AlignmentDirectional.bottomCenter,
            colors: <Color>[
              Colors.white,
              Color(0xFFE8EEFB),
            ],
          ),
        ),
        // Stack allows placing the app on top while we're awaiting layout
        child: Stack(
          children: <Widget>[
            ListView(
              controller: _scrollController,
              physics: SnapScrollPhysics(
                parent: const AlwaysScrollableScrollPhysics(),
                snaps: [
                  Snap.avoidZone(0, appTopPosition,
                      delimiter: math.min(appTopPosition * 2 / 3, 200)),
                  // from app top all the way to the end of list and beyond
                  Snap.avoidZone(appTopPosition, 9999),
                ],
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                MeasureSize(
                  onChange: (size, bounds) {
                    setState(() {
                      // input changed size, trigger build to update
                    });
                  },
                  child: const WiredashFeedbackFlow(),
                ),

                // Position of the app in the listview.
                // shown when layout is done and the entry animation
                // could be started
                if (_isLayoutingCompleted)
                  IntrinsicHeight(
                    child: Stack(
                      children: [
                        _buildAppPositioningAnimation(
                          offset: Offset(0, 100),
                          child: _buildAppFrame(
                            child: child,
                          ),
                        ),
                        Center(
                          child: Container(
                            width: 100,
                            height: 100,
                            color: Colors.red.withAlpha(20),
                          ),
                        )
                      ],
                    ),
                  ),
              ],
            ),
            // shows app on top while waiting for layouting of the ListView
            if (!_isLayoutingCompleted) ...<Widget>[
              child,
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildAppFrame({required Widget child}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        return SizedBox(
          height: MediaQuery.of(context).size.height,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _appCornerRadiusAnimation.value,
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.04),
                  offset: const Offset(0, 10),
                  blurRadius: 10,
                ),
                BoxShadow(
                  color: const Color(0xFF000000).withOpacity(0.10),
                  offset: const Offset(0, 20),
                  blurRadius: 25,
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: _appCornerRadiusAnimation.value,
              child: child,
            ),
          ),
        );
      },
      child: child,
    );
  }

  Widget _buildAppPositioningAnimation(
      {required Widget child, required Offset offset}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        final RenderBox? selfRenderBox =
            context.findRenderObject() as RenderBox?;
        final Offset? selfOffset = selfRenderBox?.localToGlobal(Offset.zero);
        final Size? size = selfRenderBox?.size;

        if (selfOffset != null && size != null) {
          final Rect rect = Rect.fromPoints(
              selfOffset, selfOffset.translate(size.width, size.height));
          if (savedRect != rect) {
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                savedRect = rect;
              });
            });
          }
        }

        print(_translateAppAnimation.value);
        return Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..scale(_scaleAppAnimation.value)
            ..translate(
              0.0 + offset.dx,
              (_translateAppAnimation.value * (selfOffset?.dy ?? 0)) +
                  offset.dy * (1 + _translateAppAnimation.value),
            ),
          child: child,
        );
      },
      child: child,
    );
  }
}