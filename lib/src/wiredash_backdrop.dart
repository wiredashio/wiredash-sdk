import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/media_query_from_window.dart';
import 'package:wiredash/src/wiredash_provider.dart';

/// The Wiredash UI behind the app
class WiredashBackdrop extends StatefulWidget {
  const WiredashBackdrop({Key? key, required this.child}) : super(key: key);

  /// The wrapped app
  final Widget child;

  @override
  State<WiredashBackdrop> createState() => _WiredashBackdropState();
}

class _WiredashBackdropState extends State<WiredashBackdrop>
    with TickerProviderStateMixin {
  static const Duration _animationDuration = Duration(milliseconds: 350);

  final GlobalKey _childAppKey = GlobalKey<State<StatefulWidget>>();

  AnimationStatus _animationStatus = AnimationStatus.dismissed;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  bool _isLayoutingCompleted = false;
  bool _isCurrentlyActive = false;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _animationController =
        AnimationController(vsync: this, duration: _animationDuration)
          ..addStatusListener(_animControllerStatusListener);
  }

  void _animControllerStatusListener(AnimationStatus status) {
    if (_animationStatus != status) {
      // Reset the show manual overlay flag once Wiredash is closed
      if (status == AnimationStatus.dismissed) {
        _onHideWiredashCompleted();
      }
      setState(() {
        _animationStatus = _animationController.status;
      });
    }
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    // TODO explicitly listen to model
    // checking if the wiredashModel.isActive has changed
    if (_isCurrentlyActive != context.wiredashModel!.isWiredashActive) {
      _isCurrentlyActive = context.wiredashModel!.isWiredashActive;

      if (_isCurrentlyActive) {
        // Once that is done and we have the RenderObject for the animation hide the manual overlay
        WidgetsBinding.instance?.addPostFrameCallback((_) {
          setState(() {
            _isLayoutingCompleted = true;
          });
          // Once the manual overlay is hidden trigger the animation
          _showWiredash();
        });
      } else {
        _hideWiredash();
      }
    }
  }

  void _showWiredash() {
    _animationController.forward();
  }

  void _hideWiredash() {
    _animationController.reverse();
  }

  void _onHideWiredashCompleted() {
    setState(() {
      _isLayoutingCompleted = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: _childAppKey,
      child: widget.child,
    );

    final model = context.wiredashModel!;
    if (!model.isWiredashActive) {
      return child;
    }

    child = AbsorbPointer(
      absorbing: !model.isAppInteractive,
      child: child,
    );

    final options = WiredashOptions.of(context);
    return MediaQueryFromWindow(
      child: Directionality(
        textDirection: options?.textDirection ?? TextDirection.ltr,
        child: Localizations(
          locale: options?.currentLocale ?? window.locale,
          delegates: const <LocalizationsDelegate<dynamic>>[
            DefaultMaterialLocalizations.delegate,
            DefaultCupertinoLocalizations.delegate,
            DefaultWidgetsLocalizations.delegate,
          ],
          child: Builder(builder: (context) {
            return Material(
              child: Container(
                color: Colors.pink,
                child: Stack(
                  children: <Widget>[
                    ListView(
                      // controller: _scrollController,
                      physics: const ClampingScrollPhysics(),
                      children: <Widget>[
                        _FeedbackInputContent(),
                        if (_isLayoutingCompleted)
                          Transform.translate(
                            offset: const Offset(0, 200),
                            child: SizedBox(
                              height: MediaQuery.of(context).size.height,
                              child: ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(8), // TODO lerp
                                child: child,
                              ),
                            ),
                          )
                      ],
                    ),
                    if (!_isLayoutingCompleted) ...<Widget>[
                      child,
                    ],
                  ],
                ),
              ),
            );
          }),
        ),
      ),
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
              left: 12,
              right: 12,
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
                left: 16,
                right: 16,
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
