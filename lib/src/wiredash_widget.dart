import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/screencapture.dart';
import 'package:wiredash/src/feedback/backdrop/backdrop_controller_provider.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/picasso/picasso_provider.dart';
import 'package:wiredash/src/not_a_widgets_app.dart';
import 'package:wiredash/src/services.dart';
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
    this.navigatorKey,
    this.options,
    this.theme,
    this.feedbackOptions,
    required this.child,
  }) : super(key: key);

  /// Reference to the app [Navigator] to show the Wiredash bottom sheet
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

    return WiredashController(state.services.wiredashModel);
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
    return WiredashController(state!.services.wiredashModel);
  }
}

class WiredashState extends State<Wiredash> {
  final Key _appKey = const ValueKey('app');

  final Key _backdropKey = const ValueKey('backdrop');

  bool _isWiredashClosed = true;

  final WiredashServices services = WiredashServices();

  @override
  void initState() {
    super.initState();
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    services.updateWidget(widget);
    services.addListener(() {
      setState(() {
        // rebuild wiredash
      });
    });
    services.backdropController.addListener(() {
      setState(() {
        _isWiredashClosed = services.backdropController.backdropStatus ==
            WiredashBackdropStatus.closed;
      });
    });
  }

  @override
  void dispose() {
    services.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);
    debugProjectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    services.updateWidget(widget);
  }

  @override
  Widget build(BuildContext context) {
    final theme = widget.theme ?? WiredashThemeData();

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
          widget = Picasso(
            controller: services.picassoController,
            child: ScreenCapture(
              controller: services.screenCaptureController,
              child: widget,
            ),
          );
        }

        return widget;
      },
    );

    final Widget backdrop = NotAWidgetsApp(
      locale: widget.options?.currentLocale,
      textDirection: widget.options?.textDirection,
      child: WiredashLocalizations(
        child: WiredashTheme(
          data: theme,
          child: Stack(
            children: [
              WiredashBackdrop(
                key: _backdropKey,
                controller: services.backdropController,
                child: appBuilder,
              ),
            ],
          ),
        ),
      ),
    );

    // Finally provide the models to wiredash and the UI
    return WiredashModelProvider(
      wiredashModel: services.wiredashModel,
      child: FeedbackModelProvider(
        feedbackModel: services.feedbackModel,
        child: BackdropControllerProvider(
          backdropController: services.backdropController,
          child: PicassoControllerProvider(
            picassoController: services.picassoController,
            child: WiredashOptions(
              data: services.wiredashOptions,
              child: backdrop,
            ),
          ),
        ),
      ),
    );
  }
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
