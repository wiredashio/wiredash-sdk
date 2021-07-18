import 'package:flutter/foundation.dart';

class DeviceInfo {
  final bool? appIsDebug;
  final String? appVersion;
  final String? buildNumber;
  final String? buildCommit;
  final String? deviceId;
  final String? locale;
  final List<double>? padding;
  final List<double>? physicalSize;
  final double? pixelRatio;

  /// A string representing the operating system or platform.
  ///
  /// Platform.operatingSystem
  final String? platformOS;

  /// A string representing the version of the operating system or platform.
  ///
  /// Platform.operatingSystemVersion
  final String? platformOSBuild;

  /// The version of the current Dart runtime.
  ///
  /// Platform.version
  final String? platformVersion;

  final double? textScaleFactor;
  final List<double>? viewInsets;

  /// When in web, the full user agent String of the browser
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
  final String? userAgent;

  const DeviceInfo({
    this.appIsDebug,
    this.appVersion,
    this.buildNumber,
    this.buildCommit,
    this.deviceId,
    this.locale,
    this.padding = const [],
    this.physicalSize = const [],
    this.pixelRatio,
    this.platformOS,
    this.platformOSBuild,
    this.platformVersion,
    this.textScaleFactor,
    this.viewInsets = const [],
    this.userAgent,
  });

  DeviceInfo copyWith({
    bool? appIsDebug,
    String? appVersion,
    String? buildNumber,
    String? buildCommit,
    String? deviceId,
    String? locale,
    List<double>? padding,
    List<double>? physicalSize,
    double? pixelRatio,
    String? platformOS,
    String? platformOSBuild,
    String? platformVersion,
    double? textScaleFactor,
    List<double>? viewInsets,
    String? userAgent,
  }) {
    return DeviceInfo(
      appIsDebug: appIsDebug ?? this.appIsDebug,
      appVersion: appVersion ?? this.appVersion,
      buildNumber: buildNumber ?? this.buildNumber,
      buildCommit: buildCommit ?? this.buildCommit,
      deviceId: deviceId ?? this.deviceId,
      locale: locale ?? this.locale,
      padding: padding ?? this.padding,
      physicalSize: physicalSize ?? this.physicalSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      platformOS: platformOS ?? this.platformOS,
      platformOSBuild: platformOSBuild ?? this.platformOSBuild,
      platformVersion: platformVersion ?? this.platformVersion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      viewInsets: viewInsets ?? this.viewInsets,
      userAgent: userAgent ?? this.userAgent,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo{'
        'appIsDebug: $appIsDebug, '
        'appVersion: $appVersion, '
        'buildNumber: $buildNumber, '
        'buildCommit: $buildCommit, '
        'deviceId: $deviceId, '
        'locale: $locale, '
        'padding: $padding, '
        'physicalSize: $physicalSize, '
        'pixelRatio: $pixelRatio, '
        'platformOS: $platformOS, '
        'platformOSBuild: $platformOSBuild, '
        'platformVersion: $platformVersion, '
        'textScaleFactor: $textScaleFactor, '
        'viewInsets: $viewInsets, '
        'userAgent: $userAgent, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          appIsDebug == other.appIsDebug &&
          appVersion == other.appVersion &&
          buildNumber == other.buildNumber &&
          buildCommit == other.buildCommit &&
          deviceId == other.deviceId &&
          locale == other.locale &&
          listEquals(padding, other.padding) &&
          listEquals(physicalSize, other.physicalSize) &&
          pixelRatio == other.pixelRatio &&
          platformOS == other.platformOS &&
          platformOSBuild == other.platformOSBuild &&
          platformVersion == other.platformVersion &&
          textScaleFactor == other.textScaleFactor &&
          listEquals(viewInsets, other.viewInsets) &&
          userAgent == other.userAgent);

  @override
  int get hashCode =>
      appIsDebug.hashCode ^
      appVersion.hashCode ^
      buildNumber.hashCode ^
      buildCommit.hashCode ^
      deviceId.hashCode ^
      locale.hashCode ^
      padding.hashCode ^
      physicalSize.hashCode ^
      pixelRatio.hashCode ^
      platformOS.hashCode ^
      platformOSBuild.hashCode ^
      platformVersion.hashCode ^
      textScaleFactor.hashCode ^
      viewInsets.hashCode ^
      userAgent.hashCode;
}
