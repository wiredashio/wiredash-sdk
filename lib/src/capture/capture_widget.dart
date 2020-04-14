import 'dart:math' as math;

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/drawer/drawer.dart';
import 'package:wiredash/src/capture/sketcher/sketcher.dart';
import 'package:wiredash/src/capture/state/capture_state.dart';
import 'package:wiredash/src/capture/state/capture_state_data.dart';
import 'package:wiredash/src/common/state/wiredash_state.dart';
import 'package:wiredash/src/common/state/wiredash_state_data.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
import 'package:wiredash/src/common/utils/diagonal_shape_painter.dart';
import 'package:wiredash/src/common/widgets/corner_radius_transition.dart';
import 'package:wiredash/src/common/widgets/simple_button.dart';
import 'package:wiredash/src/common/widgets/spotlight.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

const int _animationDuration = 350;

class CaptureWidget extends StatefulWidget {
  const CaptureWidget({
    Key key,
    @required this.child,
  })  : assert(child != null),
        super(key: key);

  final Widget child;

  @override
  CaptureWidgetState createState() => CaptureWidgetState();
}

class CaptureWidgetState extends State<CaptureWidget>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  final _sketcherKey = GlobalKey<SketcherState>();
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

  final _captureState = CaptureStateData();

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

    _updateDimensions();
    _initAnimations();

    _captureState.addListener(didCaptureStateChange);
    WidgetsBinding.instance.addObserver(this);
  }

  void _updateDimensions() {
    final window = WidgetsBinding.instance.window;
    _windowPadding = EdgeInsets.fromWindowPadding(
        window.viewPadding, window.devicePixelRatio);
    _screenSize = window.physicalSize / window.devicePixelRatio;

    final widthRestriction = CaptureDrawer.width + _windowPadding.horizontal;
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

    _drawPanelSlideAnimation = Tween(begin: 0.0, end: CaptureDrawer.width * 0.4)
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

  void didCaptureStateChange() {
    setState(() {
      // Call setState to notify children which depend on CaptureState
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _captureState.removeListener(didCaptureStateChange);

    _animationControllerScreen.dispose();
    _animationControllerDrawer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CaptureState(
      data: _captureState,
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
                    _drawPanelSlideAnimation.value,
                    -_contentBottomOffset,
                  )
                  ..scale(_scaleFactor),
                child: child,
              );
            },
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                color: WiredashTheme.of(context).secondaryBackgroundColor,
                border: Border.all(
                  color: WiredashTheme.of(context).dividerColor,
                  width: 2,
                ),
              ),
              child: Container(
                alignment: Alignment.centerRight,
                child: CaptureDrawer(),
              ),
            ),
          ),
          // --- Capture Content
          AnimatedBuilder(
            animation: _masterListenable,
            builder: (context, child) {
              return Transform(
                alignment: Alignment.bottomCenter,
                transform: Matrix4.identity()
                  ..translate(
                    -_drawPanelSlideAnimation.value,
                    -_contentSlideUpAnimation.value,
                  )
                  ..scale(_scaleAnimation.value),
                child: child,
              );
            },
            child: CornerRadiusTransition(
              radius: _cornerRadiusAnimation,
              child: Spotlight(
                key: _spotlightKey,
                child: Sketcher(
                  key: _sketcherKey,
                  isEnabled: _captureState.status == CaptureStatus.draw,
                  color: _captureState.selectedPenColor,
                  child: widget.child,
                ),
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget _buildBottomMenu() {
    return SafeArea(
      minimum: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          SimpleButton(
            onPressed: _onBackButtonPressed,
            text: _getBackButtonString(),
          ),
          SimpleButton(
            onPressed: _onNextButtonPressed,
            text: _getNextButtonString(),
            icon: _getNextButtonIcon(),
          ),
        ],
      ),
    );
  }

  void _onBackButtonPressed() {
    switch (_captureState.status) {
      case CaptureStatus.hidden:
        // Don't do anything
        break;
      case CaptureStatus.navigate:
        _hide().then((_) {
          WiredashState.of(context).feedbackState = FeedbackState.feedback;
        });
        break;
      case CaptureStatus.draw:
        _animationControllerDrawer.reverse();
        _captureState.status = CaptureStatus.navigate;
        break;
    }
  }

  String _getBackButtonString() {
    switch (_captureState.status) {
      case CaptureStatus.navigate:
        return WiredashTranslation.of(context).captureSkip;
      case CaptureStatus.draw:
        return WiredashTranslation.of(context).captureBack;
      default:
        return '';
    }
  }

  void _onNextButtonPressed() {
    switch (_captureState.status) {
      case CaptureStatus.hidden:
        // Don't do anything
        break;
      case CaptureStatus.navigate:
        _animationControllerDrawer.forward();
        _spotlightKey.currentState.show(
          WiredashIcons.spotlightDraw,
          WiredashTranslation.of(context)
              .captureSpotlightScreenCapturedTitle
              .toUpperCase(),
          WiredashTranslation.of(context).captureSpotlightScreenCapturedMsg,
        );

        _captureState.status = CaptureStatus.draw;
        break;
      case CaptureStatus.draw:
        _takeScreenshot();
        break;
    }
  }

  String _getNextButtonString() {
    switch (_captureState.status) {
      case CaptureStatus.navigate:
        return WiredashTranslation.of(context).captureTakeScreenshot;
      case CaptureStatus.draw:
        return WiredashTranslation.of(context).captureSaveScreenshot;
      default:
        return '';
    }
  }

  IconData _getNextButtonIcon() {
    switch (_captureState.status) {
      case CaptureStatus.navigate:
      case CaptureStatus.draw:
        return WiredashIcons.right;
      default:
        return null;
    }
  }

  Future<void> _takeScreenshot() async {
    final screenshot = await _sketcherKey.currentState.getSketch();
    final wiredashState = WiredashState.of(context, listen: false);

    _hide();
    wiredashState.feedbackScreenshot = screenshot;
    wiredashState.feedbackState = FeedbackState.feedback;
  }

  TickerFuture _hide() {
    _captureState.status = CaptureStatus.hidden;

    _spotlightKey.currentState.hide();
    _animationControllerDrawer.reverse();
    return _animationControllerScreen.reverse();
  }

  void show() {
    _captureState.status = CaptureStatus.navigate;

    _animationControllerScreen.forward();
    _spotlightKey.currentState.show(
      WiredashIcons.spotlightMove,
      WiredashTranslation.of(context)
          .captureSpotlightNavigateTitle
          .toLowerCase(),
      WiredashTranslation.of(context).captureSpotlightNavigateMsg,
    );
  }
}
