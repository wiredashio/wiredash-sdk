import 'dart:ui' show FlutterView, Locale, PlatformDispatcher;

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

  /// Collection of all [FlutterInfo] shared between all platforms.
  ///
  /// View-specific fields are `null` when [view] is `null`.
  static FlutterInfo flutterInfo(FlutterView? view) {
    final dispatcher = view?.platformDispatcher ?? PlatformDispatcher.instance;
    Locale windowLocale() => dispatcher.locale;
    List<Locale> windowLocales() => dispatcher.locales;

    return FlutterInfo(
      platformLocale: windowLocale().toLanguageTag(),
      platformSupportedLocales:
          windowLocales().map((it) => it.toLanguageTag()).toList(),
      viewPadding: view != null
          ? WiredashWindowPadding.fromViewPadding(view.padding)
          : null,
      physicalSize: view?.physicalSize,
      pixelRatio: view?.devicePixelRatio,
      textScaleFactor: dispatcher.textScaleFactor,
      viewInsets: view != null
          ? WiredashWindowPadding.fromViewPadding(view.viewInsets)
          : null,
      platformBrightness: dispatcher.platformBrightness,
      gestureInsets: view != null
          ? WiredashWindowPadding.fromViewPadding(view.systemGestureInsets)
          : null,
    );
  }

  /// Collects information from Flutter
  FlutterInfo capture();
}
