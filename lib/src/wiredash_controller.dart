import 'package:flutter/foundation.dart';
import 'package:wiredash/src/common/translation/wiredash_translation.dart';
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
/// Wiredash.of(context).setOptions(appVersion: "1.4.3");
/// ```
class WiredashController {
  WiredashController(this._state) : assert(_state != null);

  final WiredashState _state;

  /// Use this method to provide your app version or to attach a custom [userId]
  /// to the feedback. The [userEmail] parameter can be used to prefill the
  /// email input field but it's up to the user to decide if he want's to
  /// include his email with the feedback.
  void setOptions({String appVersion, String userId, String userEmail}) {
    _state.userManager.appVersion = appVersion ?? _state.userManager.appVersion;
    _state.userManager.userId = userId ?? _state.userManager.userId;
    _state.userManager.userEmail = userEmail ?? _state.userManager.userEmail;
  }

  /// This will open the Wiredash feedback sheet and start the feedback process.
  ///
  /// Currently you can customize the theme and translation by providing your
  /// own [WiredashTheme] and / or [WiredashTranslation] to the [Wiredash]
  /// root widget. In a future release you'll be able to customize the SDK
  /// through the Wiredash admin console as well.
  void show() => _state.show();

  /// A [ValueNotifier] representing the current state of the capture UI. Use
  /// this to change your app's configuration when the user is in the process
  /// of taking a screenshot of your app - e.g. hiding sensitive information or
  /// disabling specific widgets.
  ///
  /// The [Confidential] widget can automatically hide sensitive widgets from
  /// being recorded in a feedback screenshot.
  ValueNotifier<bool> get visible => _state.captureKey.currentState.visible;
}
