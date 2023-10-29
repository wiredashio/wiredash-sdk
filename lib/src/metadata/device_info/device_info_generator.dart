// Replace with FlutterView  when we drop support for Flutter v3.7.0-32.0.pre.
// ignore: deprecated_member_use
import 'dart:ui' show Locale, SingletonFlutterWindow;

import 'package:wiredash/src/feedback/data/pending_feedback_item.dart';
import 'package:wiredash/src/metadata/device_info/device_info.dart';
// import a dart:html or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'package:wiredash/src/metadata/device_info/device_info_generator_stub.dart'
    if (dart.library.html) 'package:wiredash/src/metadata/device_info/device_info_generator_html.dart'
    if (dart.library.io) 'package:wiredash/src/metadata/device_info/device_info_generator_io.dart';

abstract class FlutterInfoCollector {
  /// Loads a [FlutterInfoCollector] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function
  // Replace with FlutterView  when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
  factory FlutterInfoCollector(SingletonFlutterWindow window) {
    return createDeviceInfoGenerator(window);
  }

  /// Collection of all [FlutterInfo] shared between all platforms
  // Replace with FlutterView when we drop support for Flutter v3.7.0-32.0.pre.
  // ignore: deprecated_member_use
  static FlutterInfo flutterInfo(SingletonFlutterWindow window) {
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

    return FlutterInfo(
      platformLocale: windowLocale().toLanguageTag(),
      platformSupportedLocales:
          windowLocales().map((it) => it.toLanguageTag()).toList(),
      padding: WiredashWindowPadding.fromWindowPadding(window.padding),
      physicalSize: window.physicalSize,
      physicalGeometry: window.physicalGeometry,
      pixelRatio: window.devicePixelRatio,
      textScaleFactor: window.textScaleFactor,
      viewInsets: WiredashWindowPadding.fromWindowPadding(window.viewInsets),
      platformBrightness: window.platformBrightness,
      gestureInsets:
          WiredashWindowPadding.fromWindowPadding(window.systemGestureInsets),
    );
  }

  /// Collects information from Flutter
  Future<FlutterInfo> generate();
}
