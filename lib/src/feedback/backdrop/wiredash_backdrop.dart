import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';
import 'package:wiredash/src/common/widgets/animated_fade_widget_switcher.dart';
import 'package:wiredash/src/feedback/backdrop/fake_app_status_bar.dart';
import 'package:wiredash/src/feedback/backdrop/pull_to_close_detector.dart';
import 'package:wiredash/src/feedback/ui/semi_transparent_statusbar.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({
    Key? key,
    required this.contentBuilder,
    required this.app,
    required this.controller,
    this.padding,
    this.backgroundLayerBuilder,
    this.foregroundLayerBuilder,
  }) : super(key: key);

  /// The wrapped app
  final Widget app;
  final BackdropController controller;
  final EdgeInsets? padding;
  final Widget Function(BuildContext) contentBuilder;
  final Widget? Function(
    BuildContext,
    Rect appRect,
    MediaQueryData mediaQueryData,
  )? backgroundLayerBuilder;
  final Widget? Function(
    BuildContext,
    Rect appRect,
    MediaQueryData mediaQueryData,
  )? foregroundLayerBuilder;

  static BackdropController of(BuildContext context) {
    final state = context.findAncestorStateOfType<_WiredashBackdropState>();
    return state!.widget.controller;
  }

  @override
  State<WiredashBackdrop> createState() => _WiredashBackdropState();

  static const Duration animationDuration = Duration(milliseconds: 500);
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
  WiredashThemeData _wiredashThemeData = WiredashThemeData();

  /// calculated positions for the different backdrop positions / states
  Rect _rectAppOutOfFocus = Rect.zero;
  Rect _rectAppCentered = Rect.zero;
  Rect _rectAppFillsScreen = Rect.zero;
  Rect _rectContentArea = Rect.zero;

  /// Saves the max keyboard height once detected to prevent jumping of the UI
  /// when keyboard opens/closes
  double _maxKeyboardHeight = 0.0;

  WiredashBackdropStatus get _backdropStatus =>
      widget.controller.backdropStatus;

  set _backdropStatus(WiredashBackdropStatus value) =>
      widget.controller.backdropStatus = value;

  late AnimationController _pullAppYController;

  bool _pulling = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addPostFrameCallback((timeStamp) {
      widget.controller._state = this;
    });
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

  @override
  void dispose() {
    widget.controller._state = null;
    widget.controller.removeListener(_markAsDirty);
    _backdropAnimationController.dispose();
    super.dispose();
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

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldMq = _mediaQueryData;
    final newMq = MediaQuery.of(context);
    _mediaQueryData = newMq;

    final oldTheme = _wiredashThemeData;
    final newTheme = context.theme;
    _wiredashThemeData = newTheme;

    if (newMq.size != oldMq.size ||
        oldTheme.horizontalPadding != newTheme.horizontalPadding ||
        oldTheme.verticalPadding != newTheme.verticalPadding ||
        oldTheme.maxContentWidth != newTheme.maxContentWidth ||
        // keyboard detection
        newMq.viewInsets != oldMq.viewInsets ||
        newMq.padding != oldMq.padding) {
      // Reduce the number of rect calculations by explicitly checking if
      // dependencies of _calculateRects changed.
      _calculateRects();
      _swapAnimation();
    }

    if (newMq.orientation != oldMq.orientation) {
      // soft keyboards have different heights based on the orientation
      _maxKeyboardHeight = 0.0;
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
    if (oldWidget.padding != widget.padding) {
      _calculateRects();
      _swapAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    final Widget child = widget.app;

    if (_backdropStatus == WiredashBackdropStatus.closed) {
      // Wiredash is closed, show the app without being wrapped in Transforms
      return child;
    }

    final app = Focus(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: widget.controller._isAppInteractive,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: _KeepAppAlive(
        child: child,
      ),
    );

    final content = Positioned.fromRect(
      rect: _rectContentArea,
      child: MediaQuery(
        data: _mediaQueryData.removePadding(removeBottom: true),
        child: Focus(
          debugLabel: 'wiredash backdrop content',
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: widget.controller.backdropStatus ==
                        WiredashBackdropStatus.centered ||
                    widget.controller.backdropStatus ==
                        WiredashBackdropStatus.openingCentered
                ? 0.0
                : 1.0,
            child: widget.contentBuilder(context),
          ),
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
      foreground: widget.foregroundLayerBuilder
          ?.call(context, _transformAnimation.value!, _mediaQueryData),
      background: widget.backgroundLayerBuilder
          ?.call(context, _transformAnimation.value!, _mediaQueryData),
    );

    return GestureDetector(
      onTap: () {
        // Close soft keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: SemiTransparentStatusBar(
        child: DecoratedBox(
          decoration: _backgroundDecoration(),
          child: Stack(
            children: [
              ..._debugRects(),
              ...stackChildren,
            ],
          ),
        ),
      ),
    );
  }

  /// (re-)calculates the rects for the different states
  void _calculateRects() {
    final wiredashPadding = widget.padding ?? EdgeInsets.zero;
    final mqPadding = _mediaQueryData.padding;
    final Size screenSize = _mediaQueryData.size;

    final centerPadding = EdgeInsets.only(
      top: 80 + math.max(mqPadding.top, wiredashPadding.top), // navigation bar
      bottom: 80 + math.max(mqPadding.bottom, wiredashPadding.top), // color bar
    );

    // scale to show app in safeArea
    final centerScaleFactor = () {
      // center
      final maxContentWidth = screenSize.width - centerPadding.horizontal;
      final maxContentHeight = screenSize.height - centerPadding.vertical;

      return math.min(
        maxContentWidth / screenSize.width,
        maxContentHeight / screenSize.height,
      );
    }();

    _rectAppCentered = Rect.fromLTWH(
      (screenSize.width - (screenSize.width * centerScaleFactor)) / 2,
      wiredashPadding.top + centerPadding.top,
      screenSize.width * centerScaleFactor,
      screenSize.height * centerScaleFactor,
    ).translate(wiredashPadding.left / 2 - wiredashPadding.right / 2, 0);

    // iPhone SE is 320 width
    const double minContentAreaHeight = 400.0;
    const double maxContentAreaHeight = 640.0;
    const double minAppPeakHeight = 56;

    // TODO check on android with soft keyboard and soft navigation keys
    final currentKeyboardHeight = _mediaQueryData.viewInsets.bottom;
    final bool isKeyboardOpen =
        currentKeyboardHeight.isRoughly(_maxKeyboardHeight, 0.2);
    _maxKeyboardHeight = math.max(currentKeyboardHeight, _maxKeyboardHeight);
    final keyboardHeight = () {
      if (isKeyboardOpen) {
        return _maxKeyboardHeight;
      } else if (screenSize.height - _maxKeyboardHeight <
          minContentAreaHeight) {
        // there's not enough space to always include the padding
        return 0;
      } else {
        // Always include the keyboardHeight, prevent flickering when there
        // is enough space
        return _maxKeyboardHeight;
      }
    }();

    // don't peak app on small screens in landscape when the keyboard is open
    final bool peakApp = !isKeyboardOpen ||
        (screenSize.height - minAppPeakHeight - _maxKeyboardHeight) >
            minContentAreaHeight;

    final double contentHeight =
        math.min(maxContentAreaHeight, screenSize.height - keyboardHeight) -
            (peakApp ? minAppPeakHeight : 0);

    _rectContentArea = Rect.fromLTWH(
      0,
      0,
      context.theme.maxContentWidth,
      contentHeight,
    )
        .removePadding(
          wiredashPadding.copyWith(bottom: 0),
        )
        .centerHorizontally(
          maxWidth: screenSize.width - wiredashPadding.horizontal,
          minPadding: context.theme.horizontalPadding,
        );

    _rectAppOutOfFocus = Rect.fromLTWH(
      0,
      _rectContentArea.bottom,
      screenSize.width,
      screenSize.height,
    )
        .centerHorizontally(
          maxWidth: screenSize.width - wiredashPadding.horizontal,
          minPadding: context.theme.horizontalPadding,
        )
        .translate(wiredashPadding.left, 0);

    final rectFullscreen =
        Rect.fromPoints(Offset.zero, screenSize.bottomRight(Offset.zero));
    _rectAppFillsScreen = Rect.fromLTRB(
      rectFullscreen.left + mqPadding.left,
      0,
      rectFullscreen.right - mqPadding.right,
      rectFullscreen.bottom + mqPadding.bottom - mqPadding.top,
    );
  }

  /// Reorders the stack items (z-index) depending on the backdrop state
  ///
  /// Keeps [navButtons] at the very top when possible. Moves the [app] to the
  /// top when interacting with it
  List<Widget> _orderStackChildren({
    required Widget app,
    required Widget content,
    required Widget? foreground,
    required Widget? background,
  }) {
    final keyedApp = KeyedSubtree(
      key: const ValueKey('app'),
      child: app,
    );
    final keyedContent = KeyedSubtree(
      key: const ValueKey('content'),
      child: content,
    );
    final keyedForeground = foreground != null
        ? KeyedSubtree(
            key: const ValueKey('app-foreground'),
            child: foreground,
          )
        : null;
    final keyedBackground = background != null
        ? KeyedSubtree(
            key: const ValueKey('app-background'),
            child: background,
          )
        : null;

    // Place buttons at the very top by default
    return [
      keyedContent,
      if (keyedBackground != null) keyedBackground,
      keyedApp,
      if (keyedForeground != null) keyedForeground,
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

  /// Returns the rects as colored widgets on screen
  List<Widget> _debugRects() {
    bool debug = false; // not touchy here, edit in assert
    assert(
      () {
        // enable debugging here
        debug = false;
        return true;
      }(),
    );

    if (!debug) return [];
    return [
      Positioned.fromRect(
        rect: _rectContentArea,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.yellow.withOpacity(0.5),
            ),
          ),
        ),
      ),
      Positioned.fromRect(
        rect: _rectAppOutOfFocus,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              color: Colors.blue.withOpacity(0.5),
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        top: 0,
        bottom: _mediaQueryData.size.height - _mediaQueryData.padding.top,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(
              color: Colors.orange,
            ),
          ),
        ),
      ),
      Positioned.fromRect(
        rect: _rectAppCentered,
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: Colors.red.withOpacity(0.5),
            ),
          ),
        ),
      ),
    ];
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
                  clipBehavior: Clip.antiAliasWithSaveLayer,
                  borderRadius: _cornerRadiusAnimation.value,
                  child: Stack(
                    children: [
                      ColoredBox(
                        color: context.theme.appBackgroundColor,
                        child: child,
                      ),
                      Positioned(
                        top: 0,
                        left: 0,
                        right: 0,
                        height: _mediaQueryData.viewPadding.top,
                        child: () {
                          final bool showBar = () {
                            if (_backdropStatus ==
                                WiredashBackdropStatus.closing) {
                              return false;
                            }
                            if (!widget.controller.isAppInteractive) {
                              return true;
                            }
                            return false;
                          }();
                          return AnimatedFadeWidgetSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: !showBar
                                ? null
                                : FakeAppStatusBar(
                                    height: _mediaQueryData.viewPadding.top,
                                  ),
                          );
                        }(),
                      ),
                    ],
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

  /// switch to lame linear curves that match the finger location exactly
  void _pullCurves() {
    _driverAnimation.curve = Curves.linear;
  }

  /// switch to cool bouncy curves
  void _animCurves() {
    _driverAnimation.curve = Curves.easeOutCubic;
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
              await context.wiredashModel.hide();
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
              await context.wiredashModel.hide();
              _animCurves();
            },
            child: app,
          );
        }

        // the difference of height between open and closed rect
        final yTranslation =
            _pullAppYController.value + _transformAnimation.value!.top;
        // The scale the app should be scaled to, compared to fullscreen
        final appScale =
            _transformAnimation.value!.width / _rectAppFillsScreen.width;

        // ignore: join_return_with_assignment
        app = Transform.translate(
          offset: Offset(
            ((widget.padding?.left ?? 0) - (widget.padding?.right ?? 0)) / 2,
            yTranslation,
          ),
          child: Transform.scale(
            scale: appScale,
            alignment: Alignment.topCenter,
            child: app,
          ),
        );

        return app;
      },
      child: child,
    );
  }

  Future<void> _animateToOpen() async {
    if (_backdropStatus == WiredashBackdropStatus.closed ||
        _backdropStatus == WiredashBackdropStatus.closing) {
      _backdropStatus = WiredashBackdropStatus.opening;
    } else if (_backdropStatus == WiredashBackdropStatus.centered ||
        _backdropStatus == WiredashBackdropStatus.openingCentered) {
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
      // already in correct state
      return;
    }
    if (_backdropStatus == WiredashBackdropStatus.closing) {
      // already playing correct anim
      return;
    }
    _backdropStatus = WiredashBackdropStatus.closing;
    _swapAnimation();

    await _backdropAnimationController.forward();
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

  void _markAsDirty() {
    setState(() {});
  }
}

/// Controls where the app is located in [WiredashBackdrop]
class BackdropController extends ChangeNotifier {
  bool get hasState {
    return _state != null;
  }

  _WiredashBackdropState? __state;
  _WiredashBackdropState? get _state => __state;
  set _state(_WiredashBackdropState? value) {
    __state = value;
    safeNotifyListeners();
  }

  WiredashBackdropStatus _backdropStatus = WiredashBackdropStatus.closed;

  @Deprecated('moved into wiredashmodel')
  bool get isWiredashActive => _backdropStatus != WiredashBackdropStatus.closed;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  Animation<Rect?> get appPosition => _state!._transformAnimation;

  WiredashBackdropStatus get backdropStatus => _backdropStatus;

  set backdropStatus(WiredashBackdropStatus value) {
    _backdropStatus = value;
    safeNotifyListeners();
  }

  Future<void> animateToOpen() async {
    _isAppInteractive = false;
    safeNotifyListeners();

    await _state!._animateToOpen();
    safeNotifyListeners();
  }

  Future<void> animateToCentered() async {
    _isAppInteractive = true;
    await _state!._animateToCentered();

    safeNotifyListeners();
  }

  Future<void> animateToClosed() async {
    await _state!._animateToClosed();

    _isAppInteractive = true;
    safeNotifyListeners();
  }

  /// Only calls [notifyListeners()] when
  void safeNotifyListeners() {
    if (__state != null) {
      notifyListeners();
    }
  }
}

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
      left + padding,
      top,
      maxWidth - padding * 2,
      height,
    );
  }
}

extension on double {
  // ignore: unused_element
  double clapWithin({required double min, required double max}) {
    return clamp(min, max) as double;
  }

  /// Returns true when [value] is within bounds of `this * `[fraction]
  bool isRoughly(num value, double fraction) {
    final delta = this * fraction;
    final upperBound = this + delta;
    final lowerBound = this - delta;
    return value > lowerBound && value < upperBound;
  }
}
