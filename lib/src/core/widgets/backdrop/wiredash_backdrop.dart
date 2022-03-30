import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:wiredash/src/core/support/widget_binding_support.dart';
import 'package:wiredash/src/core/theme/wiredash_theme.dart';
import 'package:wiredash/src/core/widgets/backdrop/fake_app_status_bar.dart';
import 'package:wiredash/src/core/widgets/backdrop/pull_to_close_detector.dart';
import 'package:wiredash/src/core/widgets/backdrop/safe_area_calculator.dart';
import 'package:wiredash/src/core/wiredash_model_provider.dart';
import 'package:wiredash/src/feedback/ui/semi_transparent_statusbar.dart';
import 'package:wiredash/src/utils/standard_kt.dart';
import 'package:wiredash/wiredash.dart';

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({
    Key? key,
    required this.contentBuilder,
    required this.app,
    required this.controller,
    this.backgroundLayerBuilder,
    this.foregroundLayerBuilder,
  }) : super(key: key);

  /// The wrapped app
  final Widget app;
  final BackdropController controller;
  final Widget Function(BuildContext) contentBuilder;

  /// Shown below the app, but above the backdrop [contentBuilder]
  final Widget? Function(
    BuildContext,
    Rect appRect,
    MediaQueryData mediaQueryData,
  )? backgroundLayerBuilder;

  /// Shown on top of the app
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
  Animation<Rect?>? _appTransformAnimation;

  /// Used for animating the corner radius of the app
  late Animation<BorderRadius?> _cornerRadiusAnimation;

  /// How much the app handle is visible
  late Animation<double> _appHandleAnimation;

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
    widgetsBindingInstance.addPostFrameCallback((timeStamp) {
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

  final BorderRadius _appBorderRadiusClosed = BorderRadius.zero;
  final BorderRadius _appBorderRadiusOpen = BorderRadius.circular(20);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final oldMq = _mediaQueryData;
    final newMq = MediaQuery.of(context);
    _mediaQueryData = newMq;

    final oldTheme = _wiredashThemeData;
    final newTheme = context.theme;
    _wiredashThemeData = newTheme;

    if (newMq.orientation != oldMq.orientation) {
      // soft keyboards have different heights based on the orientation
      _maxKeyboardHeight = 0.0;
    }

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
      // jump immediately to end of animation
      _backdropAnimationController.forward(from: 1.0);
    }
  }

  Size? _injectedContentSize;
  void _onContentSizeChanged(Size? size, {bool? animateSizeChange}) {
    if (_injectedContentSize?.height != size?.height) {
      _injectedContentSize = size;
      final oldAppOutOfFocusRect =
          _appTransformAnimation?.value ?? _rectAppOutOfFocus;
      final oldRectAppCentered =
          _appTransformAnimation?.value ?? _rectAppCentered;
      _calculateRects();
      // explicitly not calling _swapAnimation(), doing it manually
      _backdropAnimationController.reset();
      if (_backdropStatus == WiredashBackdropStatus.centered ||
          _backdropStatus == WiredashBackdropStatus.openingCentered) {
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppCentered)
                .animate(_driverAnimation);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
      } else {
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _appHandleAnimation = const AlwaysStoppedAnimation(1.0);
      }
      _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusOpen);
      _backdropAnimationController.forward(
        from: animateSizeChange == true ? 0 : 1,
      );
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
          ?.call(context, _appTransformAnimation!.value!, _mediaQueryData),
      background: widget.backgroundLayerBuilder
          ?.call(context, _appTransformAnimation!.value!, _mediaQueryData),
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
    final mqPadding = _mediaQueryData.padding;
    final Size screenSize = _mediaQueryData.size;

    final centerPadding = EdgeInsets.only(
      top: 80 + mqPadding.top, // navigation bar
      bottom: 80 + mqPadding.bottom, // color bar
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
      centerPadding.top,
      screenSize.width * centerScaleFactor,
      screenSize.height * centerScaleFactor,
    );

    const double minContentAreaHeight = 64;
    const double defaultContentAreaHeight = 320.0;
    // Could be anything really
    const double minAppPeakHeight = 56;

    // TODO check on android with soft keyboard and soft navigation keys
    final currentKeyboardHeight = _mediaQueryData.viewInsets.bottom;
    final bool isKeyboardOpen =
        currentKeyboardHeight.isRoughly(_maxKeyboardHeight, 0.2);
    _maxKeyboardHeight = math.max(currentKeyboardHeight, _maxKeyboardHeight);

    final calc = SafeAreaCalculator(screenSize: screenSize)
      ..addTopInset(mqPadding.top, 'paddintTop')
      ..addBottomInset(mqPadding.bottom, 'paddingBottom');

    if (isKeyboardOpen) {
      calc.addBottomInset(_maxKeyboardHeight, 'keyboardHeight');
    }

    // don't peak app on small screens, i.e. on phones in landscape when the
    // keyboard is open
    final remainingSpace = calc.rect.height;
    if (remainingSpace - minAppPeakHeight > minContentAreaHeight) {
      if (isKeyboardOpen) {
        calc.addBottomInset(
          _maxKeyboardHeight + minAppPeakHeight,
          'keyboard + appPeak',
        );
      } else {
        calc.addBottomInset(minAppPeakHeight, 'appPeak');
      }
    }

    final BoxConstraints preferredContentSize =
        _injectedContentSize?.let((it) => BoxConstraints.tight(it)) ??
            const BoxConstraints(
              minHeight: minContentAreaHeight,
              maxHeight: defaultContentAreaHeight,
            );
    final naturalContentSize = preferredContentSize
        .enforce(const BoxConstraints(minHeight: minContentAreaHeight));

    final safeAreaConstraints = BoxConstraints.loose(calc.size);

    final BoxConstraints constraints =
        naturalContentSize.enforce(safeAreaConstraints);

    final double contentHeight = constraints.maxHeight;

    _rectContentArea = Rect.fromLTWH(
      0,
      0,
      context.theme.maxContentWidth,
      // add top inset, allowing to draw below status bar
      // By using SafeArea inside content the height will be removed again
      contentHeight,
    ).centerHorizontally(
      maxWidth: screenSize.width,
      minPadding: context.theme.horizontalPadding,
    );

    _rectAppOutOfFocus = Rect.fromLTWH(
      0,
      _rectContentArea.bottom,
      screenSize.width,
      screenSize.height,
    ).centerHorizontally(
      maxWidth: screenSize.width,
      minPadding: context.theme.horizontalPadding,
    );

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
              width: 4,
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
        // status bar
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
      Positioned(
        left: 0,
        right: 0,
        // min size
        top: _mediaQueryData.padding.top + context.theme.minContentHeight,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.greenAccent.withOpacity(0.1),
            border: Border.all(
              color: Colors.greenAccent,
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        bottom: 0,
        // nav buttons
        top: _mediaQueryData.size.height - _mediaQueryData.padding.bottom,
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
      Positioned(
        left: 0,
        right: 0,
        // keyboard
        top: _mediaQueryData.size.height - _mediaQueryData.viewInsets.bottom,
        bottom: 0,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(
              color: Colors.orange,
            ),
          ),
        ),
      ),
    ];
  }

  final _handleHeight = () {
    if (kIsWeb) {
      return 36.0;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 44.0;
    } else {
      // TODO find a good value for windows/linux
      return 36.0;
    }
  }();

  /// Clips and adds shadow to the app
  ///
  /// Clipping is important because by default, widgets like [Banner] draw
  /// outside of the viewport
  Widget _buildAppFrame({required Widget? child}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        final withDesktopHandle = _mediaQueryData.viewPadding.top == 0;

        return SizedBox(
          height: _mediaQueryData.size.height + _handleHeight,
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
                    child: Stack(
                      children: [
                        if (withDesktopHandle)
                          Positioned(
                            top: 0,
                            left: 0,
                            right: 0,
                            child: ColoredBox(
                              color: context.theme.primaryColor,
                              child: SizedBox(
                                // +1 to prevent flickering
                                height:
                                    _appHandleAnimation.value * _handleHeight +
                                        1,
                                child: FakeAppStatusBar(
                                  height: _handleHeight,
                                ),
                              ),
                            ),
                          ),
                        Positioned(
                          top: withDesktopHandle
                              ? _appHandleAnimation.value * _handleHeight
                              : 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: child!,
                        ),
                      ],
                    ),
                  ),
                  if (!withDesktopHandle)
                    Positioned(
                      top: 0,
                      left: 0,
                      right: 0,
                      height: _mediaQueryData.viewPadding.top,
                      child: FadeTransition(
                        // TODO show some handle when in screencapture mode?
                        opacity: _appHandleAnimation,
                        child: FakeAppStatusBar(
                          height: _mediaQueryData.viewPadding.top,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
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
            _pullAppYController.value + _appTransformAnimation!.value!.top;
        // The scale the app should be scaled to, compared to fullscreen
        final appScale =
            _appTransformAnimation!.value!.width / _rectAppFillsScreen.width;

        // ignore: join_return_with_assignment
        app = Transform.translate(
          offset: Offset(0, yTranslation),
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

    // When cancelled, complete normally
    await _backdropAnimationController
        .forward()
        .orCancel
        .catchError((_) => null);
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
    // Capture intermediate values for smooth animations
    final oldAppOutOfFocusRect =
        _appTransformAnimation?.value ?? _rectAppOutOfFocus;
    final oldRectAppFillsScreen =
        _appTransformAnimation?.value ?? _rectAppFillsScreen;
    final oldRectAppCentered =
        _appTransformAnimation?.value ?? _rectAppCentered;

    // Reset current animation, if any
    _backdropAnimationController.reset();

    switch (_backdropStatus) {
      case WiredashBackdropStatus.open:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = const AlwaysStoppedAnimation(1.0);
        break;

      case WiredashBackdropStatus.closed:
        _appTransformAnimation =
            RectTween(begin: oldRectAppFillsScreen, end: _rectAppFillsScreen)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusClosed);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
        break;

      case WiredashBackdropStatus.centered:
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
        break;

      case WiredashBackdropStatus.opening:
        _appTransformAnimation =
            RectTween(begin: oldRectAppFillsScreen, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: _appBorderRadiusClosed,
          end: _appBorderRadiusOpen,
        ).animate(_driverAnimation);
        _appHandleAnimation =
            CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut);
        break;

      case WiredashBackdropStatus.closing:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppFillsScreen)
                .animate(_driverAnimation);
        _backdropAnimationController.value = 0.0;
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: _appBorderRadiusOpen,
          end: _appBorderRadiusClosed,
        ).animate(_driverAnimation);
        _appHandleAnimation = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
        break;

      case WiredashBackdropStatus.openingCentered:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
        break;

      case WiredashBackdropStatus.closingCentered:
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
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
    // Reset in case it got changed
    _backdropAnimationController.duration = WiredashBackdrop.animationDuration;
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

  _WiredashBackdropState? _stateField;
  _WiredashBackdropState? get _state => _stateField;

  Size? _contentSize;
  Size? get contentSize => _contentSize;
  set contentSize(Size? value) {
    if (_contentSize != value) {
      _contentSize = value;
      _state?._onContentSizeChanged(
        _contentSize,
        animateSizeChange: animateSizeChange,
      );
      animateSizeChange = false;
      safeNotifyListeners();
    }
  }

  bool animateSizeChange = false;

  set _state(_WiredashBackdropState? value) {
    _stateField = value;
    safeNotifyListeners();
  }

  WiredashBackdropStatus _backdropStatus = WiredashBackdropStatus.closed;

  @Deprecated('moved into wiredashmodel')
  bool get isWiredashActive => _backdropStatus != WiredashBackdropStatus.closed;

  bool get isAppInteractive => _isAppInteractive;
  bool _isAppInteractive = false;

  Animation<Rect?> get appPosition => _state!._appTransformAnimation!;

  WiredashBackdropStatus get backdropStatus => _backdropStatus;

  set backdropStatus(WiredashBackdropStatus value) {
    _backdropStatus = value;
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      _contentSize = null;
    }
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
    if (_stateField != null) {
      notifyListeners();
    }
  }

  @mustCallSuper
  @override
  void dispose() {
    _state = null;
    super.dispose();
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
  // ignore: unused_element
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
