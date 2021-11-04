import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/pull_to_close_detector.dart';
import 'package:wiredash/src/responsive_layout.dart';
import 'package:wiredash/src/sprung.dart';
import 'package:wiredash/src/wiredash_provider.dart';

bool _firstOpenAnimOnMetal = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

enum WiredashBackdropStatus {
  closed,

  /// The app is transitioning from [open] to [closing]
  closing,

  /// The app is transitioning from [closing] to [open]
  opening,

  /// the app is pinned to the top, mostly hidden and non-interactive
  open,

  /// The app is transitioning from [open] to [intermediate]
  openingIntermediate,

  /// The app is transitioning from [intermediate] to [open]
  closingIntermediate,

  /// The app in floating in the center for screenshots
  intermediate,
}

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

  static const Duration animationDuration = Duration(milliseconds: 500);
}

class BackdropController {
  _WiredashBackdropState? _state;

  Future<void> animateToOpen() async {
    await _state!._animateToOpen();
  }

  Future<void> animateToIntermediate() async {
    await _state!._animateToIntermediate();
  }

  Future<void> animateToClosed() async {
    await _state!._animateToClosed();
  }
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  final GlobalKey _childAppKey =
      GlobalKey<State<StatefulWidget>>(debugLabel: 'app');

  WiredashBackdropStatus _backdropStatus = WiredashBackdropStatus.closed;

  late final ScrollController _scrollController = ScrollController();

  /// Main animation controller
  late final AnimationController _backdropAnimationController =
      AnimationController(
    vsync: this,
    duration: WiredashBackdrop.animationDuration,
    reverseDuration: WiredashBackdrop.animationDuration,
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
    reverseCurve: Curves.easeOutCubic,
  );

  /// Detect window size changes in [didChangeDependencies]
  MediaQueryData _mediaQueryData = MediaQueryData();

  final FocusNode _feedbackFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  static const double _appPeak = 130;

  final slightlyUnderdumped = Sprung(18);

  /// calculated positions for the different backdrop positions / states
  Rect _rectAppUp = Rect.zero;
  Rect _rectAppIntermediate = Rect.zero;
  Rect _rectAppDown = Rect.zero;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _backdropAnimationController
        .addStatusListener(_animControllerStatusListener);

    _animCurves();
  }

  /// switch to lame linear curves that match the finger location exactly
  void _pullCurves() {
    _driverAnimation.curve = Curves.linear;
    _driverAnimation.reverseCurve = Curves.linear;
  }

  /// switch to cool bouncy curves
  void _animCurves() {
    _driverAnimation.curve = Curves.easeOutCubic;
    // _driverAnimation.reverseCurve = slightlyUnderdumped.flipped;
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _backdropAnimationController.dispose();
    _feedbackFocusNode.dispose();
    _emailFocusNode.dispose();
  }

  Future<void> _animateToOpen() async {
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      _backdropStatus = WiredashBackdropStatus.opening;
    } else if (_backdropStatus == WiredashBackdropStatus.intermediate) {
      _backdropStatus = WiredashBackdropStatus.closingIntermediate;
    } else {
      throw "can't animate from state $_backdropStatus to `open`";
    }
    _swapAnimation();

    _feedbackFocusNode.requestFocus();
    await _backdropAnimationController.forward(from: 0);
  }

  Future<void> _animateToIntermediate() async {
    _backdropStatus = WiredashBackdropStatus.openingIntermediate;
    _swapAnimation();

    await _backdropAnimationController.forward(from: 0);
  }

  Future<void> _animateToClosed() async {
    _backdropStatus = WiredashBackdropStatus.closing;
    _swapAnimation();

    await _backdropAnimationController.forward(from: 0);
  }

  @override
  void reassemble() {
    super.reassemble();
    final oldAppUp = _rectAppUp;
    final oldAppIntermediate = _rectAppIntermediate;
    _calculateRects();
    if (oldAppUp != _rectAppUp &&
        _backdropStatus == WiredashBackdropStatus.open) {
      _backdropStatus = WiredashBackdropStatus.closed;
      _animateToOpen();
    }
    if (oldAppIntermediate != _rectAppIntermediate &&
        _backdropStatus == WiredashBackdropStatus.intermediate) {
      _backdropStatus = WiredashBackdropStatus.closed;
      _animateToIntermediate();
    }
  }

  /// (re-)calculates the rects for the different states
  void _calculateRects() {
    final Size screenSize = _mediaQueryData.size;

    final _maxIntermediateWidth = screenSize.width -
        (context.responsiveLayout.horizontalMargin * 2 -
                _mediaQueryData.viewPadding.horizontal)
            .abs();
    final _maxIntermediateHeight =
        screenSize.height - _mediaQueryData.viewPadding.vertical;
    final _biggestPossibleIntermediateScaleFactor = math.min(
      _maxIntermediateWidth / screenSize.width,
      _maxIntermediateHeight / screenSize.height,
    );

    // TODO: Offset the center based on viewPaddings
    _rectAppIntermediate = Rect.fromCenter(
      center: screenSize.center(Offset.zero),
      width: screenSize.width * _biggestPossibleIntermediateScaleFactor,
      height: screenSize.height * _biggestPossibleIntermediateScaleFactor,
    );

    final translateY = -screenSize.height +
        _rectAppIntermediate.top +
        _appPeak -
        _mediaQueryData.viewPadding.top;
    _rectAppUp = _rectAppIntermediate.translate(0, translateY);

    _rectAppDown =
        Rect.fromPoints(Offset.zero, screenSize.bottomRight(Offset.zero));
  }

  /// Sets the correct animation for the current [_backdropStatus]
  void _swapAnimation() {
    _backdropAnimationController.stop(canceled: false);
    switch (_backdropStatus) {
      case WiredashBackdropStatus.open:
        _transformAnimation = RectTween(begin: _rectAppUp, end: _rectAppUp)
            .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closed:
        _transformAnimation = RectTween(begin: _rectAppDown, end: _rectAppDown)
            .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(0),
          end: BorderRadius.circular(0),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.intermediate:
        _transformAnimation =
            RectTween(begin: _rectAppIntermediate, end: _rectAppIntermediate)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.opening:
        _transformAnimation = RectTween(begin: _rectAppDown, end: _rectAppUp)
            .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(0),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closing:
        _transformAnimation = RectTween(begin: _rectAppUp, end: _rectAppDown)
            .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(0),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.openingIntermediate:
        _transformAnimation =
            RectTween(begin: _rectAppUp, end: _rectAppIntermediate)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closingIntermediate:
        _transformAnimation =
            RectTween(begin: _rectAppIntermediate, end: _rectAppUp)
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
    setState(() {
      if (_backdropStatus == WiredashBackdropStatus.opening) {
        _backdropStatus = WiredashBackdropStatus.open;
      }
      if (_backdropStatus == WiredashBackdropStatus.openingIntermediate) {
        _backdropStatus = WiredashBackdropStatus.intermediate;
      }
      if (_backdropStatus == WiredashBackdropStatus.closingIntermediate) {
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
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget app = KeyedSubtree(
      key: _childAppKey,
      child: widget.child,
    );

    if (_backdropStatus == WiredashBackdropStatus.closed) {
      // Wiredash is closed, show the app without being wrapped in Transforms
      return app;
    }

    final model = context.wiredashModel;
    app = FocusScope(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: false,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: _KeepAppAlive(
        child: app,
      ),
    );
    final mediaQueryData = MediaQuery.of(context);
    final bottomInset = mediaQueryData.viewInsets.bottom;

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
            Padding(
              // Don't show content behind keyboard
              padding: EdgeInsets.only(bottom: bottomInset),
              child: WiredashFeedbackFlow(
                focusNode: _feedbackFocusNode,
              ),
            ),
            _buildAppPositioningAnimation(
              child: _buildAppFrame(child: app),
            ),
            Positioned(
              bottom: 16,
              left: 16,
              right: 16,
              child: AnimatedOpacity(
                duration: const Duration(milliseconds: 300),
                opacity: () {
                  if (_backdropStatus ==
                      WiredashBackdropStatus.closingIntermediate) {
                    return 0.0;
                  }
                  if (_backdropStatus == WiredashBackdropStatus.intermediate ||
                      _backdropStatus ==
                          WiredashBackdropStatus.openingIntermediate) {
                    return 1.0;
                  }
                  return 0.0;
                }(),
                child: BigBlueButton(
                  icon: Icon(WiredashIcons.check),
                  text: Text('Close'),
                  onTap: () {
                    if (_backdropStatus ==
                        WiredashBackdropStatus.intermediate) {
                      context.wiredashModel.exitCaptureMode();
                    }
                  },
                ),
              ),
            )
          ],
        ),
      ),
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
                  if (context.wiredashModel.isWiredashClosing) {
                    return 0.0;
                  }
                  if (!context.wiredashModel.isAppInteractive) {
                    return 1.0;
                  }
                  return 0.0;
                }(),
                child: Icon(
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
  Widget _buildAppPositioningAnimation({
    required Widget child,
  }) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, app) {
        final screenHeight = _mediaQueryData.size.height;
        final topInset = _mediaQueryData.viewInsets.top;

        final topPosition = -screenHeight + _appPeak + topInset;
        final translationY = topPosition * _driverAnimation.value;

        app = AbsorbPointer(
          absorbing: !context.wiredashModel.isAppInteractive,
          child: app!,
        );

        if (!context.wiredashModel.isAppInteractive) {
          app = PullToCloseDetector(
            animController: _backdropAnimationController,
            distanceToBottom: translationY.abs(),
            topPosition: topPosition.abs(),
            onPullStart: () {
              _backdropStatus = WiredashBackdropStatus.opening;
              _swapAnimation();
              _pullCurves();
            },
            onPullEnd: () {
              _animCurves();
            },
            onClosed: () async {
              context.wiredashModel.detectClosed();
              _backdropStatus = WiredashBackdropStatus.closed;
            },
            onClosing: () {
              context.wiredashModel.detectClosing();
              _backdropStatus = WiredashBackdropStatus.closing;
            },
            child: app,
          );

          app = GestureDetector(
            onTap: () async {
              _pullCurves();
              await context.wiredashModel.hide();
              _animCurves();
            },
            child: app,
          );
        }

        app = Positioned.fromRect(
          rect: _transformAnimation.value!,
          child: app,
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
