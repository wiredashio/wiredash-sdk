import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/services/services.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/context_cache.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/screencapture.dart';
import 'package:wiredash/src/feedback/backdrop/backdrop_controller_provider.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/picasso/picasso_provider.dart';
import 'package:wiredash/src/feedback/ui/color_palette.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
import 'package:wiredash/src/feedback/ui/screenshot_bar.dart';
import 'package:wiredash/src/support/not_a_widgets_app.dart';
import 'package:wiredash/src/wiredash_model_provider.dart';
import 'package:wiredash/wiredash.dart';

/// Capture in-app user feedback, wishes, ratings and much more
///
/// 1. Setup
/// Wrap you Application in [Wiredash] and pass in the apps [Navigator]
///
/// ```dart
/// class MyApp extends StatefulWidget {
///   @override
///   _MyAppState createState() => _MyAppState();
/// }
///
/// class _MyAppState extends State<MyApp> {
///   /// Share the app [Navigator] with Wiredash
///   final GlobalKey<NavigatorState> _navigatorKey =
///                                           GlobalKey<NavigatorState>();
///
///   @override
///   Widget build(BuildContext context) {
///     return Wiredash(
///       projectId: "YOUR-PROJECT-ID",
///       secret: "YOUR-SECRET",
///       theme: WiredashThemeData(),
///       navigatorKey: _navigatorKey,
///       child: MaterialApp(
///         navigatorKey: _navigatorKey,
///         title: 'Wiredash Demo',
///         home: DemoHomePage(),
///       ),
///     );
///   }
/// }
/// ```
///
/// 2. Start Wiredash
///
/// ```dart
/// Wiredash.of(context).show();
/// ```
class Wiredash extends StatefulWidget {
  /// Creates a new [Wiredash] Widget which allows users to send feedback,
  /// wishes, ratings and much more
  const Wiredash({
    Key? key,
    required this.projectId,
    required this.secret,
    @Deprecated('Since 1.0 the navigatorKey is not required anymore')
        this.navigatorKey,
    this.options,
    this.theme,
    this.feedbackOptions,
    this.padding,
    required this.child,
  }) : super(key: key);

  /// Reference to the app [Navigator] to show the Wiredash bottom sheet
  @Deprecated('Since 1.0 the navigatorKey is not required anymore')
  final GlobalKey<NavigatorState>? navigatorKey;

  /// Your Wiredash projectId
  final String projectId;

  /// Your Wiredash project secret
  final String secret;

  /// Customize Wiredash's behaviour and language
  final WiredashOptionsData? options;

  final WiredashFeedbackOptions? feedbackOptions;

  /// Default visual properties, like colors and fonts for the Wiredash bottom
  /// sheet and the screenshot capture UI.
  ///
  /// Dark and light themes are supported, try it!
  ///
  /// ```dart
  /// return Wiredash(
  ///   theme: WiredashThemeData(brightness: Brightness.dark),
  ///   projectId: "...",
  ///   secret: "...",
  ///   child: MyApp(),
  /// );
  /// ```
  final WiredashThemeData? theme;

  /// The padding inside wiredash, parts of the screen it should not draw into
  ///
  /// This is useful for macOS applications that draw the window titlebar
  /// themselves.
  final EdgeInsets? padding;

  /// Your application
  final Widget child;

  @override
  WiredashState createState() => WiredashState();

  /// The [WiredashController] from the closest [Wiredash] instance or `null`
  /// that encloses the given context.
  ///
  /// Use it to start Wiredash (when available)
  ///
  /// ```dart
  /// Wiredash.maybeOf(context)?.show();
  /// ```
  static WiredashController? maybeOf(BuildContext context) {
    final state = context.findAncestorStateOfType<WiredashState>();
    if (state == null) return null;
    // cache context in a short lived object like the widget
    // it gets later retrieved by the `show()` method to read the theme
    state.widget.showBuildContext = context;
    return WiredashController(state._services.wiredashModel);
  }

  /// The [WiredashController] from the closest [Wiredash] instance that
  /// encloses the given context.
  ///
  /// Use it to start Wiredash
  ///
  /// ```dart
  /// Wiredash.of(context).show();
  /// ```
  static WiredashController of(BuildContext context) {
    final state = context.findAncestorStateOfType<WiredashState>();
    if (state == null) {
      throw StateError('Could not find WiredashState in ancestors');
    }
    // cache context in a short lived object like the widget
    // it gets later retrieved by the `show()` method to read the theme
    state.widget.showBuildContext = context;
    return WiredashController(state._services.wiredashModel);
  }
}

class WiredashState extends State<Wiredash> {
  final Key _appKey = const ValueKey('app');

  final Key _backdropKey = const ValueKey('backdrop');

  bool _isWiredashClosed = true;

  final WiredashServices _services = WiredashServices();

  WiredashServices get debugServices {
    WiredashServices? services;
    assert(
      () {
        services = _services;
        return true;
      }(),
    );
    if (services == null) {
      throw "Services can't be accessed in production code";
    }
    return services!;
  }

  @override
  void initState() {
    super.initState();
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    _services.updateWidget(widget);
    _services.addListener(() {
      setState(() {
        // rebuild wiredash
      });
    });
    _services.backdropController.addListener(() {
      setState(() {
        _isWiredashClosed = _services.backdropController.backdropStatus ==
            WiredashBackdropStatus.closed;
      });
    });
  }

  @override
  void dispose() {
    _services.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    _services.updateWidget(widget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = _services.wiredashModel.themeFromContext ??
        widget.theme ??
        WiredashThemeData();

    // Assign app an key so it doesn't lose state when wrapped, unwrapped
    // with widgets
    final Widget app = KeyedSubtree(
      key: _appKey,
      child: widget.child,
    );

    final appBuilder = Builder(
      builder: (context) {
        Widget widget = app;
        // Only wrap when active to get as little side-effect as possible.
        if (!_isWiredashClosed) {
          // This is the place to wrap the app itself, not the whole backdrop
          widget = ScreenCapture(
            controller: _services.screenCaptureController,
            child: widget,
          );
        }

        return widget;
      },
    );

    final Widget backdrop = NotAWidgetsApp(
      textDirection: widget.options?.textDirection,
      child: WiredashLocalizations(
        child: WiredashTheme(
          data: theme,
          child: WiredashBackdrop(
            key: _backdropKey,
            controller: _services.backdropController,
            padding: widget.padding,
            app: appBuilder,
            contentBuilder: (context) {
              return WiredashFeedbackFlow(
                // this allows discarding feedback in the message step
                key: ValueKey(context.feedbackModel),
              );
            },
            foregroundLayerBuilder: (c, r, mq) {
              return _buildForegroundLayer(c, r, mq, _services);
            },
            backgroundLayerBuilder: (c, r, mq) {
              return _buildBackgroundLayer(c, r, mq, _services);
            },
          ),
        ),
      ),
    );

    // Finally provide the models to wiredash and the UI
    return WiredashModelProvider(
      wiredashModel: _services.wiredashModel,
      child: FeedbackModelProvider(
        feedbackModel: _services.feedbackModel,
        child: BackdropControllerProvider(
          backdropController: _services.backdropController,
          child: PicassoControllerProvider(
            picassoController: _services.picassoController,
            child: WiredashOptions(
              data: _services.wiredashOptions,
              child: backdrop,
            ),
          ),
        ),
      ),
    );
  }
}

Widget? _buildForegroundLayer(
  BuildContext context,
  Rect appRect,
  MediaQueryData mediaQueryData,
  WiredashServices services,
) {
  final List<Widget> stackChildren = [];

  final status = services.backdropController.backdropStatus;
  final animatingCenter = status == WiredashBackdropStatus.openingCentered ||
      status == WiredashBackdropStatus.closingCentered;
  if (animatingCenter || status == WiredashBackdropStatus.centered) {
    final topBar = SafeArea(
      bottom: false,
      left: false,
      right: false,
      child: SizedBox(
        height: appRect.top,
        child: const ScreenshotBar(),
      ),
    );

    stackChildren.add(
      SizedBox(
        height: appRect.top,
        width: double.infinity,
        child: Padding(
          // padding: EdgeInsets.zero,
          padding: EdgeInsets.only(
            left: appRect.left,
            right: appRect.left,
          ),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 500),
            reverseDuration: const Duration(milliseconds: 200),
            // hide buttons early when exiting centered
            child: status == WiredashBackdropStatus.openingCentered ||
                    status == WiredashBackdropStatus.centered
                ? topBar
                : null,
          ),
        ),
      ),
    );

    final bottomBar = Align(
      alignment: Alignment.bottomCenter,
      child: AnimatedSlide(
        duration: const Duration(seconds: 1),
        curve: const Interval(
          0.5,
          1,
          curve: Curves.easeOutCirc,
        ),
        offset: Offset(
          0,
          context.feedbackModel.feedbackFlowStatus ==
                  FeedbackFlowStatus.screenshotDrawing
              ? 0
              : 1,
        ),
        child: ColorPalette(
          initialColor: services.picassoController.color,
          initialStrokeWidth: services.picassoController.strokeWidth,
          onNewColorSelected: (color) =>
              services.picassoController.color = color,
          onNewStrokeWidthSelected: (width) =>
              services.picassoController.strokeWidth = width,
          onUndo: services.picassoController.undo,
        ),
      ),
    );

    // poor way to prevent overflow during enter/exit anim
    if (!animatingCenter) {
      stackChildren.add(bottomBar);
    }
  }

  if (stackChildren.isEmpty) {
    return null;
  }
  return Stack(children: stackChildren);
}

Widget? _buildBackgroundLayer(
  BuildContext context,
  Rect appRect,
  MediaQueryData mediaQueryData,
  WiredashServices services,
) {
  final List<Widget> stackChildren = [];

  final status = services.backdropController.backdropStatus;
  final animatingCenter = status == WiredashBackdropStatus.openingCentered ||
      status == WiredashBackdropStatus.closingCentered;
  if (animatingCenter || status == WiredashBackdropStatus.centered) {
    if (appRect.width < 500) {
      final bottomText = Align(
        alignment: Alignment.bottomCenter,
        child: SizedBox(
          height: math.max(mediaQueryData.size.height - appRect.bottom, 0),
          width: appRect.width,
          child: SafeArea(
            top: false,
            left: false,
            right: false,
            child: AnimatedSlide(
              duration: const Duration(seconds: 1),
              curve: const Interval(
                0.5,
                1,
                curve: Curves.easeOutCirc,
              ),
              offset: Offset(
                0,
                context.feedbackModel.feedbackFlowStatus ==
                        FeedbackFlowStatus.screenshotNavigating
                    ? 0
                    : 4,
              ),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Center(
                  child: Text(
                    'Include a screenshot for more context',
                    style: context.theme.appbarTitle,
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ),
      );
      stackChildren.add(bottomText);
    }
  }

  if (stackChildren.isEmpty) {
    return null;
  }
  return Stack(children: stackChildren);
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
