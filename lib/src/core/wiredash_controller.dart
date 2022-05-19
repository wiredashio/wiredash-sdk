import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/_wiredash_internal.dart';
import 'package:wiredash/src/_wiredash_ui.dart';
import 'package:wiredash/src/core/context_cache.dart';
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
  void modifyMetaData(
    CustomizableWiredashMetaData Function(CustomizableWiredashMetaData metaData)
        mutation,
  ) {
    _model.metaData = mutation(_model.metaData);
  }

  /// Use this method to provide custom [userId]
  /// to the feedback. The [userEmail] parameter can be used to prefill the
  /// email input field but it's up to the user to decide if he want's to
  /// include his email with the feedback.
  @Deprecated('use modifyMetaData((metaData) => metaData)')
  void setUserProperties({String? userId, String? userEmail}) {
    modifyMetaData(
      (metaData) => metaData
        ..userId = userId ?? metaData.userId
        ..userEmail = userEmail ?? metaData.userEmail,
    );
  }

  /// Use this method to attach custom [buildVersion] and [buildNumber]
  ///
  /// If these values are also provided through dart-define during compile time
  /// then they will be overwritten by this method
  @Deprecated('use modifyMetaData((metaData) => metaData)')
  void setBuildProperties({String? buildVersion, String? buildNumber}) {
    modifyMetaData(
      (metaData) => metaData
        ..buildVersion = buildVersion ?? metaData.buildVersion
        ..buildNumber = buildNumber ?? metaData.buildNumber,
    );
  }

  /// This will open the Wiredash feedback sheet and start the feedback process.
  ///
  /// Currently you can customize the theme and translation by providing your
  /// own [WiredashTheme] and / or [WiredashTranslation] to the [Wiredash]
  /// root widget. In a future release you'll be able to customize the SDK
  /// through the Wiredash admin console as well.
  ///
  /// If a Wiredash feedback flow is already active (=a feedback sheet is open),
  /// does nothing.
  void show({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
  }) {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _captureAppLocale();
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
    return _model.services.backdropController
        .asValueNotifier((c) => c.isAppInteractive);
  }

  /// Captures the current locale of the app when opening wiredash
  void _captureAppLocale() {
    final context = _model.services.wiredashWidget.showBuildContext;
    assert(context != null);
    if (context == null) return;

    final locale = Localizations.maybeLocaleOf(context);
    _model.appLocale = locale;
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

extension NpsWiredash on WiredashController {
  void showNps({
    bool? inheritMaterialTheme,
    bool? inheritCupertinoTheme,
  }) {
    _captureAppTheme(inheritMaterialTheme, inheritCupertinoTheme);
    _model.show(flow: WiredashFlow.nps);
  }
}
