import 'package:flutter/foundation.dart';

/// Class retrieving basic build information about the app
///
/// The properties can be defined in Flutter >=1.17 by passing
/// `--dart-define` flag to the `flutter run` or `flutter build`.
///
/// For example:
/// ```
/// flutter build --dart-define=BUILD_NUMBER=$BUILD_NUMBER --dart-define=BUILD_VERSION=$BUILD_VERSION --dart-define=BUILD_COMMIT=$FCI_COMMIT
/// ```
class EnvBuildInfo {
  static const _buildNumber = bool.hasEnvironment('BUILD_NUMBER')
      ? String.fromEnvironment('BUILD_NUMBER')
      : null;
  static const _buildVersion = bool.hasEnvironment('BUILD_VERSION')
      ? String.fromEnvironment('BUILD_VERSION')
      : null;
  static const _buildCommit = bool.hasEnvironment("BUILD_COMMIT")
      ? String.fromEnvironment('BUILD_COMMIT')
      : null;

  /// env.BUILD_COMMIT
  static String? get buildCommit => _buildCommit;

  /// env.BUILD_NUMBER
  static String? get buildNumber => _buildNumber;

  /// env.BUILD_VERSION
  static String? get buildVersion => _buildVersion;
}

class BuildInfo {
  const BuildInfo({
    required this.compilationMode,
    this.buildVersion,
    this.buildNumber,
    this.buildCommit,
  });

  /// Semantic version name of the app
  final String? buildVersion;

  /// Always incrementing number of the build. (actually `int`)
  final String? buildNumber;

  /// Commit hash of the build
  final String? buildCommit;

  final CompilationMode compilationMode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BuildInfo &&
          runtimeType == other.runtimeType &&
          buildVersion == other.buildVersion &&
          buildNumber == other.buildNumber &&
          buildCommit == other.buildCommit &&
          compilationMode == other.compilationMode;

  @override
  int get hashCode =>
      buildVersion.hashCode ^
      buildNumber.hashCode ^
      buildCommit.hashCode ^
      compilationMode.hashCode;

  @override
  String toString() {
    return 'BuildInfo{compilationMode: $compilationMode, buildVersion: $buildVersion, buildNumber: $buildNumber, buildCommit: $buildCommit}';
  }
}

enum CompilationMode {
  /// [kReleaseMode]
  release,

  /// [kProfileMode]
  profile,

  /// [kDebugMode]
  debug,
}
