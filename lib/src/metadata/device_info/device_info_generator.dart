import 'dart:ui' show FlutterView, PlatformDispatcher, ViewPadding;

import 'package:wiredash/src/metadata/all_meta_data.dart';
// import a web (dart:js_interop) or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'package:wiredash/src/metadata/device_info/device_info_generator_stub.dart'
    if (dart.library.js_interop) 'package:wiredash/src/metadata/device_info/device_info_generator_html.dart'
    if (dart.library.io) 'package:wiredash/src/metadata/device_info/device_info_generator_io.dart';

abstract class FlutterInfoCollector {
  /// Loads a [FlutterInfoCollector] based on the environment by calling the
  /// optional imported createDeviceInfoGenerator function.
  factory FlutterInfoCollector() {
    return createDeviceInfoGenerator();
  }

  /// Collects information from Flutter
  FlutterInfo capture();
}

/// Collection of all [FlutterInfo] shared between all platforms.
///
/// Looks up the current [FlutterView] from [PlatformDispatcher] — when no
/// view exists (e.g. background isolates), view-specific fields are `null`.
FlutterInfo captureBaseFlutterInfo() {
  final dispatcher = PlatformDispatcher.instance;
  final view = dispatcher.views.firstOrNull;

  return FlutterInfo(
    // dispatcher — always available
    platformLocale: dispatcher.locale.toLanguageTag(),
    platformSupportedLocales:
        dispatcher.locales.map((it) => it.toLanguageTag()).toList(),
    platformBrightness: dispatcher.platformBrightness,
    textScaleFactor: dispatcher.textScaleFactor,
    // view — null on background isolates
    physicalSize: view?.physicalSize,
    pixelRatio: view?.devicePixelRatio,
    viewPadding: view?.padding.toWiredashPadding(),
    viewInsets: view?.viewInsets.toWiredashPadding(),
    gestureInsets: view?.systemGestureInsets.toWiredashPadding(),
  );
}

extension on ViewPadding {
  WiredashWindowPadding toWiredashPadding() =>
      WiredashWindowPadding.fromViewPadding(this);
}
