import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/physics.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/ui/app_overlay.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/pull_to_close_detector.dart';
import 'package:wiredash/src/responsive_layout.dart';

enum WiredashBackdropStatus {
  closed,

  /// The app is transitioning from [open] to [closing]
  closing,

  /// The app is transitioning from [closing] to [open]
  opening,

  /// the app is pinned to the bottom, partially hidden and non-interactive
  open,

  /// The app is transitioning from [open] to [centered]
  openingCentered,

  /// The app is transitioning from [centered] to [open]
  closingCentered,

  /// The app in floating in the center for screenshots
  centered,
}

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({
    Key? key,
    required this.child,
    required this.controller,
  }) : super(key: key);

  /// The wrapped app
  final Widget child;
  final BackdropController controller;

  static BackdropController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_WiredashBackdropState>();
    return state!.widget.controller;
  }

  @override
  State<WiredashBackdrop> createState() => _WiredashBackdropState();

  static const Duration animationDuration = Duration(milliseconds: 500);
}

class BackdropController extends ChangeNotifier {
  _WiredashBackdropState? _state;
  WiredashBackdropStatus _backdropStatus = WiredashBackdropStatus.closed;

  bool get isWiredashActive => _backdropStatus != WiredashBackdropStatus.closed;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  Animation<Rect?> get appPosition => _state!._transformAnimation;

  WiredashBackdropStatus get backdropStatus => _backdropStatus;

  set backdropStatus(WiredashBackdropStatus value) {
    _backdropStatus = value;
    notifyListeners();
  }

  Future<void> animateToOpen() async {
    _isAppInteractive = false;
    notifyListeners();

    await _state!._animateToOpen();
  }

  Future<void> animateToCentered() async {
    await _state!._animateToCentered();

    _isAppInteractive = true;
    notifyListeners();
  }

  Future<void> animateToClosed() async {
    await _state!._animateToClosed();

    _isAppInteractive = true;
    notifyListeners();
  }
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  late final ScrollController _scrollController = ScrollController();

  /// Main animation controller
  late final AnimationController _backdropAnimationController =
      AnimationController(
    vsync: this,
    duration: WiredashBackdrop.animationDuration,
  );

  /// Used for re-positioning the app on the screen
  late Animation<Rect?> _transformAnimation;

  /// Used for animating the corner radius of the app
  late Animation<BorderRadius?> _cornerRadiusAnimation;

  /// This CurvedAnimation is used for driving the transform and corner radius
  /// animation
  late final CurvedAnimation _driverAnimation = CurvedAnimation(
    parent: _backdropAnimationController,
    curve: Curves.easeOutCubic,
  );

  /// Detect window size changes in [didChangeDependencies]
  MediaQueryData _mediaQueryData = const MediaQueryData();

  /// calculated positions for the different backdrop positions / states
  Rect _rectAppDown = Rect.zero;
  Rect _rectAppCentered = Rect.zero;
  Rect _rectAppClosed = Rect.zero;

  /// The area the content is obstructed by the keyboard, notches or the app overlaying
  EdgeInsets _contentViewPadding = EdgeInsets.zero;

  WiredashBackdropStatus get _backdropStatus =>
      widget.controller.backdropStatus;

  set _backdropStatus(WiredashBackdropStatus value) =>
      widget.controller.backdropStatus = value;

  final FocusScopeNode _backdropContentFocusNode = FocusScopeNode();

  late AnimationController _pullAppYController;

  bool _pulling = false;

  @override
  void initState() {
    super.initState();
    widget.controller._state = this;
    _backdropAnimationController
        .addStatusListener(_animControllerStatusListener);
    _backdropAnimationController.addListener(_markAsDirty);
    _pullAppYController = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
      value: 0,
    )..addListener(_markAsDirty);

    widget.controller.addListener(_markAsDirty);
    _animCurves();
  }

  /// switch to lame linear curves that match the finger location exactly
  void _pullCurves() {
    _driverAnimation.curve = Curves.linear;
  }

  /// switch to cool bouncy curves
  void _animCurves() {
    _driverAnimation.curve = Curves.easeOutCubic;
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _backdropAnimationController.dispose();
    _backdropContentFocusNode.dispose();
    super.dispose();
  }

  Future<void> _animateToOpen() async {
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      _backdropStatus = WiredashBackdropStatus.opening;
    } else if (_backdropStatus == WiredashBackdropStatus.centered) {
      _backdropStatus = WiredashBackdropStatus.closingCentered;
    } else {
      throw "can't animate from state $_backdropStatus to `open`";
    }
    _swapAnimation();

    await _backdropAnimationController.forward();
  }

  Future<void> _animateToCentered() async {
    _backdropStatus = WiredashBackdropStatus.openingCentered;
    _swapAnimation();

    await _backdropAnimationController.forward();
  }

  Future<void> _animateToClosed() async {
    _backdropStatus = WiredashBackdropStatus.closing;
    _swapAnimation();

    await _backdropAnimationController.forward();
  }

  @override
  void reassemble() {
    super.reassemble();
    final oldAppUp = _rectAppDown;
    final oldAppCentered = _rectAppCentered;
    _calculateRects();
    if (oldAppUp != _rectAppDown &&
        _backdropStatus == WiredashBackdropStatus.open) {
      _backdropStatus = WiredashBackdropStatus.closed;
      _animateToOpen();
    }
    if (oldAppCentered != _rectAppCentered &&
        _backdropStatus == WiredashBackdropStatus.centered) {
      _backdropStatus = WiredashBackdropStatus.closed;
      _animateToCentered();
    }
  }

  /// (re-)calculates the rects for the different states
  void _calculateRects() {
    final Size screenSize = _mediaQueryData.size;

    final _maxCenteredWidth = screenSize.width -
        (context.responsiveLayout.horizontalMargin * 2 -
                _mediaQueryData.viewPadding.horizontal)
            .abs();
    final _maxCenteredHeight =
        screenSize.height - _mediaQueryData.viewPadding.vertical;
    final _biggestPossibleCenteredScaleFactor = math.min(
      _maxCenteredWidth / screenSize.width,
      _maxCenteredHeight / screenSize.height,
    );

    // TODO: Offset the center based on viewPaddings
    _rectAppCentered = Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: screenSize.width * _biggestPossibleCenteredScaleFactor,
      height: screenSize.height * _biggestPossibleCenteredScaleFactor,
    );

    final contentHeight = math.max(screenSize.height * 0.4, 300.0);
    final width = screenSize.width * _biggestPossibleCenteredScaleFactor;
    _rectAppDown = Rect.fromLTWH(
      (screenSize.width - width) / 2,
      contentHeight,
      width,
      screenSize.height * _biggestPossibleCenteredScaleFactor,
    );
    _contentViewPadding = EdgeInsets.fromLTRB(
      _mediaQueryData.padding.left,
      _mediaQueryData.padding.top,
      _mediaQueryData.padding.right,
      screenSize.height - contentHeight,
    );

    _rectAppClosed =
        Rect.fromPoints(Offset.zero, screenSize.bottomRight(Offset.zero));
  }

  /// Sets the correct animation for the current [_backdropStatus]
  void _swapAnimation() {
    _backdropAnimationController.reset();
    switch (_backdropStatus) {
      case WiredashBackdropStatus.open:
        _transformAnimation = RectTween(begin: _rectAppDown, end: _rectAppDown)
            .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closed:
        _transformAnimation =
            RectTween(begin: _rectAppClosed, end: _rectAppClosed)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(0),
          end: BorderRadius.circular(0),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.centered:
        _transformAnimation =
            RectTween(begin: _rectAppCentered, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.opening:
        _transformAnimation =
            RectTween(begin: _rectAppClosed, end: _rectAppDown)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(0),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closing:
        _transformAnimation =
            RectTween(begin: _rectAppDown, end: _rectAppClosed)
                .animate(_driverAnimation);
        _backdropAnimationController.value = 0.0;
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(0),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.openingCentered:
        _transformAnimation =
            RectTween(begin: _rectAppDown, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closingCentered:
        _transformAnimation =
            RectTween(begin: _rectAppCentered, end: _rectAppDown)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;
    }
  }

  void _animControllerStatusListener(AnimationStatus status) {
    if (status != AnimationStatus.completed) {
      return;
    }
    if (_pulling) {
      return;
    }
    setState(() {
      if (_backdropStatus == WiredashBackdropStatus.opening) {
        _backdropStatus = WiredashBackdropStatus.open;
      }
      if (_backdropStatus == WiredashBackdropStatus.openingCentered) {
        _backdropStatus = WiredashBackdropStatus.centered;
      }
      if (_backdropStatus == WiredashBackdropStatus.closingCentered) {
        _backdropStatus = WiredashBackdropStatus.open;
      }
      if (_backdropStatus == WiredashBackdropStatus.closing) {
        _backdropStatus = WiredashBackdropStatus.closed;
      }
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldMq = _mediaQueryData;
    final newMq = MediaQuery.of(context);
    _mediaQueryData = newMq;
    if (newMq.size != oldMq.size) {
      _calculateRects();
      _swapAnimation();
    }
  }

  @override
  void didUpdateWidget(WiredashBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller._state = null;
      oldWidget.controller.removeListener(_markAsDirty);
      widget.controller._state = this;
      widget.controller.addListener(_markAsDirty);
    }
  }

  void _markAsDirty() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    Widget app = widget.child;

    if (_backdropStatus == WiredashBackdropStatus.closed) {
      // Wiredash is closed, show the app without being wrapped in Transforms
      return app;
    }

    app = FocusScope(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: false,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: _KeepAppAlive(
        child: app,
      ),
    );

    final content = MediaQuery(
      data: _mediaQueryData.copyWith(padding: _contentViewPadding),
      // TODO check if this has to be wrapped with a FocusScope
      child: const WiredashFeedbackFlow(),
    );

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
            content,
            _buildAppPositioningAnimation(
              child: _buildAppFrame(
                child: app,
              ),
            ),
            _buildAppOverlay(),
          ],
        ),
      ),
    );
  }

  Widget _buildAppOverlay() {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _pullAppYController.value),
          child: AppOverlay(
            appRect: _transformAnimation.value!,
            borderRadius: _cornerRadiusAnimation.value!,
          ),
        );
      },
    );
  }

  /// Clips and adds shadow to the app
  ///
  /// Clipping is important because by default, widgets like [Banner] draw
  /// outside of the viewport
  Widget _buildAppFrame({required Widget? child}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        return Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: _mediaQueryData.size.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _cornerRadiusAnimation.value,
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
                  borderRadius: _cornerRadiusAnimation.value,
                  child: child,
                ),
              ),
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: () {
                  if (_backdropStatus == WiredashBackdropStatus.closing) {
                    return 0.0;
                  }
                  if (!widget.controller.isAppInteractive) {
                    return 1.0;
                  }
                  return 0.0;
                }(),
                child: const Icon(
                  WiredashIcons.cevronDownLight,
                  color: Colors.black26,
                ),
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }

  /// Animates the app from fullscreen to inline in the list
  Widget _buildAppPositioningAnimation({required Widget child}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, app) {
        final openedPosition = _rectAppDown.top;

        app = AbsorbPointer(
          absorbing: !widget.controller.isAppInteractive,
          child: app,
        );

        if (!widget.controller.isAppInteractive) {
          app = PullToCloseDetector(
            closeDirection: CloseDirection.upwards,
            onPullStart: () {
              _pulling = true;
              _backdropStatus = WiredashBackdropStatus.closing;
              _swapAnimation();
              _pullCurves();
              _pullAppYController.value = 0.0;
            },
            onPull: (delta) {
              setState(() {
                _pullAppYController.value += delta;
              });
            },
            startCloseSimulation: (velocity) async {
              _pulling = false;
              _backdropStatus = WiredashBackdropStatus.closing;
              _swapAnimation();
              _animCurves();
              final simApp = SpringSimulation(
                const SpringDescription(mass: 30, stiffness: 1, damping: 1),
                _backdropAnimationController.value,
                1.0,
                -velocity / openedPosition,
              );
              final a1 = _backdropAnimationController.animateWith(simApp);
              final a2 = _pullAppYController.animateTo(
                0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 400),
              );
              await Future.wait([a1, a2]);
              _backdropStatus = WiredashBackdropStatus.closed;
              _swapAnimation();
            },
            startReopenSimulation: (velocity) async {
              _pulling = false;
              _backdropStatus = WiredashBackdropStatus.opening;
              _swapAnimation();
              _animCurves();
              final simApp = SpringSimulation(
                const SpringDescription(mass: 30, stiffness: 1, damping: 1),
                1 - _backdropAnimationController.value,
                1.0,
                -velocity / openedPosition,
              );
              final a1 = _backdropAnimationController.animateWith(simApp);
              final a2 = _pullAppYController.animateTo(
                0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 400),
              );
              await Future.wait([a1, a2]);
              _backdropStatus = WiredashBackdropStatus.open;
              _swapAnimation();
            },
            child: app,
          );

          app = GestureDetector(
            onTap: () async {
              _pullCurves();
              await widget.controller.animateToClosed();
              _animCurves();
            },
            child: app,
          );
        }

        // ignore: join_return_with_assignment
        app = Positioned.fromRect(
          rect: _transformAnimation.value!,
          child: Transform.translate(
            offset: Offset(0, _pullAppYController.value),
            child: app,
          ),
        );

        return app;
      },
      child: child,
    );
  }
}

/// Keeps the app alive, even when not in viewport
class _KeepAppAlive extends StatefulWidget {
  const _KeepAppAlive({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  _KeepAppAliveState createState() => _KeepAppAliveState();
}

class _KeepAppAliveState extends State<_KeepAppAlive>
    with AutomaticKeepAliveClientMixin {
  @override
  Widget build(BuildContext context) {
    super.build(context);
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
