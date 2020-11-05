import 'package:flutter/foundation.dart';

class DeviceInfo {
  final bool appIsDebug;
  final String appVersion;
  final String buildNumber;
  final String buildCommit;
  final String deviceId;
  final String locale;
  final List<double> padding;
  final List<double> physicalSize;
  final double pixelRatio;
  final String platformOS;
  final String platformOSBuild;
  final String platformVersion;
  final double textScaleFactor;
  final List<double> viewInsets;

  const DeviceInfo({
    this.appIsDebug,
    this.appVersion,
    this.buildNumber,
    this.buildCommit,
    this.deviceId,
    this.locale,
    this.padding,
    this.physicalSize,
    this.pixelRatio,
    this.platformOS,
    this.platformOSBuild,
    this.platformVersion,
    this.textScaleFactor,
    this.viewInsets,
  });

  factory DeviceInfo.fromJson(Map<String, dynamic> json) {
    return DeviceInfo(
      appIsDebug: json['appIsDebug'] as bool,
      appVersion: json['appVersion'] as String,
      buildNumber: json['buildNumber'] as String,
      buildCommit: json['buildCommit'] as String,
      deviceId: json['deviceId'] as String,
      locale: json['locale'] as String,
      padding: ((json['padding'] as List<dynamic>) ?? [])
          .cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      physicalSize: ((json['physicalSize'] as List<dynamic>) ?? [])
          .cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
      pixelRatio: (json['pixelRatio'] as num)?.toDouble(),
      platformOS: json['platformOS'] as String,
      platformOSBuild: json['platformOSBuild'] as String,
      platformVersion: json['platformVersion'] as String,
      textScaleFactor: (json['textScaleFactor'] as num)?.toDouble(),
      viewInsets: ((json['viewInsets'] as List<dynamic>) ?? [])
          .cast<num>()
          .map((i) => i.toDouble())
          .toList(growable: false),
    );
  }

  @override
  String toString() {
    return 'DeviceInfo{appIsDebug: $appIsDebug, buildVersion: $appVersion, buildNumber: $buildNumber, buildCommit: $buildCommit, deviceId: $deviceId, locale: $locale, padding: $padding, physicalSize: $physicalSize, pixelRatio: $pixelRatio, platformOS: $platformOS, platformOSBuild: $platformOSBuild, platformVersion: $platformVersion, textScaleFactor: $textScaleFactor, viewInsets: $viewInsets}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceInfo &&
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
          listEquals(viewInsets, other.viewInsets);

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
      viewInsets.hashCode;

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> uiValues = {};

    uiValues['appIsDebug'] = appIsDebug;

    if (appVersion != null) {
      uiValues['appVersion'] = appVersion;
    }
    if (buildNumber != null) {
      uiValues['buildNumber'] = buildNumber;
    }
    if (buildCommit != null) {
      uiValues['buildCommit'] = buildCommit;
    }
    if (deviceId != null) {
      uiValues['deviceId'] = deviceId;
    }

    if (locale != null) {
      uiValues['locale'] = locale.toString();
    }

    if (padding != null) {
      uiValues['padding'] = padding;
    }

    if (physicalSize != null) {
      uiValues['physicalSize'] = physicalSize;
    }

    if (pixelRatio != null) {
      uiValues['pixelRatio'] = pixelRatio;
    }

    if (platformOS != null) {
      uiValues['platformOS'] = platformOS;
    }

    if (platformOSBuild != null) {
      uiValues['platformOSBuild'] = platformOSBuild;
    }

    if (platformVersion != null) {
      uiValues['platformVersion'] = platformVersion;
    }

    if (textScaleFactor != null) {
      uiValues['textScaleFactor'] = textScaleFactor;
    }

    if (viewInsets != null) {
      uiValues['viewInsets'] = viewInsets;
    }

    return uiValues;
  }
}
