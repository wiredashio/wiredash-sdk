import 'dart:ui' show Brightness, WindowPadding;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

export 'dart:ui' show Brightness;

class DeviceInfo {
  /// The primary locale enabled on the device
  ///
  /// https://api.flutter.dev/flutter/dart-ui/SingletonFlutterWindow/locale.html
  final String platformLocale;

  /// Locales the user enabled on their device
  ///
  /// https://api.flutter.dev/flutter/dart-ui/SingletonFlutterWindow/locales.html
  final List<String> platformSupportedLocales;

  /// Area not covered with system UI
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/padding.html
  final WindowPadding padding;

  /// The dimensions of the rectangle into which the scene rendered in this view will be drawn on the screen, in physical pixels.
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/physicalSize.html
  final Size physicalSize;

  /// The dimensions and location of the rectangle into which the scene rendered in this view will be drawn on the screen, in physical pixels.
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/physicalGeometry.html
  final Rect physicalGeometry;

  /// The number of device pixels for each logical pixel for the screen this view is displayed on.
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/devicePixelRatio.html
  final double pixelRatio;

  /// Is the system dark or light themed?
  ///
  /// https://api.flutter.dev/flutter/dart-ui/SingletonFlutterWindow/platformBrightness.html
  final Brightness platformBrightness;

  /// A string representing the operating system or platform.
  ///
  /// https://api.flutter.dev/flutter/package-platform_platform/LocalPlatform/operatingSystem.html
  final String? platformOS;

  /// A string representing the version of the operating system or platform.
  ///
  /// https://api.flutter.dev/flutter/package-platform_platform/LocalPlatform/operatingSystemVersion.html
  final String? platformOSVersion;

  /// The version of the current Dart runtime.
  ///
  /// https://api.flutter.dev/flutter/package-platform_platform/LocalPlatform/version.html
  final String? platformVersion;

  /// Text scale factor, default 1.0
  ///
  /// https://api.flutter.dev/flutter/dart-ui/SingletonFlutterWindow/textScaleFactor.html
  final double textScaleFactor;

  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/viewInsets.html
  final WindowPadding viewInsets;

  /// Area where Android does not intercept i.e. for the back button gesture (swipe from the side of the screen)
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/systemGestureInsets.html
  final WindowPadding gestureInsets;

  /// When in web, the full user agent String of the browser
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
  final String? userAgent;

  const DeviceInfo({
    required this.platformLocale,
    required this.platformSupportedLocales,
    required this.padding,
    required this.physicalSize,
    required this.physicalGeometry,
    required this.pixelRatio,
    this.platformOS,
    this.platformOSVersion,
    this.platformVersion,
    required this.textScaleFactor,
    required this.viewInsets,
    this.userAgent,
    required this.platformBrightness,
    required this.gestureInsets,
  });

  DeviceInfo copyWith({
    String? deviceId,
    String? platformLocale,
    List<String>? platformSupportedLocales,
    WindowPadding? padding,
    Size? physicalSize,
    Rect? physicalGeometry,
    double? pixelRatio,
    String? platformOS,
    String? platformOSVersion,
    String? platformVersion,
    double? textScaleFactor,
    WindowPadding? viewInsets,
    String? userAgent,
    Brightness? platformBrightness,
    WindowPadding? gestureInsets,
  }) {
    return DeviceInfo(
      platformLocale: platformLocale ?? this.platformLocale,
      platformSupportedLocales:
          platformSupportedLocales ?? this.platformSupportedLocales,
      padding: padding ?? this.padding,
      physicalSize: physicalSize ?? this.physicalSize,
      physicalGeometry: physicalGeometry ?? this.physicalGeometry,
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
        'physicalGeometry: $physicalGeometry, '
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
          padding == other.padding &&
          physicalSize == other.physicalSize &&
          physicalGeometry == other.physicalGeometry &&
          pixelRatio == other.pixelRatio &&
          platformOS == other.platformOS &&
          platformOSVersion == other.platformOSVersion &&
          platformVersion == other.platformVersion &&
          textScaleFactor == other.textScaleFactor &&
          viewInsets == other.viewInsets &&
          userAgent == other.userAgent &&
          platformBrightness == other.platformBrightness &&
          gestureInsets == other.gestureInsets);

  @override
  int get hashCode =>
      platformLocale.hashCode ^
      hashList(platformSupportedLocales) ^
      padding.hashCode ^
      physicalSize.hashCode ^
      physicalGeometry.hashCode ^
      pixelRatio.hashCode ^
      platformOS.hashCode ^
      platformOSVersion.hashCode ^
      platformVersion.hashCode ^
      textScaleFactor.hashCode ^
      viewInsets.hashCode ^
      userAgent.hashCode ^
      platformBrightness.hashCode ^
      gestureInsets.hashCode;
}
