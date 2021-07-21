import 'dart:ui' show Locale, SingletonFlutterWindow;

import 'package:wiredash/src/common/device_info/device_info.dart';

// import a dart:html or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'device_info_generator_stub.dart'
    if (dart.library.html) 'dart_html_device_info_generator.dart'
    if (dart.library.io) 'dart_io_device_info_generator.dart';

abstract class DeviceInfoGenerator {
  /// Loads a [DeviceInfoGenerator] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function
  factory DeviceInfoGenerator(SingletonFlutterWindow window) {
    return createDeviceInfoGenerator(window);
  }

  /// Collection of all [DeviceInfo] shared between all platforms
  static DeviceInfo baseDeviceInfo(SingletonFlutterWindow window) {
    Locale windowLocale() {
      // Flutter 1.26 (2.0.1) returns `Locale?`, 1.27 `Locale`
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final Locale? locale = window.locale;
      return locale ?? const Locale('en', 'US');
    }

    List<Locale> windowLocales() {
      // Flutter 1.26 (2.0.1) returns `List<Locale>?`, 1.27 `List<Locale>`
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final List<Locale>? locales = window.locales;
      return locales ?? [];
    }

    return DeviceInfo(
      platformLocale: windowLocale().toLanguageTag(),
      platformSupportedLocales:
          windowLocales().map((it) => it.toLanguageTag()).toList(),
      padding: window.padding,
      physicalSize: window.physicalSize,
      physicalGeometry: window.physicalGeometry,
      pixelRatio: window.devicePixelRatio,
      textScaleFactor: window.textScaleFactor,
      viewInsets: window.viewInsets,
      platformBrightness: window.platformBrightness,
      gestureInsets: window.systemGestureInsets,
    );
  }

  DeviceInfo generate();
}
