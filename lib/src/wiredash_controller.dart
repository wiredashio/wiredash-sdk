import 'package:flutter/foundation.dart';
import 'package:wiredash/src/wiredash_widget.dart';

/// Use this controller to interact with [Wiredash]
///
/// Start Wiredash:
/// ```dart
/// Wiredash.of(context).show();
/// ```
///
/// Add user information
/// ```dart
/// Wiredash.of(context).setIdentifiers(appVersion: "1.4.3");
/// ```
class WiredashController {
  WiredashController(this._state);

  final WiredashState _state;

  /// Use this method to provide custom [userId]
  /// to the feedback. The [userEmail] parameter can be used to prefill the
  /// email input field but it's up to the user to decide if he want's to
  /// include his email with the feedback.
  void setUserProperties({String? userId, String? userEmail}) {
    _state.userManager.userId = userId ?? _state.userManager.userId;
    _state.userManager.userEmail = userEmail ?? _state.userManager.userEmail;
  }

  /// Use this method to attach custom [buildVersion] and [buildNumber]
  ///
  /// If these values are also provided through dart-define during compile time
  /// then they will be overwritten by this method
  void setBuildProperties({String? buildVersion, String? buildNumber}) {
    _state.buildInfoManager.buildVersion =
        buildVersion ?? _state.buildInfoManager.buildVersion;
    _state.buildInfoManager.buildNumber =
        buildNumber ?? _state.buildInfoManager.buildNumber;
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
  void show() => _state.show();

  /// A [ValueNotifier] representing the current state of the capture UI. Use
  /// this to change your app's configuration when the user is in the process
  /// of taking a screenshot of your app - e.g. hiding sensitive information or
  /// disabling specific widgets.
  ///
  /// The [Confidential] widget can automatically hide sensitive widgets from
  /// being recorded in a feedback screenshot.
  ValueNotifier<bool> get visible => _state.captureKey.currentState!.visible;
}
