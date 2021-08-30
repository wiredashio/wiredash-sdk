import 'dart:async';
import 'dart:io';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';
import 'package:wiredash/src/feedback/ui/base_click_target.dart';
import 'package:wiredash/src/feedback/ui/big_blue_button.dart';
import 'package:wiredash/src/feedback/ui/email_input.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/measure.dart';
import 'package:wiredash/src/responsive_layout.dart';
import 'package:wiredash/src/snap.dart';
import 'package:wiredash/src/sprung.dart';
import 'package:wiredash/src/wiredash_provider.dart';

bool _firstOpenAnimOnMetal = !kIsWeb && (Platform.isIOS || Platform.isMacOS);

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

      if (_firstOpenAnimOnMetal) {
        // increase anim time on metal because shaders aren't cached yet
        _firstOpenAnimOnMetal = false;
        _state!._backdropAnimationController.duration =
            WiredashBackdrop.enterDuration * 2;
      } else {
        _state!._backdropAnimationController.duration =
            WiredashBackdrop.enterDuration;
      }

      // 1) start animation, causes app to be rendered on top of stack
      final openFuture = _state!._backdropAnimationController.animateTo(0.01);

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
      await _state!._backdropAnimationController.forward();
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
  final GlobalKey _childAppKey =
      GlobalKey<State<StatefulWidget>>(debugLabel: 'app');

  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  late final ScrollController _scrollController = ScrollController()
    ..addListener(() {
      if (_scrollController.positions.length == 1) {
        setState(() {
          _scrollOffset = _scrollController.offset;
        });
      }
    });

  /// Controls revealing and hiding of Wiredash
  ///
  /// forward() to open, reverse() to close
  late final AnimationController _backdropAnimationController =
      AnimationController(
    vsync: this,
    duration: WiredashBackdrop.enterDuration,
    reverseDuration: WiredashBackdrop.exitDuration,
  );

  late Animation<double> _scaleAppAnimation;
  late Animation<double> _translateAppAnimation;
  late Animation<BorderRadius?> _appCornerRadiusAnimation;

  /// When opening wiredash layouting has not yet finished and we don't know
  /// the exact location of the app in our layout. This flag is used to show the
  /// app at current position (fully visible, fully expanded) until the first
  /// frame is drawn and the animation can start.
  bool _isLayoutingCompleted = false;

  /// Position of the app relative to the whole backdrop layout
  Rect? _savedRect;

  /// The "default" position of app used for the snap point calculation
  ///
  /// This is just an estimation, and makes sure there aren't multiple snap
  /// points at location 0 with height 0
  static const double appStartingTopPosition = 300;

  late Animation<double> _centerAnimation;

  final FocusNode _feedbackFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  static const double _appPeak = 100;

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _backdropAnimationController
        .addStatusListener(_animControllerStatusListener);
    final slightlyUnderdumped = Sprung(18);
    _centerAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.0, 1.0, curve: Sprung.overDamped),
      reverseCurve: slightlyUnderdumped.flipped,
    );
    final CurvedAnimation inlineAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.0, 1.0, curve: slightlyUnderdumped),
      reverseCurve: slightlyUnderdumped.flipped,
    );

    _translateAppAnimation =
        Tween<double>(begin: 0, end: 1).animate(inlineAnimation);
    _appCornerRadiusAnimation = BorderRadiusTween(
      begin: BorderRadius.circular(0),
      end: BorderRadius.circular(20),
    ).animate(_centerAnimation);
  }

  @override
  void dispose() {
    super.dispose();
    _scrollController.dispose();
    _backdropAnimationController.dispose();
    _feedbackFocusNode.dispose();
    _emailFocusNode.dispose();
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

  double _scrollOffset = 0;

  @override
  Widget build(BuildContext context) {
    Widget app = KeyedSubtree(
      key: _childAppKey,
      child: widget.child,
    );

    if (_animationStatus == AnimationStatus.dismissed) {
      // animation is not yet started, show the app without being wrapped in Transforms
      return app;
    }

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final model = context.wiredashModel;
    app = FocusScope(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: false,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: AbsorbPointer(
        absorbing: !model.isAppInteractive,
        child: _KeepAppAlive(
          child: app,
        ),
      ),
    );

    final topInset = MediaQuery.of(context).viewInsets.top;

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
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                SizedBox(height: topInset),
                SizedBox(height: _appPeak),
                // Position of the app in the listview for measure, show child here when measured
                IntrinsicHeight(
                  child: Align(
                    alignment: Alignment.topCenter,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      child: () {
                        return _ScrollToTopButton(
                          onTap: () {
                            print("Scroll to top");
                            model.hide();
                          },
                        );
                      }(),
                    ),
                  ),
                ),

                MeasureSize(
                  onChange: (size, bounds) {
                    setState(() {
                      // input changed size, trigger build to update
                    });
                  },
                  child: WiredashFeedbackFlow(
                    focusNode: _feedbackFocusNode,
                  ),
                ),

                // keyboard inset
                SizedBox(height: bottomInset),
              ],
            ),
            _buildAppPositioningAnimation(
              offset: Offset(0, 50),
              child: _buildAppFrame(
                child: app,
              ),
            ),
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
            ),
            Positioned(
              bottom: 8,
              left: 0,
              right: 0,
              child: Icon(
                WiredashIcons.cevronDownLight,
                color: Colors.black26,
              ),
            ),
          ],
        );
      },
      child: child,
    );
  }

  /// Animates the app from fullscreen to inline in the list
  ///
  /// [offset] moves the app inside the window sized area reserved for the app in the list
  Widget _buildAppPositioningAnimation({
    required Widget child,
    Offset offset = Offset.zero,
  }) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, app) {
        final screenHeight = MediaQuery.of(context).size.height;
        final topInset = MediaQuery.of(context).viewInsets.top;

        final translationY = (-screenHeight + _appPeak + topInset) *
            _translateAppAnimation.value;
        print(translationY);
        return Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..scale(_scaleAppAnimation.value)
            ..translate(
              offset.dx,
              translationY,
            ),
          child: app,
        );
      },
      child: child,
    );
  }
}

class _ScrollToTopButton extends StatelessWidget {
  _ScrollToTopButton({
    Key? key,
    this.onTap,
  }) : super(key: key);

  final void Function()? onTap;

  static final _colorTween =
      ColorTween(begin: Color(0xFF1A56DB), end: Colors.black54);

  @override
  Widget build(BuildContext context) {
    return AnimatedClickTarget(
      onTap: onTap,
      builder: (context, state, anims) {
        final colorValue =
            math.max(anims.hoveredAnim.value * 0.3, anims.pressedAnim.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              'Pull to Return',
              style: TextStyle(
                color: _colorTween.lerp(colorValue),
              ),
            ),
          ),
        );
      },
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
    return widget.child;
  }

  @override
  bool get wantKeepAlive => true;
}
