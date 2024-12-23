// ignore: unnecessary_import
import 'dart:ui' show Brightness;

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/_wiredash_internal.dart';

/// All information we can gather from the Flutter Framework about the
/// device/window/canvas
///
/// Created by following implementations
/// - [_DartHtmlDeviceInfoGenerator]
/// - [_DartIoDeviceInfoGenerator]
class FlutterInfo {
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
  final WiredashWindowPadding viewPadding;

  /// The dimensions of the rectangle into which the scene rendered in this
  /// view will be drawn on the screen, in physical pixels.
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/physicalSize.html
  final Size physicalSize;

  /// The number of device pixels for each logical pixel for the screen this
  /// view is displayed on.
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

  /// The version of the current Dart runtime.
  ///
  /// https://api.flutter.dev/flutter/package-platform_platform/LocalPlatform/version.html
  final String? platformDartVersion;

  /// Text scale factor, default 1.0
  ///
  /// https://api.flutter.dev/flutter/dart-ui/SingletonFlutterWindow/textScaleFactor.html
  final double textScaleFactor;

  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/viewInsets.html
  final WiredashWindowPadding viewInsets;

  /// Area where Android does not intercept i.e. for the back button gesture
  /// (swipe from the side of the screen)
  ///
  /// https://api.flutter.dev/flutter/dart-ui/FlutterView/systemGestureInsets.html
  final WiredashWindowPadding gestureInsets;

  /// When in web, the full user agent String of the browser
  ///
  /// https://developer.mozilla.org/en-US/docs/Web/HTTP/Headers/User-Agent
  final String? userAgent;

  const FlutterInfo({
    required this.platformLocale,
    required this.platformSupportedLocales,
    required this.viewPadding,
    required this.physicalSize,
    required this.pixelRatio,
    this.platformOS,
    this.platformDartVersion,
    required this.textScaleFactor,
    required this.viewInsets,
    this.userAgent,
    required this.platformBrightness,
    required this.gestureInsets,
  });

  FlutterInfo copyWith({
    String? deviceModel,
    String? deviceId,
    String? platformLocale,
    List<String>? platformSupportedLocales,
    WiredashWindowPadding? padding,
    Size? physicalSize,
    double? pixelRatio,
    String? platformOS,
    String? platformVersion,
    double? textScaleFactor,
    WiredashWindowPadding? viewInsets,
    String? userAgent,
    Brightness? platformBrightness,
    WiredashWindowPadding? gestureInsets,
  }) {
    return FlutterInfo(
      platformLocale: platformLocale ?? this.platformLocale,
      platformSupportedLocales:
          platformSupportedLocales ?? this.platformSupportedLocales,
      viewPadding: padding ?? viewPadding,
      physicalSize: physicalSize ?? this.physicalSize,
      pixelRatio: pixelRatio ?? this.pixelRatio,
      platformOS: platformOS ?? this.platformOS,
      platformDartVersion: platformVersion ?? platformDartVersion,
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
        'padding: $viewPadding, '
        'physicalSize: $physicalSize, '
        'pixelRatio: $pixelRatio, '
        'platformOS: $platformOS, '
        'platformVersion: $platformDartVersion, '
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
      (other is FlutterInfo &&
          runtimeType == other.runtimeType &&
          platformLocale == other.platformLocale &&
          listEquals(
            platformSupportedLocales,
            other.platformSupportedLocales,
          ) &&
          viewPadding == other.viewPadding &&
          physicalSize == other.physicalSize &&
          pixelRatio == other.pixelRatio &&
          platformOS == other.platformOS &&
          platformDartVersion == other.platformDartVersion &&
          textScaleFactor == other.textScaleFactor &&
          viewInsets == other.viewInsets &&
          userAgent == other.userAgent &&
          platformBrightness == other.platformBrightness &&
          gestureInsets == other.gestureInsets);

  @override
  int get hashCode =>
      platformLocale.hashCode ^
      Object.hashAll(platformSupportedLocales) ^
      viewPadding.hashCode ^
      physicalSize.hashCode ^
      pixelRatio.hashCode ^
      platformOS.hashCode ^
      platformDartVersion.hashCode ^
      textScaleFactor.hashCode ^
      viewInsets.hashCode ^
      userAgent.hashCode ^
      platformBrightness.hashCode ^
      gestureInsets.hashCode;
}
