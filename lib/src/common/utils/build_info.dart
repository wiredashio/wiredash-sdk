/// Class retrieving basic build information about the app
/// 
/// The properties can be defined in Flutter >=1.17 by passing
/// `--dart-define` flag to the `flutter run` or `flutter build`.
/// 
/// For example:
/// ```
/// flutter build --dart-define=BUILD_NUMBER=$BUILD_NUMBER --dart-define=BUILD_COMMIT=$FCI_COMMIT
/// ```
class BuildInfo {
  static const buildNumber = bool.hasEnvironment('BUILD_NUMBER')
      ? String.fromEnvironment('BUILD_NUMBER')
      : null;
  static const buildCommit = bool.hasEnvironment("BUILD_COMMIT")
      ? String.fromEnvironment('BUILD_COMMIT')
      : null;
}
