import 'dart:async';
import 'dart:math' as math;
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';
import 'package:wiredash/src/capture/drawer/drawer.dart';
import 'package:wiredash/src/capture/screenshot/screenshot.dart';
import 'package:wiredash/src/capture/sketcher/sketcher.dart';
import 'package:wiredash/src/capture/sketcher/sketcher_controller.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/utils/diagonal_shape_painter.dart';
import 'package:wiredash/src/common/widgets/corner_radius_transition.dart';
import 'package:wiredash/src/common/widgets/simple_button.dart';
import 'package:wiredash/src/common/widgets/spotlight.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

const int _animationDuration = 350;

enum CaptureUiState { hidden, navigate, draw }

class Capture extends StatefulWidget {
  const Capture({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  CaptureState createState() => CaptureState();
}

class CaptureState extends State<Capture>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _spotlightKey = GlobalKey<SpotlightState>();

  AnimationController _animationControllerScreen;
  AnimationController _animationControllerDrawer;

  Size _screenSize;
  EdgeInsets _windowPadding;
  double _scaleFactor;
  double _contentBottomOffset;

  Animation<double> _scaleAnimation;
  Animation<double> _cornerRadiusAnimation;
  Animation<double> _contentSlideUpAnimation;
  Animation<double> _drawPanelSlideAnimation;
  Listenable _masterListenable;

  Completer<Uint8List> _captureCompleter;
  ValueNotifier<CaptureUiState> _captureUiState;
  SketcherController _sketcherController;
  ValueNotifier<bool> _visible;

  ui.Image _screenshot;
  Uint8List _screenshotSketch;

  @override
  void initState() {
    super.initState();
    _animationControllerScreen = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _animationDuration),
    );

    _animationControllerDrawer = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: _animationDuration),
    );

    _captureUiState = ValueNotifier(CaptureUiState.hidden);
    _sketcherController = SketcherController();
    _visible = ValueNotifier(false);

    _captureUiState.addListener(() {
      switch (_captureUiState.value) {
        case CaptureUiState.hidden:
          _visible.value = false;
          break;
        case CaptureUiState.navigate:
          _visible.value = true;
          break;
        case CaptureUiState.draw:
          _visible.value = true;
          break;
      }
    });

    _updateDimensions();
    _initAnimations();

    WidgetsBinding.instance.addObserver(this);
  }

  void _updateDimensions() {
    final window = WidgetsBinding.instance.window;
    _windowPadding = EdgeInsets.fromWindowPadding(
        window.viewPadding, window.devicePixelRatio);
    _screenSize = window.physicalSize / window.devicePixelRatio;

    final widthRestriction = Drawer.width + _windowPadding.horizontal;
    final heightRestriction = 80 + _windowPadding.vertical; // Bottom Bar height

    final targetContentWidth = _screenSize.width - widthRestriction;
    final targetContentHeight = _screenSize.height - heightRestriction;

    _scaleFactor = math.min(targetContentWidth / _screenSize.width,
        targetContentHeight / _screenSize.height);

    _contentBottomOffset = 80 + _windowPadding.bottom;
  }

  void _initAnimations() {
    final curvedScreenAnimation = CurvedAnimation(
        parent: _animationControllerScreen, curve: Curves.fastOutSlowIn);

    final curvedDrawerAnimation = CurvedAnimation(
        parent: _animationControllerDrawer, curve: Curves.fastOutSlowIn);

    _scaleAnimation =
        Tween(begin: 1.0, end: _scaleFactor).animate(curvedScreenAnimation);

    _cornerRadiusAnimation =
        Tween(begin: 0.0, end: 1.0).animate(curvedScreenAnimation);

    _contentSlideUpAnimation = Tween(begin: 0.0, end: _contentBottomOffset)
        .animate(curvedScreenAnimation);

    _drawPanelSlideAnimation = Tween(begin: 0.0, end: Drawer.width * 0.4)
        .animate(curvedDrawerAnimation);

    _masterListenable =
        Listenable.merge([_scaleAnimation, _drawPanelSlideAnimation]);
  }

  @override
  void didChangeMetrics() {
    setState(() {
      // Update when MediaQuery properties change
      _updateDimensions();
      _initAnimations();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _animationControllerScreen.dispose();
    _animationControllerDrawer.dispose();
    _captureUiState.dispose();
    _sketcherController.dispose();
    _visible.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final directionalityFactor =
        Directionality.of(context) == TextDirection.ltr ? 1.0 : -1.0;
    return MultiProvider(
      providers: [
        ValueListenableProvider.value(value: _captureUiState),
        ChangeNotifierProvider.value(value: _sketcherController)
      ],
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: <Widget>[
          CustomPaint(
            painter: DiagonalShapePainter(
              color: WiredashTheme.of(context).secondaryBackgroundColor,
              padding: _windowPadding.bottom,
            ),
            child: const SizedBox.expand(),
          ),
          _buildBottomMenu(),
          // --- Capture Menu
          AnimatedBuilder(
            animation: _drawPanelSlideAnimation,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..translate(
                    directionalityFactor * _drawPanelSlideAnimation.value,
                    -_contentBottomOffset,
                  )
                  ..scale(_scaleFactor),
                child: child,
              );
            },
            child: _buildDrawer(),
          ),
          // --- Capture Content
          AnimatedBuilder(
            animation: _masterListenable,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..translate(
                    directionalityFactor * -_drawPanelSlideAnimation.value,
                    -_contentSlideUpAnimation.value,
                  )
                  ..scale(_scaleAnimation.value),
                child: child,
              );
            },
            child: _buildContent(),
          )
        ],
      ),
    );
  }

  Widget _buildDrawer() {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: WiredashTheme.of(context).secondaryBackgroundColor,
        border: Border.all(
          color: WiredashTheme.of(context).dividerColor,
          width: 2,
        ),
      ),
      child: Container(
        alignment: AlignmentDirectional.centerEnd,
        child: Drawer(),
      ),
    );
  }

  Widget _buildContent() {
    return Consumer<CaptureUiState>(
      builder: (_, uiState, __) {
        return CornerRadiusTransition(
          radius: _cornerRadiusAnimation,
          child: Spotlight(
            key: _spotlightKey,
            child: Sketcher(
              isEnabled: uiState == CaptureUiState.draw,
              controller: _sketcherController,
              child: Screenshot(
                capture: uiState == CaptureUiState.draw,
                onCaptured: (image) => _screenshot = image,
                child: widget.child,
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildBottomMenu() {
    return Consumer<CaptureUiState>(builder: (context, uiState, child) {
      return SafeArea(
        minimum: const EdgeInsets.all(20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: SimpleButton(
                mainAxisAlignment: MainAxisAlignment.start,
                onPressed: _onBackButtonPressed,
                text: _getBackButtonString(),
              ),
            ),
            Expanded(
              child: SimpleButton(
                mainAxisAlignment: MainAxisAlignment.end,
                onPressed: _onNextButtonPressed,
                text: _getNextButtonString(),
                icon: _getNextButtonIcon(),
              ),
            ),
          ],
        ),
      );
    });
  }

  void _onBackButtonPressed() {
    switch (_captureUiState.value) {
      case CaptureUiState.hidden:
        // Don't do anything
        break;
      case CaptureUiState.navigate:
        _animateToHidden();
        break;
      case CaptureUiState.draw:
        _animateToNavigate();
        break;
    }
  }

  String _getBackButtonString() {
    switch (_captureUiState.value) {
      case CaptureUiState.navigate:
        return WiredashLocalizations.of(context).captureSkip;
      case CaptureUiState.draw:
        return WiredashLocalizations.of(context).feedbackBack;
      default:
        return '';
    }
  }

  void _onNextButtonPressed() {
    switch (_captureUiState.value) {
      case CaptureUiState.hidden:
        // Don't do anything
        break;
      case CaptureUiState.navigate:
        _animateToDraw();
        break;
      case CaptureUiState.draw:
        _takeScreenshotAndHide();
        break;
    }
  }

  TickerFuture _animateToHidden() {
    _sketcherController.clearGestures();
    _captureUiState.value = CaptureUiState.hidden;

    _captureCompleter.complete(_screenshotSketch);
    _captureCompleter = null;
    _screenshot = null;
    _screenshotSketch = null;

    _spotlightKey.currentState.hide();
    _animationControllerDrawer.reverse();
    return _animationControllerScreen.reverse();
  }

  void _animateToNavigate() {
    _sketcherController.clearGestures();
    _captureUiState.value = CaptureUiState.navigate;

    _animationControllerScreen.forward();
    _animationControllerDrawer.reverse();
    _spotlightKey.currentState.show(
      WiredashIcons.spotlightMove,
      WiredashLocalizations.of(context)
          .captureSpotlightNavigateTitle
          .toLowerCase(),
      WiredashLocalizations.of(context).captureSpotlightNavigateMsg,
    );
  }

  void _animateToDraw() {
    _captureUiState.value = CaptureUiState.draw;

    _animationControllerScreen.forward();
    _animationControllerDrawer.forward();
    _spotlightKey.currentState.show(
      WiredashIcons.spotlightDraw,
      WiredashLocalizations.of(context)
          .captureSpotlightScreenCapturedTitle
          .toUpperCase(),
      WiredashLocalizations.of(context).captureSpotlightScreenCapturedMsg,
    );
  }

  String _getNextButtonString() {
    switch (_captureUiState.value) {
      case CaptureUiState.navigate:
        return WiredashLocalizations.of(context).captureTakeScreenshot;
      case CaptureUiState.draw:
        return WiredashLocalizations.of(context).captureSaveScreenshot;
      default:
        return '';
    }
  }

  IconData _getNextButtonIcon() {
    switch (_captureUiState.value) {
      case CaptureUiState.navigate:
      case CaptureUiState.draw:
        return WiredashIcons.right;
      default:
        return null;
    }
  }

  Future<void> _takeScreenshotAndHide() async {
    _screenshotSketch = await _sketcherController.recordOntoImage(_screenshot);
    _animateToHidden();
  }

  Future<Uint8List> show() {
    _animateToNavigate();
    _captureCompleter = Completer<Uint8List>();
    return _captureCompleter.future;
  }

  ValueNotifier<bool> get visible => _visible;
}
