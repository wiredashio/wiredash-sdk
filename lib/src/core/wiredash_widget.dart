import 'dart:async';
import 'dart:ui' as ui;

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_feedback.dart';
import 'package:wiredash/src/_ps.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/analytics/event_submitter.dart';
import 'package:wiredash/src/core/context_cache.dart';
import 'package:wiredash/src/core/lifecycle/lifecycle_notifier.dart';
import 'package:wiredash/src/core/support/back_button_interceptor.dart';
import 'package:wiredash/src/core/support/not_a_widgets_app.dart';
import 'package:wiredash/src/feedback/feedback_backdrop.dart';
import 'package:wiredash/src/utils/disposable.dart';
import 'package:wiredash/wiredash.dart';

/// Capture in-app user feedback, wishes, ratings and much more
///
/// 1. Setup
/// Wrap you Application in [Wiredash] and pass in the apps [Navigator]
///
/// ```dart
///   @override
///   Widget build(BuildContext context) {
///     return Wiredash(
///       projectId: "YOUR-PROJECT-ID",
///       secret: "YOUR-SECRET",
///       child: MaterialApp(
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
    super.key,
    required this.projectId,
    required this.secret,
    this.environment,
    this.options,
    this.theme,
    this.feedbackOptions,
    this.psOptions,
    this.padding,
    this.collectMetaData,
    required this.child,
  });

  /// Your Wiredash projectId
  final String projectId;

  /// Your Wiredash project secret
  final String secret;

  /// The environment of your app, like 'prod', 'dev', 'staging'
  ///
  /// When null, defaults to 'prod' for release builds and 'dev' for debug builds and emulators.
  /// To disable the automatic environment detection, set `environment: 'prod'`.
  ///
  /// Setting an environment is useful to differentiate between different
  /// versions of your app allowing you to filter analytics and feedback by
  /// environment.
  ///
  /// White-label apps can use this to differentiate between different clients,
  /// when they share the same Wiredash project.
  ///
  /// {@macro environmentNameConstraints}
  final String? environment;

  /// Customize Wiredash's behaviour and language
  final WiredashOptionsData? options;

  /// Adds additional metadata to feedback
  ///
  /// This callback is called when Wiredash collects information about the
  /// device, app and session during the feedback or promoter score flow.
  /// It may be called once or multiple times during a single flow.
  ///
  /// Mutate the incoming `metaData` object and add or override values
  ///
  /// ```dart
  /// Wiredash(
  ///   projectId: "...",
  ///   secret: "...",
  ///   collectMetaData: (metaData) => metaData
  ///     ..userEmail = 'dash@wiredash.com'
  ///     ..userEmail = 'dash@wiredash.com'
  ///     ..custom['isPremium'] = false
  ///     ..custom['nested'] = {'wire': 'dash'},
  ///   child: MyApp(),
  /// ),
  /// ```
  final FutureOr<CustomizableWiredashMetaData> Function(
    CustomizableWiredashMetaData metaData,
  )? collectMetaData;

  /// Customize the feedback flow
  final WiredashFeedbackOptions? feedbackOptions;

  /// Customize when to show the promoter score flow
  final PsOptions? psOptions;

  /// Default visual properties, like colors and fonts for the Wiredash bottom
  /// sheet and the screenshot capture UI.
  ///
  /// Dark and light themes are supported, try it!
  ///
  /// ```dart
  /// return Wiredash(
  ///   projectId: "...",
  ///   secret: "...",
  ///   theme: WiredashThemeData.fromColor(
  ///     primaryColor: Colors.indigo,
  ///     brightness: Brightness.dark,
  ///   ).copyWith(
  ///     // further customizations
  ///   ),
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

  /// Tracks an event with Wiredash.
  ///
  /// This method allows you to record user interactions or other significant
  /// occurrences within your app and send them to the Wiredash service for
  /// analysis.
  ///
  /// ```dart
  /// await Wiredash.of(context).trackEvent('button_tapped', data: {
  ///  'button_id': 'submit_button',
  /// });
  /// ```
  ///
  /// **[eventName] constraints**
  /// {@macro eventNameConstraints}
  ///
  /// **[data] constraints**
  /// {@macro eventDataConstraints}
  ///
  /// **Event Sending Behavior:**
  ///
  /// * Events are batched and sent to the Wiredash server periodically at 30-second intervals.
  /// * The first batch of events is sent after a 5-second delay.
  /// * Events are also sent immediately when the app goes to the background (not applicable to web platforms).
  /// * If events cannot be sent due to network issues, they are stored locally and retried later.
  /// * Unsent events are discarded after 3 days.
  ///
  /// **Multiple Wiredash Widgets:**
  ///
  /// If you have multiple [Wiredash] widgets in your app with different projectIds,
  /// you can specify the desired [projectId] when creating [WiredashAnalytics].
  /// This ensures that the event is sent to the correct project.
  ///
  /// If no [projectId] is provided and multiple widgets are mounted, the event will be sent to
  /// the project associated with the first mounted widget. A warning message will also be logged
  /// to the console in this scenario.
  ///
  /// **Background Isolates:**
  ///
  /// When calling [trackEvent] from a background isolate, the event will be stored locally.
  /// The main isolate will pick up these events and send them along with the next batch or
  /// when the app goes to the background.
  ///
  /// **See also**
  ///
  /// Use [WiredashAnalytics] for easy mocking and testing
  ///
  /// ```dart
  /// final analytics = WiredashAnalytics();
  /// await analytics.trackEvent('Click Button', data: {/**/});
  ///
  /// // inject into other classes
  /// final bloc = MyBloc(analytics: analytics);
  /// ```
  ///
  /// Access the correct [Wiredash] project via context to send events to if you
  /// use multiple Wiredash widgets in your app. This way you don't have to
  /// specify the [projectId] every time you call [trackEvent].
  ///
  /// ```dart
  /// Wiredash.of(context).trackEvent('Click Button');
  /// ```
  static Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? data,
    String? projectId,
    String? environment,
  }) async {
    final analytics = WiredashAnalytics(
      projectId: projectId,
      environment: environment,
    );
    await analytics.trackEvent(eventName, data: data);
  }
}

class WiredashState extends State<Wiredash> {
  final GlobalKey _appKey = GlobalKey(debugLabel: 'app');

  final WiredashServices _services = WiredashServices();

  late final WiredashBackButtonDispatcher _backButtonDispatcher;

  final FocusScopeNode _appFocusScopeNode = FocusScopeNode();

  Disposable? _unregister;

  /// A way to access the services during testing
  @visibleForTesting
  WiredashServices get debugServices {
    if (kReleaseMode) {
      throw "Services can't be accessed in production code";
    }
    return _services;
  }

  @override
  void initState() {
    super.initState();
    _services.projectCredentialValidator.validate(
      projectId: widget.projectId,
      secret: widget.secret,
    );
    _verifySyncLocalizationsDelegate();

    _unregister = WiredashRegistry.instance.register(this);
    _services.updateWidget(widget);
    _services.addListener(_markNeedsBuild);
    _services.wiredashModel.addListener(_markNeedsBuild);
    _services.backdropController.addListener(_markNeedsBuild);

    _services.appLifecycleNotifier.addListener(() {
      final state = _services.appLifecycleNotifier.value;
      if (state == AppLifecycleState_hidden_compat()) {
        _services.syncEngine.onAppMovedToBackground();
      }
    });
    _onProjectEnvChanged();

    _backButtonDispatcher = WiredashBackButtonDispatcher()..initialize();
  }

  void _markNeedsBuild() {
    // rebuild the Wiredash widget state
    setState(() {});
  }

  /// Notifies the [EventSubmitter] to send all pending events to the server.
  ///
  /// This method is called by [WiredashAnalytics] when new events have been
  /// added or the app goes to the background.
  Future<void> triggerAnalyticsEventUpload() async {
    try {
      await _services.eventSubmitter.submitEvents();
    } catch (e, stack) {
      reportWiredashInfo(e, stack, 'Unexpected error while submitting events');
    }
  }

  @override
  void dispose() {
    _unregister?.dispose();
    _services.dispose();
    _backButtonDispatcher.dispose();
    _appFocusScopeNode.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(Wiredash oldWidget) {
    super.didUpdateWidget(oldWidget);

    _unregister?.dispose();
    _unregister = WiredashRegistry.instance.register(this);
    _services.updateWidget(widget);

    if (oldWidget.projectId != widget.projectId ||
        oldWidget.secret != widget.secret ||
        oldWidget.environment != widget.environment) {
      _services.projectCredentialValidator.validate(
        projectId: widget.projectId,
        secret: widget.secret,
      );
      _onProjectEnvChanged();
    }

    if (oldWidget.options?.localizationDelegate !=
        widget.options?.localizationDelegate) {
      _verifySyncLocalizationsDelegate();
    }
  }

  void _onProjectEnvChanged() {
    if (widget.environment != null) {
      validateEnvironment(widget.environment!);
    }
    final inFakeAsync = _services.testDetector.inFakeAsync();
    if (!inFakeAsync) {
      // start the sync engine
      unawaited(_services.syncEngine.onWiredashInit());
    }
  }

  @override
  Widget build(BuildContext context) {
    // Assign app an key so it doesn't lose state when wrapped, unwrapped
    // with widgets
    Widget app = KeyedSubtree(
      key: _appKey,
      child: widget.child,
    );

    // Fix focus bug for apps that use go_router
    // https://github.com/flutter/flutter/issues/119849
    app = FocusScope(
      node: _appFocusScopeNode,
      child: app,
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
        case WiredashFlow.promoterScore:
          return PsModelProvider(
            psModel: _services.psModel,
            child: PsBackdrop(child: app),
          );
      }
    }();

    final child = WiredashTheme(
      data: theme,
      child: flow,
    );

    final Widget backdrop = NotAWidgetsApp(
      child: _backButtonDispatcher.wrap(
        child: Builder(
          builder: (context) {
            // Check if we have a Localizations widget as parent. This works because
            // WidgetsLocalizations is a required for construction
            final parentLocalization =
                Localizations.of(context, WidgetsLocalizations);

            final wiredashL10nDelegate = widget.options?.localizationDelegate;
            final delegates = [
              // whatever is provided in the WiredashOptions
              // Order matters here. Localizations will pick the first in the list
              if (wiredashL10nDelegate != null) wiredashL10nDelegate,
              // The wiredash localizations, used unless overridden by ☝️
              WiredashLocalizations.delegate,

              // WidgetsLocalizations is required. Unless we know it already
              // exists, add it here
              if (parentLocalization == null)
                DefaultWidgetsLocalizations.delegate,
            ];

            if (parentLocalization == null) {
              // no Localizations widget as parent, we can't override, just provide
              return Localizations(
                delegates: delegates,
                locale: _currentLocale,
                child: child,
              );
            } else {
              // There might be some Localizations from the parent widget that
              // might be interesting for children. Pass them along.
              return Localizations.override(
                context: context,
                delegates: delegates,
                locale: _currentLocale,
                child: child,
              );
            }
          },
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
          child: backdrop,
        ),
      ),
    );
  }

  /// Returns `true` if a WiredashLocalizations for the [locale] exists
  bool _isLocaleSupported(Locale locale) {
    final match = WiredashLocalizations.supportedLocales.firstWhereOrNull((it) {
      if (it == locale) {
        // exact match, perfect
        return true;
      }

      // just the language code is close enough
      return it.languageCode == locale.languageCode;
    });
    if (match != null) {
      return true;
    }

    final delegate = widget.options?.localizationDelegate;
    if (delegate != null && delegate.isSupported(locale)) {
      // A custom localization supports this locale
      return true;
    }
    return false;
  }

  /// Current locale used by Wiredash widget
  Locale get _currentLocale {
    final localesInOrder = [
      // Use what users set in WiredashOptions has the highest priority
      widget.options?.locale,
      // Use what users see in the app
      _services.wiredashModel.sessionMetaData?.appLocale,
    ]
        // Switch to .nonNulls when minSdk is Dart 3.0
        // ignore: deprecated_member_use
        .whereNotNull();

    for (final locale in localesInOrder) {
      if (_isLocaleSupported(locale)) {
        return locale;
      }
    }

    // Use what's set by the operating system
    return _defaultLocale;
  }

  void _verifySyncLocalizationsDelegate() {
    assert(() {
      final delegate = widget.options?.localizationDelegate;
      if (delegate == null) {
        return true;
      }
      final locale = _currentLocale;
      if (!delegate.isSupported(locale)) {
        // load should not be called
        return true;
      }
      final loadFuture = delegate.load(locale);
      if (loadFuture is! SynchronousFuture) {
        reportWiredashInfo(
          'Warning: $delegate load() is async',
          StackTrace.current,
          'Warning: ${delegate.runtimeType}.load() returned a Future for Locale "$locale".\n'
              'This will lead to your app losing all its state when you open Wiredash!\n'
              '\tDO return a SynchronousFuture from your LocalizationsDelegate.load() method. \n'
              '\tDO NOT use the async keyword in LocalizationsDelegate.load().\n'
              'When load() returns SynchronousFuture the Localizations widget can build your app widget with the already loaded localizations at the first frame.\n'
              'For more information visit https://github.com/wiredashio/wiredash-sdk/issues/341',
        );
      }
      return true;
    }());
  }
}

Locale get _defaultLocale {
  // Flutter 1.26 (2.0.1) returns `Locale?`, 1.27 `Locale`
  // ignore: unnecessary_nullable_for_final_variable_declarations, deprecated_member_use
  final Locale? locale = ui.window.locale;
  return locale ?? const Locale('en', 'US');
}

/// Validates the value [Wiredash.environment]
///
/// {@template environmentNameConstraints}
/// The environment needs to be
/// - at least 2 characters long, max 32 characters
/// - only use lowercase a-z, - and _
/// - start with a letter (a-z)
/// {@endtemplate}
void validateEnvironment(String environment) {
  if (environment.isEmpty) {
    throw ArgumentError.value(
      environment,
      'environment',
      'The environment must not be empty',
    );
  }
  // at least two characters
  if (environment.length < 2 || environment.length > 32) {
    throw ArgumentError.value(
      environment,
      'environment',
      '$environment must be between 2 and 32 characters long',
    );
  }

  if (environment.contains(' ')) {
    throw ArgumentError.value(
      environment,
      'environment',
      '$environment must not contain spaces',
    );
  }

  if (environment.contains('ä') ||
      environment.contains('ö') ||
      environment.contains('ü')) {
    throw ArgumentError.value(
      environment,
      'environment',
      '$environment must not contain umlauts',
    );
  }

  String firstChar = String.fromCharCode(environment.codeUnitAt(0));
  if (firstChar == '#') {
    firstChar = String.fromCharCode(environment.codeUnitAt(1));
  }
  final regex = RegExp('^[a-z]');
  if (!regex.hasMatch(firstChar)) {
    throw ArgumentError.value(
      environment,
      'environment',
      '$environment must start with a letter (a-z)',
    );
  }

  /// The complete regular expression to validate a event name.
  ///
  /// All checks in validateEventName are based on this regular expression but
  /// are split up for better error messages.
  final environmentRegExp = RegExp(r'^[a-z][a-z_-]+$');
  if (!environmentRegExp.hasMatch(environment)) {
    throw ArgumentError.value(
      environment,
      'environment',
      '$environment does not match $environmentRegExp',
    );
  }
}
