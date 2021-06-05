import 'dart:async';
import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/media_query_from_window.dart';
import 'package:wiredash/src/sprung.dart';
import 'package:wiredash/src/wiredash_provider.dart';

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({Key? key, required this.child, this.controller})
      : super(key: key);

  /// The wrapped app
  final Widget child;

  final BackdropController? controller;

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
        _state!.setState(() {
          _state!._isLayoutingCompleted = true;
        });

        completer.complete();
      });
      await completer.future;
      await openFuture;
    } else {
      _state!._backdropAnimationController.forward();
    }
  }

  Future<void> hideWiredash() async {
    await _state!._backdropAnimationController.reverse();
    _state!.setState(() {
      _state!._isLayoutingCompleted = false;
    });
  }
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  static const double feedbackInputHorizontalPadding = 32;

  final GlobalKey _childAppKey = GlobalKey<State<StatefulWidget>>();

  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  late final ScrollController _scrollController;

  /// Controls reveleaing and hiding of Wiredash
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

  @override
  void initState() {
    super.initState();
    widget.controller?._state = this;
    _scrollController = ScrollController();
    _backdropAnimationController = AnimationController(
      vsync: this,
      duration: WiredashBackdrop.enterDuration,
      reverseDuration: WiredashBackdrop.exitDuration,
    )..addStatusListener(_animControllerStatusListener);
    final CurvedAnimation centerAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.0, 0.5, curve: Sprung.overDamped),
      reverseCurve: Sprung.overDamped.flipped,
    );
    final CurvedAnimation inlineAnimation = CurvedAnimation(
      parent: _backdropAnimationController,
      curve: Interval(0.5, 1.0, curve: Sprung.overDamped),
      reverseCurve: Sprung.overDamped.flipped,
    );

    _scaleAppAnimation = Tween<double>(begin: 1, end: _calculateScaleFactor())
        .animate(centerAnimation);
    _translateAppAnimation =
        Tween<double>(begin: -1, end: 0).animate(inlineAnimation);
    _appCornerRadiusAnimation = BorderRadiusTween(
            begin: BorderRadius.circular(0), end: BorderRadius.circular(16))
        .animate(centerAnimation);
  }

  /// returns the scale factor of
  double _calculateScaleFactor() {
    final mediaQueryData =
        MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    final Size screenSize = mediaQueryData.size;
    final EdgeInsets viewPadding = mediaQueryData.viewPadding;

    final double targetContentWidth = screenSize.width -
        viewPadding.horizontal -
        2 * feedbackInputHorizontalPadding;
    final double targetContentHeight = screenSize.height -
        viewPadding.vertical -
        2 * feedbackInputHorizontalPadding;

    return math.min(
      targetContentWidth / screenSize.width,
      targetContentHeight / screenSize.height,
    );
  }

  void _animControllerStatusListener(AnimationStatus status) {
    if (_animationStatus != status) {
      setState(() {
        _animationStatus = _backdropAnimationController.status;
      });
    }
  }

  void didUpdateWidget(WiredashBackdrop oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      oldWidget.controller?._state = null;
      widget.controller?._state = this;
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: _childAppKey,
      child: widget.child,
    );

    if (_animationStatus == AnimationStatus.dismissed) {
      // animation is not yet started, show the app without being wrapped in Transforms
      return child;
    }

    final model = context.wiredashModel!;
    child = AbsorbPointer(
      absorbing: !model.isAppInteractive,
      child: child,
    );

    final options = WiredashOptions.of(context);
    return MediaQueryFromWindow(
      // Directionality required for all Text widgets
      child: Directionality(
        textDirection: options?.textDirection ?? TextDirection.ltr,
        // Localizations required for all Flutter UI widgets
        child: Localizations(
          locale: options?.currentLocale ?? window.locale,
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          // Overlay is required for text edit functions such as copy/paste on mobile
          child: Overlay(initialEntries: <OverlayEntry>[
            OverlayEntry(builder: (BuildContext context) {
              return Builder(builder: (context) {
                return Material(
                  child: Container(
                    color: Colors.white,
                    child: Stack(
                      children: <Widget>[
                        ListView(
                          // controller: _scrollController,
                          physics: const ClampingScrollPhysics(),
                          children: <Widget>[
                            _FeedbackInputContent(),

                            // Position of the app in the listview.
                            // shown when layout is done and the entry animation
                            // could be started
                            buildBackdropAnimation(
                              context,
                              _isLayoutingCompleted
                                  ? child
                                  : const SizedBox.expand(),
                            )
                          ],
                        ),
                        // shows app on top while waiting for layouting to happen
                        if (!_isLayoutingCompleted) ...<Widget>[
                          child,
                        ],
                      ],
                    ),
                  ),
                );
              });
            })
          ]),
        ),
      ),
    );
  }

  Widget buildBackdropAnimation(BuildContext context, Widget child) {
    return AnimatedBuilder(
      animation: _backdropAnimationController,
      builder: (context, child) {
        final RenderBox? selfRenderBox =
            context.findRenderObject() as RenderBox?;
        final Offset selfOffset =
            selfRenderBox?.localToGlobal(Offset.zero) ?? Offset.zero;

        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..scale(_scaleAppAnimation.value)
            ..translate(
              0.0,
              _translateAppAnimation.value * selfOffset.dy,
            ),
          child: SizedBox(
            height: MediaQuery.of(context).size.height,
            child: Material(
              elevation: 2,
              shadowColor: const Color(0xffe5e7eb),
              clipBehavior: Clip.antiAlias,
              borderRadius: _appCornerRadiusAnimation.value,
              animationDuration: Duration.zero,
              child: ClipRRect(
                borderRadius: _appCornerRadiusAnimation.value,
                child: child,
              ),
            ),
          ),
        );
      },
      child: child,
    );
  }
}

class _FeedbackInputContent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      minimum: const EdgeInsets.only(top: 16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Center(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () {
                  context.wiredashModel!.hide();
                },
                borderRadius: BorderRadius.circular(20),
                child: const Padding(
                  padding: EdgeInsets.all(24),
                  child: Text(
                    'CLOSE',
                  ),
                ),
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.only(
              left: _WiredashBackdropState.feedbackInputHorizontalPadding,
              right: _WiredashBackdropState.feedbackInputHorizontalPadding,
              top: 128,
            ),
            child: Text(
              'You got feedback for us?',
            ),
          ),
          TextFormField(
            keyboardType: TextInputType.multiline,
            maxLines: null,
            decoration: const InputDecoration(
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              enabledBorder: InputBorder.none,
              disabledBorder: InputBorder.none,
              errorBorder: InputBorder.none,
              hintText: 'e.g. there’s a bug when ... or I really enjoy ...',
              contentPadding: EdgeInsets.only(
                left: _WiredashBackdropState.feedbackInputHorizontalPadding,
                right: _WiredashBackdropState.feedbackInputHorizontalPadding,
                top: 24,
                bottom: 16,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
