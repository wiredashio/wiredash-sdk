import 'dart:ui' show Brightness;
import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

export 'dart:ui' show Brightness;

class DeviceInfo {
  final String platformLocale;
  final List<String> platformSupportedLocales;
  final List<double>? padding;
  final List<double> physicalSize;
  final double pixelRatio;
  final Brightness platformBrightness;

  /// A string representing the operating system or platform.
  ///
  /// Platform.operatingSystem
  final String? platformOS;

  /// A string representing the version of the operating system or platform.
  ///
  /// Platform.operatingSystemVersion
  final String? platformOSVersion;

  /// The version of the current Dart runtime.
  ///
  /// Platform.version
  final String? platformVersion;

  final double textScaleFactor;
  final List<double>? viewInsets;

  final List<double>? gestureInsets;

  /// When in web, the full user agent String of the browser
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
  final String? userAgent;

  const DeviceInfo({
    required this.platformLocale,
    required this.platformSupportedLocales,
    this.padding,
    required this.physicalSize,
    required this.pixelRatio,
    this.platformOS,
    this.platformOSVersion,
    this.platformVersion,
    required this.textScaleFactor,
    this.viewInsets,
    this.userAgent,
    required this.platformBrightness,
    this.gestureInsets,
  });

  DeviceInfo copyWith({
    String? deviceId,
    String? platformLocale,
    List<String>? platformSupportedLocales,
    List<double>? padding,
    List<double>? physicalSize,
    double? pixelRatio,
    String? platformOS,
    String? platformOSVersion,
    String? platformVersion,
    double? textScaleFactor,
    List<double>? viewInsets,
    String? userAgent,
    Brightness? platformBrightness,
    List<double>? gestureInsets,
  }) {
    return DeviceInfo(
      platformLocale: platformLocale ?? this.platformLocale,
      platformSupportedLocales:
          platformSupportedLocales ?? this.platformSupportedLocales,
      padding: padding ?? this.padding,
      physicalSize: physicalSize ?? this.physicalSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      platformOS: platformOS ?? this.platformOS,
      platformOSVersion: platformOSVersion ?? this.platformOSVersion,
      platformVersion: platformVersion ?? this.platformVersion,
      textScaleFactor: textScaleFactor ?? this.textScaleFactor,
      viewInsets: viewInsets ?? this.viewInsets,
      userAgent: userAgent ?? this.userAgent,
      platformBrightness: platformBrightness ?? this.platformBrightness,
      gestureInsets: gestureInsets ?? this.gestureInsets,
    );
  }

  @override
  String toString() {
    return 'DeviceInfo{'
        'platformLocale: $platformLocale, '
        'platformSupportedLocales: $platformSupportedLocales, '
        'padding: $padding, '
        'physicalSize: $physicalSize, '
        'pixelRatio: $pixelRatio, '
        'platformOS: $platformOS, '
        'platformOSBuild: $platformOSVersion, '
        'platformVersion: $platformVersion, '
        'textScaleFactor: $textScaleFactor, '
        'viewInsets: $viewInsets, '
        'userAgent: $userAgent, '
        'platformBrightness: $platformBrightness, '
        'gestureInsets: $gestureInsets, '
        '}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DeviceInfo &&
          runtimeType == other.runtimeType &&
          platformLocale == other.platformLocale &&
          listEquals(
              platformSupportedLocales, other.platformSupportedLocales) &&
          listEquals(padding, other.padding) &&
          listEquals(physicalSize, other.physicalSize) &&
          pixelRatio == other.pixelRatio &&
          platformOS == other.platformOS &&
          platformOSVersion == other.platformOSVersion &&
          platformVersion == other.platformVersion &&
          textScaleFactor == other.textScaleFactor &&
          listEquals(viewInsets, other.viewInsets) &&
          userAgent == other.userAgent &&
          platformBrightness == other.platformBrightness &&
          listEquals(gestureInsets, other.gestureInsets));

  @override
  int get hashCode =>
      platformLocale.hashCode ^
      hashList(platformSupportedLocales) ^
      hashList(padding) ^
      hashList(physicalSize) ^
      pixelRatio.hashCode ^
      platformOS.hashCode ^
      platformOSVersion.hashCode ^
      platformVersion.hashCode ^
      textScaleFactor.hashCode ^
      hashList(viewInsets) ^
      userAgent.hashCode ^
      platformBrightness.hashCode ^
      hashList(gestureInsets);
}
