/// Information about the user app
class AppInfo {
  final String? appName;
  final String? bundleId;
  final String? version;
  final String? buildNumber;

  const AppInfo({
    this.appName,
    this.bundleId,
    this.version,
    this.buildNumber,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppInfo &&
          runtimeType == other.runtimeType &&
          appName == other.appName &&
          bundleId == other.bundleId &&
          version == other.version &&
          buildNumber == other.buildNumber);

  @override
  int get hashCode =>
      appName.hashCode ^
      bundleId.hashCode ^
      version.hashCode ^
      buildNumber.hashCode;

  @override
  String toString() {
    return 'AppInfo{' +
        ' appName: $appName,' +
        ' applicationId: $bundleId,' +
        ' version: $version,' +
        ' buildNumber: $buildNumber,' +
        '}';
  }

  AppInfo copyWith({
    String? appLocale,
    String? appName,
    String? applicationId,
    String? version,
    String? buildNumber,
  }) {
    return AppInfo(
      appName: appName ?? this.appName,
      bundleId: applicationId ?? this.bundleId,
      version: version ?? this.version,
      buildNumber: buildNumber ?? this.buildNumber,
    );
  }
}
