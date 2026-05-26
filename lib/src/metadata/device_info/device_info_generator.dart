import 'dart:ui' show FlutterView, Locale;

import 'package:wiredash/src/metadata/all_meta_data.dart';
// import a web (dart:js_interop) or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'package:wiredash/src/metadata/device_info/device_info_generator_stub.dart'
    if (dart.library.js_interop) 'package:wiredash/src/metadata/device_info/device_info_generator_html.dart'
    if (dart.library.io) 'package:wiredash/src/metadata/device_info/device_info_generator_io.dart';

abstract class FlutterInfoCollector {
  /// Loads a [FlutterInfoCollector] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function
  factory FlutterInfoCollector(FlutterView view) {
    return createDeviceInfoGenerator(view);
  }

  /// Collection of all [FlutterInfo] shared between all platforms
  static FlutterInfo flutterInfo(FlutterView view) {
    final dispatcher = view.platformDispatcher;
    Locale windowLocale() => dispatcher.locale;
    List<Locale> windowLocales() => dispatcher.locales;

    return FlutterInfo(
      platformLocale: windowLocale().toLanguageTag(),
      platformSupportedLocales:
          windowLocales().map((it) => it.toLanguageTag()).toList(),
      viewPadding: WiredashWindowPadding.fromViewPadding(view.padding),
      physicalSize: view.physicalSize,
      pixelRatio: view.devicePixelRatio,
      textScaleFactor: dispatcher.textScaleFactor,
      viewInsets: WiredashWindowPadding.fromViewPadding(view.viewInsets),
      platformBrightness: dispatcher.platformBrightness,
      gestureInsets:
          WiredashWindowPadding.fromViewPadding(view.systemGestureInsets),
    );
  }

  /// Collects information from Flutter
  FlutterInfo capture();
}
