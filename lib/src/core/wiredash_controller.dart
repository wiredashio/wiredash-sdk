import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/context_cache.dart';
import 'package:wiredash/src/utils/object_util.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash/wiredash_preview.dart';

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
  /// The metadata include user information (userId and userEmail),
  /// build information (version, buildNumber, commit) and
  /// any custom data (Map<String, Object?>) you want to have attached to
  /// feedback.
  ///
  /// Setting the userEmail prefills the email field.
  ///
  /// The build information is prefilled by [EnvBuildInfo], reading the build
  /// environment variables during compilation.
  ///
  /// Usage:
  ///
  /// ```dart
  /// Wiredash.of(context).modifyMetaData(
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
  /// Wiredash.of(context)
  ///     .modifyMetaData((_) => CustomizableWiredashMetaData.populated());
  /// ```
  ///
  /// The metaData will be completely overridden with the values from the
  /// returned object.
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
    _model.metaData = mutation(_model.metaData);
  }

  /// Reads the currently set `metaData` (immutable)
  ///
  /// Use [modifyMetaData] to update the metaData
  ///
  /// ### Discussion
  ///
  /// *Why is there no simple `metaData` setter?*
  ///
  /// Wiredash wants to provide a mutable [CustomizableWiredashMetaData] Object
  /// that can easily build upon and continuously filled with new data. But
  /// Wiredash also need to know when you actually changed the metadata.
  /// [modifyMetaData] is executed immediately (like setState) which solves both.
  WiredashMetaData get metaData {
    final mutable = _model.metaData;
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

  /// Use this method to attach custom [buildVersion], [buildNumber] and
  /// [buildCommit] to the feedback.
  ///
  /// If these values are also provided through dart-define during compile time
  /// then they will be overwritten by this method;
  void Function({
    String? buildVersion,
    String? buildNumber,
    String? buildCommit,
  }) get setBuildProperties => _setBuildProperties;

  void _setBuildProperties({
    Object? buildVersion = defaultArgument,
    Object? buildNumber = defaultArgument,
    Object? buildCommit = defaultArgument,
  }) {
    modifyMetaData((metaData) {
      if (buildVersion != defaultArgument) {
        metaData.buildVersion = buildVersion as String?;
      }
      if (buildNumber != defaultArgument) {
        metaData.buildNumber = buildNumber as String?;
      }
      if (buildCommit != defaultArgument) {
        metaData.buildCommit = buildCommit as String?;
      }
      return metaData;
    });
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
    assert(context != null);
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

/// Methods for NPS related features
extension NpsWiredash on WiredashController {
  /// Probably shows the Net Promoter Score survey depending on [options],
  /// specifically [NpsOptions.frequency], [NpsOptions.initialDelay] and
  /// [NpsOptions.minimumAppStarts] settings.
  ///
  /// Wiredash decides whether it is a good time to show the NPS flow or not,
  /// making sure your users don't see the NPS flow too often while maintaining
  /// a continuous stream of NPS feedback.
  ///
  /// Use [force] to explicitly show open the NPS survey.
  /// This is useful when you want to trigger the flow at specific/rare times
  /// in your business logic.
  /// E.g. a user has paired their Action camera and transferred more than three
  /// pictures.
  ///
  /// This method returns `true` when the flow got opened or `false` when it was
  /// not a good time to show it.
  ///
  /// When providing [options], those settings will be used, overwriting the
  /// ones defined in [Wiredash.npsOptions].
  /// The [options] will then be merged with [defaultNpsOptions], filling your
  /// `null` values
  Future<bool> showNps({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
    NpsOptions? options,
    bool? force,
  }) async {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _captureAppLocale();
    _model.npsOptionsOverride = options;

    if (force == true) {
      await _model.show(flow: WiredashFlow.nps);
      return true;
    } else {
      final actualOptions = _model.npsOptions;

      final properties = DiagnosticPropertiesBuilder();
      final trigger = _model.services.npsTrigger;
      final shouldShow = await trigger.shouldShowNps(
        options: actualOptions,
        diagnosticProperties: properties,
      );
      if (shouldShow) {
        await _model.show(flow: WiredashFlow.nps);
        return true;
      } else {
        final reasons = properties.properties.join('\n - ');
        // ignore: avoid_print
        print('Wiredash: Not showing NPS because:\n - $reasons');
        if (kDebugMode) {
          print('For testing, use Wiredash.of(context).showNps(force: true);');
        }
        return false;
      }
    }
  }
}
