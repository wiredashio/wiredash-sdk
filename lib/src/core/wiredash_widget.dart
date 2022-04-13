import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/context_cache.dart';
import 'package:wiredash/src/core/options/wiredash_options.dart';
import 'package:wiredash/src/core/project_credential_validator.dart';
import 'package:wiredash/src/core/support/back_button_interceptor.dart';
import 'package:wiredash/src/core/support/not_a_widgets_app.dart';
import 'package:wiredash/src/feedback/_feedback.dart';
import 'package:wiredash/src/feedback/feedback_backdrop.dart';
import 'package:wiredash/src/nps/nps_backdrop.dart';
import 'package:wiredash/src/nps/nps_model_provider.dart';
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
  final GlobalKey _appKey = GlobalKey(debugLabel: 'app');

  final WiredashServices _services = WiredashServices();

  late final WiredashBackButtonDispatcher _backButtonDispatcher;

  Timer? _submitTimer;

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
    _services.addListener(_markNeedsBuild);
    _services.wiredashModel.addListener(_markNeedsBuild);
    _services.backdropController.addListener(_markNeedsBuild);

    _submitTimer =
        Timer(const Duration(seconds: 5), scheduleFeedbackSubmission);
    _backButtonDispatcher = WiredashBackButtonDispatcher()..initialize();
  }

  /// Submits pending feedbacks on app start (slightly delayed)
  void scheduleFeedbackSubmission() {
    _submitTimer = null;
    final submitter = _services.feedbackSubmitter;
    if (submitter is RetryingFeedbackSubmitter) {
      submitter.submitPendingFeedbackItems();

      if (kDebugMode) {
        //submitter.deletePendingFeedbacks();
      }
    }
  }

  void _markNeedsBuild() {
    // rebuild the Wiredash widget state
    setState(() {});
  }

  @override
  void dispose() {
    _submitTimer?.cancel();
    _submitTimer = null;
    _services.dispose();
    _backButtonDispatcher.dispose();
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
    // Assign app an key so it doesn't lose state when wrapped, unwrapped
    // with widgets
    final Widget app = KeyedSubtree(
      key: _appKey,
      child: widget.child,
    );

    if (!_services.wiredashModel.isWiredashActive) {
      // We don't wrap the app at all with any wiredash related widget until
      // users requested to open wiredash
      return app;
    }

    final theme = _services.wiredashModel.themeFromContext ??
        widget.theme ??
        WiredashThemeData();

    final Widget flow = () {
      final active = _services.wiredashModel.activeFlow;
      if (active == null) {
        return const Center(
          child: Text('No flow selected'),
        );
      }
      switch (active) {
        case WiredashFlow.feedback:
          return FeedbackModelProvider(
            feedbackModel: _services.feedbackModel,
            child: FeedbackBackdrop(child: app),
          );
        case WiredashFlow.nps:
          return NpsModelProvider(
            npsModel: _services.npsModel,
            child: NpsBackdrop(child: app),
          );
      }
    }();

    final Widget backdrop = NotAWidgetsApp(
      textDirection: widget.options?.textDirection,
      child: _backButtonDispatcher.wrap(
        child: WiredashLocalizations(
          child: WiredashTheme(
            data: theme,
            child: flow,
          ),
        ),
      ),
    );

    // Finally provide the models to wiredash and the UI
    return WiredashModelProvider(
      wiredashModel: _services.wiredashModel,
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
    );
  }
}

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
