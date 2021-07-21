import 'dart:ui' show SingletonFlutterWindow;

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
    return DeviceInfo(
      platformLocale: window.locale.toLanguageTag(),
      platformSupportedLocales:
          window.locales.map((it) => it.toLanguageTag()).toList(),
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
