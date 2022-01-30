import 'package:flutter/material.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/services/services.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/utils/context_cache.dart';
import 'package:wiredash/src/common/utils/project_credential_validator.dart';
import 'package:wiredash/src/common/widgets/screencapture.dart';
import 'package:wiredash/src/common/widgets/tron_button.dart';
import 'package:wiredash/src/common/widgets/wirecons.dart';
import 'package:wiredash/src/feedback/backdrop/backdrop_controller_provider.dart';
import 'package:wiredash/src/feedback/backdrop/wiredash_backdrop.dart';
import 'package:wiredash/src/feedback/feedback_model.dart';
import 'package:wiredash/src/feedback/feedback_model_provider.dart';
import 'package:wiredash/src/feedback/picasso/picasso.dart';
import 'package:wiredash/src/feedback/picasso/picasso_provider.dart';
import 'package:wiredash/src/feedback/ui/feedback_flow.dart';
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
          widget = Picasso(
            controller: _services.picassoController,
            child: ScreenCapture(
              controller: _services.screenCaptureController,
              child: widget,
            ),
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
            contentBuilder: (_) => const WiredashFeedbackFlow(),
            // TODO move somewhere else
            foregroundLayerBuilder: (context, appRect) {
              final status = _services.backdropController.backdropStatus;
              Widget? content;
              final animatingCenter =
                  status == WiredashBackdropStatus.openingCentered ||
                      status == WiredashBackdropStatus.closingCentered;
              if (animatingCenter ||
                  status == WiredashBackdropStatus.centered) {
                final feedbackStatus = context.feedbackModel.feedbackFlowStatus;
                final topBar = SizedBox(
                  height: appRect.top,
                  child: Row(
                    children: [
                      TronButton(
                        label: 'Back',
                        leadingIcon: Wirecons.arrow_left,
                        color: context.theme.secondaryColor,
                        onTap: () {
                          context.feedbackModel.goToStep(
                            FeedbackFlowStatus.screenshotsOverview,
                          );
                        },
                      ),
                      if (context.theme.windowSize.width > 680) ...[
                        const Spacer(),
                        const Padding(
                          padding: EdgeInsets.only(left: 8.0, right: 8.0),
                          child: FeedbackProgressIndicator(
                            flowStatus: FeedbackFlowStatus.screenshotsOverview,
                          ),
                        ),
                        const SizedBox(
                          height: 28,
                          child: VerticalDivider(),
                        ),
                      ],
                      if (context.theme.windowSize.width > 500) ...[
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 10,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              'Include a screenshot for more context',
                              style: context.theme.appbarTitle,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 2,
                            ),
                          ),
                        ),
                        const Spacer(),
                      ] else
                        const Spacer(flex: 10),
                      if (feedbackStatus ==
                          FeedbackFlowStatus.screenshotNavigating)
                        TronButton(
                          color: context.theme.primaryColor,
                          leadingIcon: Wirecons.camera,
                          iconOffset: const Offset(-.15, 0),
                          label: 'Capture',
                          onTap: () => context.feedbackModel.goToStep(
                            FeedbackFlowStatus.screenshotCapturing,
                          ),
                        ),
                      if (feedbackStatus ==
                          FeedbackFlowStatus.screenshotDrawing)
                        TronButton(
                          color: context.theme.primaryColor,
                          leadingIcon: Wirecons.check,
                          iconOffset: const Offset(-.15, 0),
                          label: 'Next',
                          onTap: () => context.feedbackModel.goToStep(
                            FeedbackFlowStatus.screenshotSaving,
                          ),
                        ),
                    ],
                  ),
                );
                content = Column(
                  children: [
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
                          child: status ==
                                      WiredashBackdropStatus.openingCentered ||
                                  status == WiredashBackdropStatus.centered
                              ? topBar
                              : null,
                        ),
                      ),
                    ),
                    // poor way to prevent overflow during enter/exit anim
                    if (!animatingCenter)
                      Container(
                        height: appRect.height,
                      ),
                    if (!animatingCenter)
                      Expanded(
                        child: Container(
                          width: double.infinity,
                          color: Colors.orange.withOpacity(0.1),
                        ),
                      ),
                  ],
                );
              }

              return content;
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

@visibleForTesting
ProjectCredentialValidator debugProjectCredentialValidator =
    const ProjectCredentialValidator();
