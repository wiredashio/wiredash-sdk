import 'dart:async';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/physics.dart';
import 'package:wiredash/src/core/support/back_button_interceptor.dart';
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
    super.key,
    required this.contentBuilder,
    required this.app,
    required this.controller,
    this.padding,
    this.backgroundLayerBuilder,
    this.foregroundLayerBuilder,
  });

  /// The wrapped app
  final Widget app;
  final BackdropController controller;
  final EdgeInsets? padding;
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

  /// Gains access to the [BackdropController] from children of
  /// [WiredashBackdrop] via the element tree
  static BackdropController of(BuildContext context) => maybeOf(context)!;

  /// Gains access to the [BackdropController] from children of
  /// [WiredashBackdrop] via the element tree. Returns `null` if
  /// [WiredashBackdrop] is not a parent in the widget tree.
  static BackdropController? maybeOf(BuildContext context) {
    final state = context.findAncestorStateOfType<_WiredashBackdropState>();
    return state?.widget.controller;
  }

  @override
  State<WiredashBackdrop> createState() => _WiredashBackdropState();

  static const double topBarHeight = 80;
  static const double bottomBarHeight = 80;
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  /// Main animation controller
  late final AnimationController _backdropAnimationController =
      AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 500),
    debugLabel: 'backdropAnimationController',
  );

  /// Used for re-positioning the app on the screen
  Animation<Rect?>? _appTransformAnimation;

  /// Used for animating the corner radius of the app
  Animation<BorderRadius?> _cornerRadiusAnimation =
      const AlwaysStoppedAnimation(_appBorderRadiusClosed);

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

  /// the key for the app
  final GlobalKey _appKey = GlobalKey(debugLabel: 'WiredashBackdrop app');

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
    _pullAppYController = AnimationController(
      vsync: this,
      lowerBound: double.negativeInfinity,
      upperBound: double.infinity,
      value: 0,
    );

    widget.controller.addListener(_markAsDirty);
    _animCurves();
  }

  @override
  void dispose() {
    widget.controller._state = null;
    _backdropStatus = WiredashBackdropStatus.closed;
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

  static const BorderRadius _appBorderRadiusClosed = BorderRadius.zero;
  static const BorderRadius _appBorderRadiusOpen =
      BorderRadius.all(Radius.circular(20));

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

      if (_backdropStatus == WiredashBackdropStatus.centered) {
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppCentered)
                .animate(_driverAnimation);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
      } else {
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
      }
      if (_backdropStatus == WiredashBackdropStatus.open) {
        _appHandleAnimation = const AlwaysStoppedAnimation(1.0);
      }
      if (_backdropStatus == WiredashBackdropStatus.closed) {
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
      }
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

    if (oldWidget.padding != widget.padding) {
      _calculateRects();
      _swapAnimation();
    }
  }

  @override
  Widget build(BuildContext context) {
    // Prevent widgets from being recreated unnecessarily when app
    // becomes interactive
    final Widget child = KeyedSubtree(
      key: _appKey,
      child: widget.app,
    );

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

    final double opacity = () {
      if (widget.controller.backdropStatus == WiredashBackdropStatus.centered ||
          widget.controller.backdropStatus ==
              WiredashBackdropStatus.openingCentered) {
        return 0.0;
      }
      return 1.0;
    }();

    final content = Positioned.fromRect(
      rect: _rectContentArea,
      child: MediaQuery(
        data: _mediaQueryData
            .copyWith(
              padding: _mediaQueryData.padding
                  .max(widget.padding ?? EdgeInsets.zero),
            )
            // remove the padding from the content area
            .removePadding(
              removeBottom: true,
              removeLeft: true,
              removeRight: true,
            ),
        child: Focus(
          debugLabel: 'wiredash backdrop content',
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 300),
            opacity: opacity,
            child: IgnorePointer(
              ignoring: opacity == 0,
              child: widget.contentBuilder(context),
            ),
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
      foreground: () {
        final builder = widget.foregroundLayerBuilder;
        if (builder == null) {
          return null;
        }
        return AnimatedBuilder(
          animation: _appTransformAnimation!,
          builder: (context, child) {
            final widget = builder(
              context,
              _appTransformAnimation!.value!,
              _mediaQueryData,
            );
            return widget ?? const SizedBox();
          },
        );
      }(),
      background: () {
        final builder = widget.backgroundLayerBuilder;
        if (builder == null) {
          return null;
        }
        return AnimatedBuilder(
          animation: _appTransformAnimation!,
          builder: (context, child) {
            final widget = builder(
              context,
              _appTransformAnimation!.value!,
              _mediaQueryData,
            );
            return widget ?? const SizedBox();
          },
        );
      }(),
    );

    return GestureDetector(
      onTap: () {
        // Close soft keyboard
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: BackButtonInterceptor(
        onBackPressed: () {
          switch (_backdropStatus) {
            case WiredashBackdropStatus.closed:
            case WiredashBackdropStatus.closing:
              // Nothing to do, allow app to handle the back button
              return BackButtonAction.ignored;

            case WiredashBackdropStatus.opening:
            case WiredashBackdropStatus.open:
            case WiredashBackdropStatus.closingCentered:
              // in open position, close wiredash
              context.wiredashModel.hide();
              return BackButtonAction.consumed;

            case WiredashBackdropStatus.openingCentered:
            case WiredashBackdropStatus.centered:
              // currently centered, go back to open
              widget.controller.animateToOpen();
              return BackButtonAction.consumed;
          }
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
      bottom:
          80 + math.max(mqPadding.bottom, wiredashPadding.bottom), // color bar
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
      math.max(wiredashPadding.top, centerPadding.top),
      screenSize.width * centerScaleFactor,
      screenSize.height * centerScaleFactor,
    ).translate(wiredashPadding.left / 2 - wiredashPadding.right / 2, 0);

    const double minContentAreaHeight = 64;
    const double defaultContentAreaHeight = 320.0;

    final currentKeyboardHeight = _mediaQueryData.viewInsets.bottom;
    final bool isKeyboardOpen =
        currentKeyboardHeight.isRoughly(_maxKeyboardHeight, 0.2);
    _maxKeyboardHeight = math.max(currentKeyboardHeight, _maxKeyboardHeight);

    final contentCalc = SafeAreaCalculator(screenSize: screenSize)
      // ignoring top paddings because the content can draw behind or has to
      // use a SafeArea
      ..addTopInset(mqPadding.top, 'mediaQueryPadding top')
      ..addTopInset(wiredashPadding.top, 'wiredashPadding top')
      ..addBottomInset(mqPadding.bottom, 'mediaQueryPadding bottom')
      ..addBottomInset(wiredashPadding.bottom, 'wiredashPadding bottom');

    if (isKeyboardOpen) {
      contentCalc.addBottomInset(_maxKeyboardHeight, 'keyboardHeight');
    }

    final remainingSpace = contentCalc.rect.height;

    // positioning the app at the bottom works without bottom insets
    final appCalc = contentCalc.withoutBottomInsets();

    final double minAppPeakHeight =
        remainingSpace < defaultContentAreaHeight ? 16 : 56;

    if (!isKeyboardOpen) {
      // Always peak app when the keybaord is not open
      contentCalc.addBottomInset(minAppPeakHeight, 'appPeak');
      appCalc.addBottomInset(minAppPeakHeight, 'appPeak');
    }

    // don't peak app on small screens, i.e. on phones in landscape when the
    // keyboard is open
    if (isKeyboardOpen && remainingSpace > defaultContentAreaHeight) {
      // when there's enough space peak app above keyboard
      contentCalc.addBottomInset(
        _maxKeyboardHeight + minAppPeakHeight,
        'keyboard + appPeak',
      );
    }

    final BoxConstraints preferredContentSize =
        _injectedContentSize?.let((it) => BoxConstraints.tight(it)) ??
            const BoxConstraints(
              minHeight: minContentAreaHeight,
              maxHeight: defaultContentAreaHeight,
            );
    final naturalContentSize = preferredContentSize
        .enforce(const BoxConstraints(minHeight: minContentAreaHeight));

    final BoxConstraints contentConstraints =
        naturalContentSize.enforce(BoxConstraints.loose(contentCalc.size));
    final BoxConstraints appConstraints =
        naturalContentSize.enforce(BoxConstraints.loose(appCalc.size));

    final double contentHeight = contentConstraints.maxHeight;

    _rectContentArea = Rect.fromLTWH(
      wiredashPadding.left,
      0,
      context.theme.maxContentWidth,
      contentHeight + contentCalc.topInset,
    ).centerHorizontally(
      maxWidth: screenSize.width - wiredashPadding.horizontal,
      minPadding: context.theme.horizontalPadding,
    );

    _rectAppOutOfFocus = Rect.fromLTWH(
      0,
      appConstraints.maxHeight,
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: 4,
              // ignore: deprecated_member_use
              color: Colors.yellow.withOpacity(0.5),
            ),
          ),
        ),
      ),
      Positioned.fromRect(
        rect: _rectAppOutOfFocus,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              width: 3,
              // ignore: deprecated_member_use
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
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
        top: 0,
        // padding top
        height: widget.padding?.top ?? 0,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.pink.withOpacity(0.1),
            border: Border.all(
              color: Colors.pink,
            ),
          ),
        ),
      ),
      Positioned(
        left: 0,
        right: 0,
        // min size
        top: _mediaQueryData.padding.top + context.theme.minContentHeight,
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(
              color: Colors.orange,
            ),
          ),
        ),
      ),
      Positioned.fromRect(
        rect: _rectAppCentered,
        child: DecoratedBox(
          decoration: BoxDecoration(
            border: Border.all(
              // ignore: deprecated_member_use
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
        child: DecoratedBox(
          decoration: BoxDecoration(
            // ignore: deprecated_member_use
            color: Colors.orange.withOpacity(0.1),
            border: Border.all(
              color: Colors.orange,
            ),
          ),
        ),
      ),
    ];
  }

  static const double _minHandleHeight = 20;

  double get _handleHeight {
    final topPadding = _mediaQueryData.padding.top;
    if (topPadding > 0) {
      return math.max(_minHandleHeight, topPadding);
    }
    if (kIsWeb) {
      return 36.0;
    } else if (defaultTargetPlatform == TargetPlatform.macOS) {
      return 44.0;
    } else {
      return 36.0;
    }
  }

  /// Clips and adds shadow to the app
  ///
  /// Clipping is important because by default, widgets like [Banner] draw
  /// outside of the viewport
  Widget _buildAppFrame({required Widget? child}) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        // rounds _handleHeight up to exactly match
        double scaledAndUpRoundedHandleHeight() {
          final appScale =
              _appTransformAnimation!.value!.width / _rectAppFillsScreen.width;
          final scaledHandleHeight = _handleHeight * appScale;
          final reverseScale = 1.0 / appScale;
          // this prevents flickering
          final standardRoundedHandleHeight =
              scaledHandleHeight.ceil().toDouble() * reverseScale;
          return standardRoundedHandleHeight.ceil().toDouble();
        }

        final withDesktopHandle = _mediaQueryData.viewPadding.top == 0;

        final fakeAppStatusBar = FakeAppStatusBar(
          height: _appHandleAnimation.value * scaledAndUpRoundedHandleHeight(),
          color: context.theme.appHandleBackgroundColor,
        );

        return SizedBox(
          height: _mediaQueryData.size.height + _handleHeight,
          child: DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: _cornerRadiusAnimation.value,
              boxShadow: [
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF000000).withOpacity(0.04),
                  offset: const Offset(0, 10),
                  blurRadius: 10,
                ),
                BoxShadow(
                  // ignore: deprecated_member_use
                  color: const Color(0xFF000000).withOpacity(0.10),
                  offset: const Offset(0, 20),
                  blurRadius: 25,
                ),
              ],
            ),
            child: ClipRRect(
              clipBehavior: Clip.antiAliasWithSaveLayer,
              borderRadius: _cornerRadiusAnimation.value ?? BorderRadius.zero,
              child: Stack(
                children: [
                  ColoredBox(
                    color: context.theme.appBackgroundColor,
                    child: Stack(
                      children: [
                        Positioned(
                          top: withDesktopHandle
                              ? _appHandleAnimation.value * _handleHeight
                              : 0,
                          left: 0,
                          right: 0,
                          bottom: 0,
                          child: ClipRect(
                            child: Opacity(
                              opacity: 1 - (_appHandleAnimation.value * 0.4),
                              child: child,
                            ),
                          ),
                        ),
                        if (withDesktopHandle)
                          Align(
                            alignment: Alignment.topCenter,
                            child: fakeAppStatusBar,
                          ),
                      ],
                    ),
                  ),
                  if (!withDesktopHandle)
                    FadeTransition(
                      opacity: _appHandleAnimation,
                      child: fakeAppStatusBar,
                    ),
                  // Overlay app with colored overlay to indicate inactivity
                  Positioned.fill(
                    child: IgnorePointer(
                      child: Opacity(
                        opacity: _appHandleAnimation.value,
                        child: ColoredBox(
                          color: context.theme.appHandleBackgroundColor
                              // ignore: deprecated_member_use
                              .withOpacity(0.1),
                        ),
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
      animation:
          Listenable.merge([_backdropAnimationController, _pullAppYController]),
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
                -velocity / outOfFocusPosition,
              );
              final a1 = _backdropAnimationController.animateWith(simApp);
              final a2 = _pullAppYController.animateTo(
                0,
                curve: Curves.easeOutExpo,
                duration: const Duration(milliseconds: 600),
              );
              final wiredashModel = context.wiredashModel;
              widget.controller._isAppInteractive = true;
              _closeAnim = a2;
              await Future.wait([a1, a2]);
              _closeAnim = null;
              _backdropStatus = WiredashBackdropStatus.closed;
              await wiredashModel.hide();
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
              _openAnim = a2;
              await Future.wait([a1, a2]);
              _openAnim = null;
              _backdropStatus = WiredashBackdropStatus.open;
              _swapAnimation();
            },
            child: app,
          );

          app = GestureDetector(
            onTap: () async {
              await context.wiredashModel.hide();
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

        // center in padding
        final horizontalOffset =
            ((widget.padding?.left ?? 0) - (widget.padding?.right ?? 0)) / 2;

        // ignore: join_return_with_assignment
        app = Transform.translate(
          offset: Offset(horizontalOffset, yTranslation),
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

  TickerFuture? _openAnim;

  Future<void> _animateToOpen() async {
    _animCurves();
    if (_backdropStatus == WiredashBackdropStatus.opening) {
      // already opening, return running animation
      return _openAnim!.orCancel.catchError((_) => null);
    }

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

    _openAnim = _backdropAnimationController.forward(from: 0);
    // When cancelled, complete normally
    await _openAnim!.orCancel.catchError((_) => null);
    _openAnim = null;
  }

  Future<void> _animateToCentered() async {
    _backdropStatus = WiredashBackdropStatus.openingCentered;
    _swapAnimation();

    await _backdropAnimationController.forward(from: 0);
  }

  TickerFuture? _closeAnim;

  Future<void> _animateToClosed() async {
    _animCurves();
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      // already in correct state
      return;
    }
    if (_backdropStatus == WiredashBackdropStatus.closing) {
      // already closing, return running animation
      return _closeAnim!.orCancel.catchError((_) => null);
    }
    if (_backdropStatus == WiredashBackdropStatus.opening) {
      _appHandleAnimation = Tween(begin: 0.0, end: 1.0).animate(
        CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
      );
      _backdropStatus = WiredashBackdropStatus.closing;
      _closeAnim = _backdropAnimationController.reverse();
      return _closeAnim!.orCancel.catchError((_) => null);
    } else {
      _backdropStatus = WiredashBackdropStatus.closing;
      _swapAnimation();
    }

    _closeAnim = _backdropAnimationController.forward(from: 0);
    // When cancelled, complete normally
    await _closeAnim!.orCancel.catchError((_) => null);
    _closeAnim = null;
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

    switch (_backdropStatus) {
      case WiredashBackdropStatus.open:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation =
            const AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = const AlwaysStoppedAnimation(1.0);
        break;

      case WiredashBackdropStatus.closed:
        _appTransformAnimation =
            RectTween(begin: oldRectAppFillsScreen, end: _rectAppFillsScreen)
                .animate(_driverAnimation);
        _cornerRadiusAnimation =
            const AlwaysStoppedAnimation(_appBorderRadiusClosed);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
        break;

      case WiredashBackdropStatus.centered:
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation =
            const AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = const AlwaysStoppedAnimation(0.0);
        break;

      case WiredashBackdropStatus.opening:
        _appTransformAnimation =
            RectTween(begin: oldRectAppFillsScreen, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: _cornerRadiusAnimation.value,
          end: _appBorderRadiusOpen,
        ).animate(
          CurvedAnimation(
            parent: _driverAnimation,
            curve: const Interval(0.3, 0.7),
          ),
        );
        _appHandleAnimation = Tween(begin: 0.0, end: 1.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
        break;

      case WiredashBackdropStatus.closing:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppFillsScreen)
                .animate(_driverAnimation);
        _backdropAnimationController.value = 0.0;
        _cornerRadiusAnimation = BorderRadiusTween(
          begin: _cornerRadiusAnimation.value,
          end: _appBorderRadiusClosed,
        ).animate(
          CurvedAnimation(
            parent: _driverAnimation,
            curve: const Interval(0.3, 0.7),
          ),
        );
        _appHandleAnimation = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
        break;

      case WiredashBackdropStatus.openingCentered:
        _appTransformAnimation =
            RectTween(begin: oldAppOutOfFocusRect, end: _rectAppCentered)
                .animate(_driverAnimation);
        _cornerRadiusAnimation =
            const AlwaysStoppedAnimation(_appBorderRadiusOpen);
        _appHandleAnimation = Tween(begin: 1.0, end: 0.0).animate(
          CurvedAnimation(parent: _driverAnimation, curve: Curves.easeInOut),
        );
        break;

      case WiredashBackdropStatus.closingCentered:
        _appTransformAnimation =
            RectTween(begin: oldRectAppCentered, end: _rectAppOutOfFocus)
                .animate(_driverAnimation);
        _cornerRadiusAnimation =
            const AlwaysStoppedAnimation(_appBorderRadiusOpen);
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
    if (_backdropStatus == WiredashBackdropStatus.opening) {
      setState(() {
        _backdropStatus = WiredashBackdropStatus.open;
      });
    }
    if (_backdropStatus == WiredashBackdropStatus.openingCentered) {
      setState(() {
        _backdropStatus = WiredashBackdropStatus.centered;
      });
    }
    if (_backdropStatus == WiredashBackdropStatus.closingCentered) {
      setState(() {
        _backdropStatus = WiredashBackdropStatus.open;
      });
    }
    if (_backdropStatus == WiredashBackdropStatus.closing) {
      setState(() {
        _backdropStatus = WiredashBackdropStatus.closed;
      });
    }
    _swapAnimation();
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
    if (_backdropStatus == WiredashBackdropStatus.closed) {
      return;
    }
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
  const _KeepAppAlive({required this.child});

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

extension on EdgeInsets {
  EdgeInsets max(EdgeInsets other) {
    return EdgeInsets.fromLTRB(
      math.max(left, other.left),
      math.max(top, other.top),
      math.max(right, other.right),
      math.max(bottom, other.bottom),
    );
  }
}
