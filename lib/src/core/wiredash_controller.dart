import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/context_cache.dart';
// ignore: unnecessary_import
import 'package:wiredash/src/utils/object_util.dart';
import 'package:wiredash/wiredash.dart';

/// Use this controller to interact with [Wiredash]
///
/// Start Wiredash:
/// ```dart
/// Wiredash.of(context).show();
/// ```
///
/// Add user information
/// ```dart
/// Wiredash.of(context)
///     .setBuildProperties(buildVersion: "1.4.3", buildNumber: "42");
/// ```
class WiredashController {
  WiredashController(this._model);

  final WiredashModel _model;

  /// Modify the metadata that will be collected with Wiredash
  ///
  /// The metadata include user information (userId and userEmail) and
  /// any custom data (Map<String, Object?>) you want to have attached to
  /// feedback.
  ///
  /// Setting the userEmail prefills the email field.
  ///
  /// The build information is prefilled with
  /// - build data from [EnvBuildInfo] injected during compile time
  /// - app information like the app version
  /// - session information like the appLocale (from context)
  ///
  /// Usage:
  ///
  /// ```dart
  /// Wiredash.of(context).modifyMetaData(
  ///   (metaData) => metaData
  ///     ..userEmail = 'dash@wiredash.com'
  ///     ..buildCommit = '43f23dd'
  ///     ..custom['screen'] = 'HomePage'
  ///     ..custom['isPremium'] = false,
  /// );
  /// ```
  ///
  /// ### Reset
  ///
  /// To reset all metadata (i.e. when the user signs out) use:
  ///
  /// ```dart
  /// await Wiredash.of(context).resetMetaData();
  /// ```
  ///
  /// ## Scope
  ///
  /// Please do not keep a reference to the incoming `metaData` parameter. The
  /// reference might not be outdated and not be used. The `metaData` object is
  /// only guaranteed to be up-to-date within the `modifyMetaData` method.
  void modifyMetaData(
    CustomizableWiredashMetaData Function(CustomizableWiredashMetaData metaData)
        mutation,
  ) {
    _captureSessionMetaData();
    final before = _model.customizableMetaData.copyWith();
    final after = mutation(before);
    _model.customizableMetaData = after;
  }

  /// Resets all metadata to the initial state
  ///
  /// Call this method when the user signs out to make sure no old metadata like
  /// [WiredashMetaData.userId] or [WiredashMetaData.userEmail] is still set.
  /// Same goes for custom metadata.
  void resetMetaData() {
    _model.customizableMetaData = CustomizableWiredashMetaData();
  }

  /// Reads the currently set `metaData` (immutable)
  ///
  /// Use [modifyMetaData] to update the metaData
  ///
  /// ### Discussion
  ///
  /// *Why is there no simple `metaData` setter?*
  ///
  /// Wiredash wants to provide a mutable [CustomizableWiredashMetaData]
  /// Object that can easily build upon and continuously filled with new data. But
  /// Wiredash also need to know when you actually changed the metadata.
  CustomizableWiredashMetaData get metaData {
    final mutable = _model.customizableMetaData;
    // return an immutable view
    return mutable.copyWith(custom: Map.unmodifiable(mutable.custom));
  }

  /// Use this method to provide custom [userId] and [userEmail] to the feedback.
  ///
  /// The [userEmail] parameter can be used to prefill the email input field
  /// but it's up to the user to decide if he want's to include his email with
  /// the feedback.
  void Function({
    String? userId,
    String? userEmail,
  }) get setUserProperties => _setUserProperties;

  void _setUserProperties({
    Object? userId = defaultArgument,
    Object? userEmail = defaultArgument,
  }) {
    modifyMetaData(
      (metaData) {
        if (userId != defaultArgument) {
          metaData.userId = userId as String?;
        }
        if (userEmail != defaultArgument) {
          metaData.userEmail = userEmail as String?;
        }
        return metaData;
      },
    );
  }

  /// This will open Wiredash and start the feedback flow.
  ///
  /// Use [options] to configure the feedback flow.
  /// Setting the [options] here will override [Wiredash.feedbackOptions].
  ///
  /// If Wiredash is already open this method does nothing.
  ///
  /// ## Theming
  ///
  /// As a quick way to style Wiredash based on your app [Theme] set
  /// [inheritMaterialTheme]/[inheritCupertinoTheme] to `true`.
  /// Wiredash will automatically read colors from [context], overriding
  /// [Wiredash.theme].
  ///
  /// For more advanced styling check the [documentation](https://docs.wiredash.com/reference/sdk/theming)
  /// and use [Wiredash.theme].
  void show({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
    WiredashFeedbackOptions? options,
  }) {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _captureSessionMetaData();
    _model.feedbackOptionsOverride = options;
    _model.show(flow: WiredashFlow.feedback);
  }

  /// Tracks an event with Wiredash.
  ///
  /// This method allows you to record user interactions or other significant
  /// occurrences within your app and send them to the Wiredash service for
  /// analysis.
  ///
  /// Access the correct [Wiredash] project via [context] to send events to if you
  /// use multiple Wiredash widgets in your app. This way you don't have to
  /// specify the [projectId] every time you call [trackEvent].
  ///
  /// ```dart
  /// final analytics = WiredashAnalytics();
  /// await analytics.trackEvent('button_tapped', data: {
  ///  'button_id': 'submit_button',
  /// });
  /// ```
  /// ### [eventName] constraints
  /// {@macro eventNameConstraints}
  ///
  /// ### [data] constraints
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
  /// Use [Wiredash.trackEvent] for easy access from everywhere in your app.
  ///
  /// ```dart
  /// await Wiredash.trackEvent('Click Button', data: {/**/});
  /// ```
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
  Future<void> trackEvent(
    String eventName, {
    Map<String, Object?>? data,
  }) async {
    final wiredash = _model.services.wiredashWidget;
    Wiredash.trackEvent(
      eventName,
      data: data,
      projectId: wiredash?.projectId,
      environment: wiredash?.environment,
    );
  }

  /// Submits all pending analytics events to the server
  ///
  /// Usually, events are submitted automatically, batched every 30 seconds, and
  /// when the app goes to the background.
  ///
  /// This methods allows manually submitting events at any time.
  ///
  /// See [trackEvent] for more information on how events are sent.
  Future<void> forceSubmitEvents() async {
    await _model.forceSubmitAnalyticsEvents();
  }

  /// A [ValueNotifier] representing the current state of the capture UI. Use
  /// this to change your app's configuration when the user is in the process
  /// of taking a screenshot of your app - e.g. hiding sensitive information or
  /// disabling specific widgets.
  ///
  /// The [Confidential] widget can automatically hide sensitive widgets from
  /// being recorded in a feedback screenshot.
  ValueNotifier<bool> get visible {
    const openStates = [
      WiredashBackdropStatus.centered,
      WiredashBackdropStatus.openingCentered,
      WiredashBackdropStatus.closingCentered,
    ];
    return _model.services.backdropController
        .asValueNotifier((c) => openStates.contains(c.backdropStatus));
  }

  /// Captures the session information of the app based on the [BuildContext]
  void _captureSessionMetaData() {
    final brightness = _detectAppBrightness();
    final locale = _detectAppLocale();

    final sessionMetaData = SessionMetaData(
      appLocale: locale,
      appBrightness: brightness,
    );

    _model.sessionMetaData = sessionMetaData;
  }

  /// Captures the current locale of the app when opening wiredash
  Locale? _detectAppLocale() {
    final context = _model.services.wiredashWidget?.showBuildContext;
    if (context == null) return null;

    final locale = Localizations.maybeLocaleOf(context);
    return locale;
  }

  /// Search the user context for the app theme
  void _captureAppTheme(
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
  ) {
    assert(
      () {
        if (inheritCupertinoTheme == true && inheritMaterialTheme == true) {
          throw 'You can not enabled both, '
              'inheritCupertinoTheme and inheritMaterialTheme';
        }
        return true;
      }(),
    );

    // reset theme at every call
    _model.themeFromContext = null;
    if (inheritMaterialTheme == true) {
      final materialTheme = _detectMaterialTheme();
      if (materialTheme != null) {
        _model.themeFromContext = WiredashThemeData.fromColor(
          primaryColor: materialTheme.colorScheme.primary,
          secondaryColor: materialTheme.colorScheme.secondary,
          brightness: materialTheme.brightness,
        );
      }
    }
    if (inheritCupertinoTheme == true) {
      final cupertinoTheme = _detectCupertinoTheme();
      if (cupertinoTheme != null) {
        _model.themeFromContext = WiredashThemeData.fromColor(
          primaryColor: cupertinoTheme.primaryColor,
          brightness: cupertinoTheme.brightness ?? Brightness.light,
        );
      }
    }
  }

  /// Captures the current brightness of the app by material or cupertino theme
  Brightness? _detectAppBrightness() {
    final materialBrightness = _detectMaterialTheme()?.brightness;
    if (materialBrightness != null) {
      return materialBrightness;
    }
    final cupertinoBrightness = _detectCupertinoTheme()?.brightness;
    if (cupertinoBrightness != null) {
      return cupertinoBrightness;
    }
    return null;
  }

  /// Search the user context for the material theme
  ThemeData? _detectMaterialTheme() {
    final context = _model.services.wiredashWidget?.showBuildContext;
    if (context != null) {
      return Theme.of(context);
    }
    return null;
  }

  /// Search the user context for the cupertino theme
  CupertinoThemeData? _detectCupertinoTheme() {
    final context = _model.services.wiredashWidget?.showBuildContext;
    if (context != null) {
      return CupertinoTheme.of(context);
    }
    return null;
  }
}

/// Methods for promoter score related features
extension PromoterScoreWiredash on WiredashController {
  /// Probably shows the Promoter Score survey depending on [options],
  /// specifically [PsOptions.frequency], [PsOptions.initialDelay] and
  /// [PsOptions.minimumAppStarts] settings.
  ///
  /// Wiredash decides whether it is a good time to show the promoter score
  /// survey or not, making sure your users don't see the promoter score
  /// survey too often while maintaining a continuous stream of promoter score
  /// ratings.
  ///
  /// Use [force] to explicitly show open the promoter score survey.
  /// This is useful when you want to trigger the flow at specific/rare times
  /// in your business logic.
  /// E.g. a user has paired their Action camera and transferred more than three
  /// pictures.
  ///
  /// This method returns `true` when the flow got opened or `false` when it was
  /// not a good time to show it.
  ///
  /// When providing [options], those settings will be used, overwriting the
  /// ones defined in [Wiredash.psOptions].
  /// The [options] will then be merged with [defaultPsOptions], filling your
  /// `null` values
  Future<bool> showPromoterSurvey({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
    PsOptions? options,
    bool? force,
  }) async {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _captureSessionMetaData();
    _model.psOptionsOverride = options;

    if (force == true) {
      await _model.show(flow: WiredashFlow.promoterScore);
      return true;
    } else {
      final actualOptions = _model.psOptions;

      final properties = DiagnosticPropertiesBuilder();
      final trigger = _model.services.psTrigger;
      final shouldShow = await trigger.shouldShowPromoterSurvey(
        options: actualOptions,
        diagnosticProperties: properties,
      );
      if (shouldShow) {
        await _model.show(flow: WiredashFlow.promoterScore);
        return true;
      } else {
        final reasons = properties.properties.join('\n - ');
        // ignore: avoid_print
        print(
          'Wiredash: Not showing promoter score survey because:\n - $reasons',
        );
        if (kDebugMode) {
          print(
            'For testing, use Wiredash.of(context).showPromoterSurvey(force: true);',
          );
        }
        return false;
      }
    }
  }
}
