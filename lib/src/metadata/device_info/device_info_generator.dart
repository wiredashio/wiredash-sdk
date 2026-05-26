import 'dart:ui' show FlutterView, Locale, PlatformDispatcher, Size;

import 'package:wiredash/src/metadata/all_meta_data.dart';
// import a web (dart:js_interop) or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'package:wiredash/src/metadata/device_info/device_info_generator_stub.dart'
    if (dart.library.js_interop) 'package:wiredash/src/metadata/device_info/device_info_generator_html.dart'
    if (dart.library.io) 'package:wiredash/src/metadata/device_info/device_info_generator_io.dart';

abstract class FlutterInfoCollector {
  /// Loads a [FlutterInfoCollector] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function.
  ///
  /// [view] may be null when there is no implicit [FlutterView] available
  /// (e.g. on background isolates); the collector then falls back to
  /// [PlatformDispatcher] defaults.
  factory FlutterInfoCollector(FlutterView? view) {
    return createDeviceInfoGenerator(view);
  }

  /// Collection of all [FlutterInfo] shared between all platforms
  static FlutterInfo flutterInfo(FlutterView? view) {
    final dispatcher = view?.platformDispatcher ?? PlatformDispatcher.instance;
    Locale windowLocale() => dispatcher.locale;
    List<Locale> windowLocales() => dispatcher.locales;

    const WiredashWindowPadding zeroPadding = WiredashWindowPadding(
      left: 0,
      top: 0,
      right: 0,
      bottom: 0,
    );

    return FlutterInfo(
      platformLocale: windowLocale().toLanguageTag(),
      platformSupportedLocales:
          windowLocales().map((it) => it.toLanguageTag()).toList(),
      viewPadding: view != null
          ? WiredashWindowPadding.fromViewPadding(view.padding)
          : zeroPadding,
      physicalSize: view?.physicalSize ?? Size.zero,
      pixelRatio: view?.devicePixelRatio ?? 1.0,
      textScaleFactor: dispatcher.textScaleFactor,
      viewInsets: view != null
          ? WiredashWindowPadding.fromViewPadding(view.viewInsets)
          : zeroPadding,
      platformBrightness: dispatcher.platformBrightness,
      gestureInsets: view != null
          ? WiredashWindowPadding.fromViewPadding(view.systemGestureInsets)
          : zeroPadding,
    );
  }

  /// Collects information from Flutter
  FlutterInfo capture();
}
