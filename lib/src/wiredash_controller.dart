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

  final WiredashWidgetState _state;

  /// Use this method to provide your app version or to attach a custom [userId]
  /// to the feedback. The [userEmail] parameter can be used to prefill the
  /// email input field but it's up to the user to decide if he want's to
  /// include his email with the feedback.
  void setOptions({String appVersion, String userId, String userEmail}) {
    _state.data.appVersion = appVersion ?? _state.data.appVersion;
    _state.data.userId = userId ?? _state.data.userId;
    _state.data.userEmail = userEmail ?? _state.data.userEmail;
  }

  /// This will open the Wiredash feedback sheet and start the feedback process.
  ///
  /// Currently you can customize the theme and translation by providing your
  /// own [WiredashTheme] and / or [WiredashTranslation] to the [Wiredash]
  /// root widget. In a future release you'll be able to customize the SDK
  /// through the Wiredash admin console as well.
  void show() => _state.data.show();
}
