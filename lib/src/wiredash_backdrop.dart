import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
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
      _state!._scrollController.animateTo(
        MediaQuery.of(_state!.context).size.height - 100,
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOutCubic,
      );
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
  final GlobalKey _childAppKey =
      GlobalKey<State<StatefulWidget>>(debugLabel: 'app');

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
  Rect? _savedRect;

  /// The "default" position of app used for the snap point calculation
  ///
  /// This is just an estimation, and makes sure there aren't multiple snap
  /// points at location 0 with height 0
  static const double appStartingTopPosition = 300;

  late Animation<double> _centerAnimation;

  final FocusNode _feedbackFocusNode = FocusNode();
  final FocusNode _emailFocusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _scrollController = ScrollController()
      ..addListener(() {
        if (_scrollController.positions.length == 1) {
          setState(() {
            _scrollOffset = _scrollController.offset;
          });
        }
      });
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
      curve: Interval(0.0, 1.0, curve: slightlyUnderdumped),
      reverseCurve: slightlyUnderdumped.flipped,
    );

    _translateAppAnimation =
        Tween<double>(begin: -1, end: 0).animate(inlineAnimation);
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

    final appTopPosition = () {
      if (_savedRect != null) {
        if (_scrollController.positions.length == 1) {
          return _savedRect!.top + _scrollController.offset;
        }
        return _savedRect!.top;
      }
      return appStartingTopPosition;
    }();

    final appBottomPosition = () {
      if (_savedRect != null) {
        return _savedRect!.bottom;
      }
      return appStartingTopPosition + MediaQuery.of(context).size.height;
    }();

    print("scrollOffset $_scrollOffset");
    print('_savedRect=${_savedRect}');
    // print("app position $appTopPosition - $appBottomPosition");

    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    final model = context.wiredashModel;
    app = FocusScope(
      debugLabel: 'wiredash app wrapper',
      canRequestFocus: false,
      // Users would be unable to leave the app once it got focus
      skipTraversal: true,
      child: AbsorbPointer(
        absorbing: _scrollOffset > 0.0,
        child: _KeepAppAlive(
          child: app,
        ),
      ),
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
            ListView(
              controller: _scrollController,
              // TODO fix snapping when scolled with mouse wheel on desktop
              physics: SnapScrollPhysics(
                parent: const AlwaysScrollableScrollPhysics(),
                snaps: [
                  Snap.avoidZone(
                    0,
                    appBottomPosition,
                    delimiter: appBottomPosition - appTopPosition,
                  ),
                  Snap(appBottomPosition + 10),
                ],
              ),
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              children: <Widget>[
                // Position of the app in the listview for measure, show child here when measured
                IntrinsicHeight(
                  child: Stack(
                    children: [
                      _buildAppPositioningAnimation(
                        offset: Offset(0, 50),
                        child: _buildAppFrame(
                          child: _savedRect != null ? app : null,
                        ),
                      ),
                      Align(
                        alignment: Alignment.topCenter,
                        child: SafeArea(
                          top: true,
                          minimum: const EdgeInsets.only(top: 8),
                          child: AnimatedSwitcher(
                            duration: const Duration(milliseconds: 200),
                            child: () {
                              if (model.capturingScreenshot) {
                                // TODO fix arrow only clickable within app frame bounds
                                return _ScrollToTopButton(
                                  onTap: () {
                                    print("Scroll to top");
                                    model.exitCaptureMode();
                                    _scrollController.animateTo(
                                      0,
                                      duration:
                                          const Duration(milliseconds: 200),
                                      curve: Curves.easeInOutCubic,
                                    );
                                  },
                                );
                              }
                              return const SizedBox();
                            }(),
                          ),
                        ),
                      )
                    ],
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

            // shows app on top while waiting for layouting of the ListView
            if (_savedRect == null) ...<Widget>[
              app,
            ],
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

  /// Animates the app from fullscreen to inline in the list
  ///
  /// [offset] moves the app inside the window sized area reserved for the app in the list
  Widget _buildAppPositioningAnimation({
    required Widget child,
    Offset offset = Offset.zero,
  }) {
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
          if (_savedRect != rect) {
            _savedRect = rect;
            WidgetsBinding.instance!.addPostFrameCallback((_) {
              setState(() {
                /* notify that _savedRect has changed */
              });
            });
          }
        }

        final translationY =
            (_translateAppAnimation.value * (_savedRect?.top ?? 0)) +
                offset.dy * (1 + _translateAppAnimation.value);
        return Transform(
          alignment: Alignment.topCenter,
          transform: Matrix4.identity()
            ..scale(_scaleAppAnimation.value)
            ..translate(
              offset.dx,
              translationY,
            ),
          child: child,
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
      ColorTween(begin: Colors.black26, end: Colors.black54);

  @override
  Widget build(BuildContext context) {
    return AnimatedClickTarget(
      onTap: onTap,
      builder: (context, state, anims) {
        final colorValue =
            math.max(anims.hoveredAnim.value * 0.3, anims.pressedAnim.value);
        return ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Align(
            alignment: Alignment.center,
            widthFactor: 0.5,
            heightFactor: 0.5,
            child: Icon(
              Icons.keyboard_arrow_up_outlined,
              size: 100,
              color: _colorTween.lerp(colorValue),
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
