import 'package:flutter/foundation.dart';

/// Class retrieving basic build information about the app
///
/// The properties can be defined in Flutter >=1.17 by passing
/// `--dart-define` flag to the `flutter run` or `flutter build`.
///
/// For example:
/// ```
/// flutter build --dart-define=BUILD_NUMBER=$BUILD_NUMBER \
///   --dart-define=BUILD_VERSION=$BUILD_VERSION \
///   --dart-define=BUILD_COMMIT=$FCI_COMMIT
/// ```
class EnvBuildInfo {
  static const _buildNumber = bool.hasEnvironment('BUILD_NUMBER')
      ? String.fromEnvironment('BUILD_NUMBER')
      : null;
  static const _buildVersion = bool.hasEnvironment('BUILD_VERSION')
      ? String.fromEnvironment('BUILD_VERSION')
      : null;
  static const _buildCommit = bool.hasEnvironment('BUILD_COMMIT')
      ? String.fromEnvironment('BUILD_COMMIT')
      : null;

  /// env.BUILD_COMMIT
  static String? get buildCommit => _buildCommit;

  /// env.BUILD_NUMBER
  static String? get buildNumber => _buildNumber;

  /// env.BUILD_VERSION
  static String? get buildVersion => _buildVersion;
}

/// Compile time information about the app
class BuildInfo {
  const BuildInfo({
    required this.compilationMode,
    this.buildVersion,
    this.buildNumber,
    this.buildCommit,
  });

  /// Semantic version name of the app (env.BUILD_VERSION)
  final String? buildVersion;

  /// Always incrementing number of the build. (actually `int`) (env.BUILD_NUMBER)
  final String? buildNumber;

  /// Commit hash of the build (env.BUILD_COMMIT)
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
    return 'BuildInfo{compilationMode: $compilationMode, '
        'buildVersion: $buildVersion, '
        'buildNumber: $buildNumber, '
        'buildCommit: $buildCommit'
        '}';
  }

  BuildInfo copyWith({
    String? buildVersion,
    String? buildNumber,
    String? buildCommit,
    CompilationMode? compilationMode,
  }) {
    return BuildInfo(
      buildVersion: buildVersion ?? this.buildVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      buildCommit: buildCommit ?? this.buildCommit,
      compilationMode: compilationMode ?? this.compilationMode,
    );
  }
}

BuildInfo getBuildInformation() {
  return BuildInfo(
    compilationMode: getCompilationMode(),
    buildVersion: EnvBuildInfo.buildVersion,
    buildNumber: EnvBuildInfo.buildNumber,
    buildCommit: EnvBuildInfo.buildCommit,
  );
}

CompilationMode getCompilationMode() {
  if (kDebugMode) return CompilationMode.debug;
  if (kProfileMode) return CompilationMode.profile;
  return CompilationMode.release;
}

/// The compile mode the Flutter app was built with
enum CompilationMode {
  /// [kReleaseMode]
  release,

  /// [kProfileMode]
  profile,

  /// [kDebugMode]
  debug,
}
