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
  /// await Wiredash.of(context).modifyMetaData(
  ///   (metaData) => metaData
  ///     ..userEmail = 'dash@wiredash.io'
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
  Future<void> modifyMetaData(
    WiredashMetaData Function(CustomizableWiredashMetaData metaData) mutation,
  ) async {
    _captureAppLocale();
    await _model.initializeMetadata();
    _model.metaData = mutation(_model.metaData!.makeCustomizable());
  }

  /// Resets all metadata to the initial state
  ///
  /// Call this method when the user signs out to make sure no old metadata like
  /// [WiredashMetaData.userId] or [WiredashMetaData.userEmail] is still set.
  /// Same goes for custom metadata.
  Future<void> resetMetaData() async {
    await _model.initializeMetadata();
  }

  /// Reads the currently set `metaData` (immutable)
  ///
  /// Deprecated, use the async [getMetaData] method instead. The synchronous
  /// getter will return an empty metaData, whereas the async version always
  /// returns a pre-filled version.
  ///
  /// Use [modifyMetaData] to update the metaData
  ///
  /// ### Discussion
  ///
  /// *Why is there no simple `metaData` setter?*
  ///
  /// Wiredash wants to provide a pre-filled, mutable [CustomizableWiredashMetaData]
  /// Object that can easily build upon and continuously filled with new data. But
  /// Wiredash also need to know when you actually changed the metadata.
  @Deprecated('Use the async getMetaData() instead')
  WiredashMetaData get metaData {
    // fallback to empty when metaData is not yet initialized
    final mutable =
        _model.metaData?.makeCustomizable() ?? CustomizableWiredashMetaData();
    // return an immutable view
    return mutable.copyWith(custom: Map.unmodifiable(mutable.custom));
  }

  /// Reads the currently set `metaData` (immutable)
  ///
  /// Use [modifyMetaData] to update the metaData
  ///
  /// ### Discussion
  ///
  /// *Why is there no simple `metaData` setter?*
  ///
  /// Wiredash wants to provide a pre-filled, mutable [CustomizableWiredashMetaData]
  /// Object that can easily build upon and continuously filled with new data. But
  /// Wiredash also need to know when you actually changed the metadata.
  Future<WiredashMetaData> getMetaData() async {
    _captureAppLocale();
    await _model.initializeMetadata();
    final mutable = _model.metaData!.makeCustomizable();
    // return an immutable view
    return mutable.copyWith(custom: Map.unmodifiable(mutable.custom));
  }

  /// Use this method to provide custom [userId] and [userEmail] to the feedback.
  ///
  /// The [userEmail] parameter can be used to prefill the email input field
  /// but it's up to the user to decide if he want's to include his email with
  /// the feedback.
  Future<void> Function({
    String? userId,
    String? userEmail,
  }) get setUserProperties => _setUserProperties;

  Future<void> _setUserProperties({
    Object? userId = defaultArgument,
    Object? userEmail = defaultArgument,
  }) async {
    await modifyMetaData(
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

  /// Deprecated, do not use anymore.
  ///
  /// Was used to attach custom [buildVersion], [buildNumber] and
  /// [buildCommit] to the feedback.
  ///
  /// This information is now collected automatically with platform APIs.
  ///
  /// Alternatively, on platforms, that do not provide the correct information
  /// (sometimes on web) set env.BUILD_VERSION, env.BUILD_NUMBER or
  /// env.BUILD_COMMIT during compile time with dart-define.
  /// https://docs.wiredash.io/sdk/custom-properties/#during-compile-time
  @Deprecated(
    'Build information has to be provided during build time or is now collected automatically with platform APIs (where possible). '
    'Set env.BUILD_VERSION, env.BUILD_NUMBER or env.BUILD_COMMIT with --dart-define. '
    'See https://docs.wiredash.io/sdk/custom-properties/#during-compile-time',
  )
  void setBuildProperties({
    String? buildVersion,
    String? buildNumber,
    String? buildCommit,
  }) {
    if (kDebugMode) {
      print(
        'Wiredash: setBuildProperties() is deprecated. The version information should be picked up automatically. '
        'Alternatively, set env.BUILD_VERSION, env.BUILD_NUMBER or env.BUILD_COMMIT during compile time. '
        'See https://docs.wiredash.io/sdk/custom-properties/#during-compile-time',
      );
    }
    // noop
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
  /// For more advanced styling check the [documentation](https://docs.wiredash.io/sdk/theming/)
  /// and use [Wiredash.theme].
  void show({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
    @Deprecated('Use options') WiredashFeedbackOptions? feedbackOptions,
    WiredashFeedbackOptions? options,
  }) {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _captureAppLocale();
    _model.feedbackOptionsOverride = options ?? feedbackOptions;
    _model.show(flow: WiredashFlow.feedback);
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

  /// Captures the current locale of the app when opening wiredash
  void _captureAppLocale() {
    final context = _model.services.wiredashWidget.showBuildContext;
    if (context == null) return;

    final locale = Localizations.maybeLocaleOf(context);
    _model.appLocaleFromContext = locale;
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
    final context = _model.services.wiredashWidget.showBuildContext;
    if (context != null) {
      // generate theme from current context
      if (inheritMaterialTheme == true) {
        final materialTheme = Theme.of(context);
        _model.themeFromContext = WiredashThemeData.fromColor(
          primaryColor: materialTheme.colorScheme.primary,
          secondaryColor: materialTheme.colorScheme.secondary,
          brightness: materialTheme.brightness,
        );
      }
      if (inheritCupertinoTheme == true) {
        final cupertinoTheme = CupertinoTheme.of(context);
        _model.themeFromContext = WiredashThemeData.fromColor(
          primaryColor: cupertinoTheme.primaryColor,
          brightness: cupertinoTheme.brightness ?? Brightness.light,
        );
      }
    }
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
    _captureAppLocale();
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
