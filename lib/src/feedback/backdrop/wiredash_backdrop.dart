import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/feedback/backdrop/pull_to_close_detector.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/feedback_navigation.dart';

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
    this.padding,
  }) : super(key: key);

  /// The wrapped app
  final Widget child;
  final BackdropController controller;
  final EdgeInsets? padding;

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
    notifyListeners();
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
  Rect _rectAppOutOfFocus = Rect.zero;
  Rect _rectAppCentered = Rect.zero;
  Rect _rectAppFillsScreen = Rect.zero;
  Rect _rectContentArea = Rect.zero;
  Rect _rectNavigationButtons = Rect.zero;

  WiredashBackdropStatus get _backdropStatus =>
      widget.controller.backdropStatus;

  set _backdropStatus(WiredashBackdropStatus value) =>
      widget.controller.backdropStatus = value;

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
    _backdropAnimationController.dispose();
    super.dispose();
  }

  Future<void> _animateToOpen() async {
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      _backdropStatus = WiredashBackdropStatus.opening;
    } else if (_backdropStatus == WiredashBackdropStatus.centered) {
      _backdropStatus = WiredashBackdropStatus.closingCentered;
    } else {
      // no need for animating, we're already in a desired state
      return;
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
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      return;
    }
    _backdropStatus = WiredashBackdropStatus.closing;
    _swapAnimation();

    await _backdropAnimationController.forward();
  }

  @override
  void reassemble() {
    super.reassemble();
    final oldAppOutOfFocus = _rectAppOutOfFocus;
    final oldAppCentered = _rectAppCentered;
    _calculateRects();
    if (oldAppOutOfFocus != _rectAppOutOfFocus &&
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
    final wiredashPadding = widget.padding ?? EdgeInsets.zero;
    final Size screenSize = _mediaQueryData.size;

    // scale to show app in safeArea
    final centerScaleFactor = () {
      // center
      final minContentWidthPadding = context.theme.horizontalPadding * 2;
      final maxContentWidth = screenSize.width -
          math.max(
            wiredashPadding.horizontal,
            math.max(
              _mediaQueryData.viewPadding.horizontal,
              minContentWidthPadding,
            ),
          );

      final maxContentHeight = screenSize.height -
          math.max(
            0,
            // wiredashPadding.vertical,
            _mediaQueryData.viewPadding.vertical,
          );

      return math.min(
        maxContentWidth / screenSize.width,
        maxContentHeight / screenSize.height,
      );
    }();

    _rectAppCentered = Rect.fromCenter(
      center: screenSize.center(Offset.zero) +
          _mediaQueryData.viewInsets.topLeft / 2 +
          wiredashPadding.topLeft / 2,
      width: screenSize.width * centerScaleFactor,
      height: screenSize.height * centerScaleFactor,
    );

    // iPhone SE is 320 width
    const double minContentAreaHeight = 320.0;
    const double maxContentAreaHeight = 640.0;
    const double minAppPeakHeight = 56;

    final double buttonBarHeight = context.theme.buttonBarHeight;
    final bool isKeyboardOpen = _mediaQueryData.viewInsets.bottom > 100;

    // center the navigation buttons
    var preferredAppHeight = _mediaQueryData.size.height * 0.5;
    if (!isKeyboardOpen) {
      preferredAppHeight -= minAppPeakHeight;
      preferredAppHeight -= buttonBarHeight / 2;
      preferredAppHeight -= wiredashPadding.top / 2;
    }
    final preferredContentHeight =
        _mediaQueryData.size.height - preferredAppHeight;

    final contentHeightWithButtons = math.max(
      math.min(preferredContentHeight, maxContentAreaHeight),
      minContentAreaHeight,
    );
    // On super small screen (landscape phones) scale to 0 and
    // make 100% sure the appPeak is visible
    final double contentHeight =
        math.min(contentHeightWithButtons, screenSize.height) -
            minAppPeakHeight;

    _rectContentArea = Rect.fromLTWH(
      0,
      0,
      context.theme.maxContentWidth,
      contentHeight - buttonBarHeight,
    ).removePadding(wiredashPadding.copyWith(bottom: 0)).centerHorizontally(
          maxWidth: screenSize.width,
          minPadding: context.theme.horizontalPadding,
        );

    _rectAppOutOfFocus = Rect.fromLTWH(
      0,
      contentHeight,
      screenSize.width * centerScaleFactor,
      screenSize.height * centerScaleFactor,
    ).centerHorizontally(
      maxWidth: screenSize.width,
      minPadding: context.theme.horizontalPadding,
    );

    _rectNavigationButtons = Rect.fromLTWH(
      _rectAppOutOfFocus.left,
      _rectContentArea.bottom,
      _rectAppOutOfFocus.width,
      buttonBarHeight,
    );

    _rectAppFillsScreen =
        Rect.fromPoints(Offset.zero, screenSize.bottomRight(Offset.zero));
  }

  /// Sets the correct animation for the current [_backdropStatus]
  void _swapAnimation() {
    _backdropAnimationController.reset();
    switch (_backdropStatus) {
      case WiredashBackdropStatus.open:
        _transformAnimation =
            RectTween(begin: _rectAppOutOfFocus, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closed:
        _transformAnimation =
            RectTween(begin: _rectAppFillsScreen, end: _rectAppFillsScreen)
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
            RectTween(begin: _rectAppFillsScreen, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(0),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closing:
        _transformAnimation =
            RectTween(begin: _rectAppOutOfFocus, end: _rectAppFillsScreen)
                .animate(_driverAnimation);
        _backdropAnimationController.value = 0.0;
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(0),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.openingCentered:
        _transformAnimation =
            RectTween(begin: _rectAppOutOfFocus, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: BorderRadius.circular(20),
          end: BorderRadius.circular(20),
        ).animate(_driverAnimation);
        break;

      case WiredashBackdropStatus.closingCentered:
        _transformAnimation =
            RectTween(begin: _rectAppCentered, end: _rectAppOutOfFocus)
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
    if (newMq.size != oldMq.size ||
        // keyboard detection
        newMq.viewInsets != oldMq.viewInsets) {
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

    app = Focus(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: widget.controller._isAppInteractive,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: _KeepAppAlive(
        child: app,
      ),
    );

    final content = Positioned.fromRect(
      rect: _rectContentArea,
      child: MediaQuery(
        data: _mediaQueryData.removePadding(removeBottom: true),
        child: const Focus(
          debugLabel: 'wiredash backdrop content',
          child: WiredashFeedbackFlow(),
        ),
      ),
    );

    final stackChildren = _orderStackChildren(
      app: _buildAppPositioningAnimation(
        child: _buildAppFrame(
          child: app,
        ),
      ),
      content: content,
      navButtons: _buildNavigationButtons(),
    );

    return DecoratedBox(
      decoration: _backgroundDecoration(),
      child: Stack(
        children: stackChildren,
      ),
    );
  }

  /// Reorders the stack items (z-index) depending on the backdrop state
  ///
  /// Keeps [navButtons] at the very top when possible. Moves the [app] to the
  /// top when interacting with it
  List<Widget> _orderStackChildren({
    required Widget app,
    required Widget content,
    required Widget navButtons,
  }) {
    final keyedApp = KeyedSubtree(
      key: const ValueKey('app'),
      child: app,
    );
    final keyedContent = KeyedSubtree(
      key: const ValueKey('content'),
      child: content,
    );
    final keyedNav = KeyedSubtree(
      key: const ValueKey('nav'),
      child: navButtons,
    );

    if (_backdropStatus == WiredashBackdropStatus.closing ||
        _backdropStatus == WiredashBackdropStatus.opening) {
      // Move app above nav buttons
      return [
        keyedContent,
        keyedNav,
        keyedApp,
      ];
    }

    // Place buttons at the very top by default
    return [
      keyedContent,
      keyedApp,
      keyedNav,
    ];
  }

  /// Wiredash background based on a linear gradient
  BoxDecoration _backgroundDecoration() {
    return BoxDecoration(
      gradient: LinearGradient(
        begin: AlignmentDirectional.topCenter,
        end: AlignmentDirectional.bottomCenter,
        colors: <Color>[
          context.theme.primaryBackgroundColor,
          context.theme.secondaryBackgroundColor,
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return AnimatedOpacity(
      duration: const Duration(milliseconds: 150),
      opacity: _backdropStatus == WiredashBackdropStatus.closing ? 0.0 : 1.0,
      child: FeedbackNavigation(
        defaultLocation: _rectNavigationButtons,
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
        final double barContentHeight =
            math.min(12, _mediaQueryData.viewPadding.top);
        return Stack(
          fit: StackFit.passthrough,
          clipBehavior: Clip.none,
          children: [
            SizedBox(
              height: _mediaQueryData.size.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: _cornerRadiusAnimation.value,
                  color: context.theme.appBackgroundColor,
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
              top: 0,
              left: 0,
              right: 0,
              height: _mediaQueryData.viewPadding.top,
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
                child: DefaultTextStyle(
                  style: TextStyle(
                    shadows: const [
                      Shadow(
                        offset: Offset(2, 2),
                        blurRadius: 2,
                        color: Color.fromARGB(30, 0, 0, 0),
                      ),
                    ],
                    color: Colors.white,
                    fontSize: barContentHeight,
                  ),
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: _cornerRadiusAnimation.value!.copyWith(
                        bottomLeft: Radius.zero,
                        bottomRight: Radius.zero,
                      ),
                      color: Colors.black12,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 2,
                      ),
                      child: Stack(
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.5,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  Image.asset(
                                    'assets/images/logo_white.png',
                                    package: 'wiredash',
                                    height: barContentHeight,
                                  ),
                                  const SizedBox(width: 8),
                                  const Text('Wiredash'),
                                ],
                              ),
                            ),
                          ),
                          const Center(
                            child: Text('Return to App'),
                          ),
                        ],
                      ),
                    ),
                  ),
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
        final outOfFocusPosition = _rectAppOutOfFocus.top;

        app = AbsorbPointer(
          absorbing: !widget.controller.isAppInteractive,
          child: app,
        );

        if (!widget.controller.isAppInteractive) {
          app = PullToCloseDetector(
            closeDirection: CloseDirection.upwards,
            onPullStart: () {
              setState(() {
                _pulling = true;
                _backdropStatus = WiredashBackdropStatus.closing;
              });
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
                -velocity / outOfFocusPosition,
              );
              final a1 = _backdropAnimationController.animateWith(simApp);
              final a2 = _pullAppYController.animateTo(
                0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 600),
              );
              widget.controller._isAppInteractive = true;
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
                -velocity / outOfFocusPosition,
              );
              final a1 = _backdropAnimationController.animateWith(simApp);
              final a2 = _pullAppYController.animateTo(
                0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 600),
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

        // the difference of height between open and closed rect
        final heightDifference =
            _rectAppFillsScreen.height - _transformAnimation.value!.height;
        final yTranslation = _pullAppYController.value +
            _transformAnimation.value!.top -
            heightDifference;
        // The scale the app should be scaled to, compared to fullscreen
        final appScale =
            _transformAnimation.value!.width / _rectAppFillsScreen.width;

        // ignore: join_return_with_assignment
        app = Transform.translate(
          offset: Offset(0, yTranslation),
          child: Transform.scale(
            scale: appScale,
            alignment: Alignment.bottomCenter,
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

extension on Rect {
  Rect removePadding(EdgeInsets padding) {
    return padding.deflateRect(this);
  }

  Rect centerHorizontally({required double maxWidth, double minPadding = 0.0}) {
    double padding = (maxWidth - width) / 2;
    if (padding < minPadding) {
      padding = minPadding;
    }
    return Rect.fromLTWH(
      padding,
      top,
      maxWidth - padding * 2,
      height,
    );
  }
}