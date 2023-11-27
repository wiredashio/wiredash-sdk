import 'dart:ui';

/// Data tha is extracted from the app [BuildContext] when opening Wiredash.
class SessionMetaData {
  const SessionMetaData({
    this.appLocale,
    this.appBrightness,
  });

  /// The current locale of the app
  final Locale? appLocale;

  /// The current brightness of the app
  ///
  /// By default, captured from the material or cupertino theme
  final Brightness? appBrightness;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SessionMetaData &&
          runtimeType == other.runtimeType &&
          appLocale == other.appLocale &&
          appBrightness == other.appBrightness);

  @override
  int get hashCode => appLocale.hashCode ^ appBrightness.hashCode;

  @override
  String toString() {
    return 'SessionMetaData{ '
        ' appLocale: ${appLocale?.toLanguageTag()}, '
        ' appBrightness: $appBrightness'
        '}';
  }

  SessionMetaData copyWith({
    Locale? appLocale,
    Brightness? appBrightness,
  }) {
    return SessionMetaData(
      appLocale: appLocale ?? this.appLocale,
      appBrightness: appBrightness ?? this.appBrightness,
    );
  }
}
