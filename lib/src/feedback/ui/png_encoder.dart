import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:wiredash/src/feedback/ui/png_encoder_io.dart'
    if (dart.library.js_interop) 'package:wiredash/src/feedback/ui/png_encoder_web.dart'
    as impl;

/// Encodes [image] as PNG.
///
/// Use this instead of `image.toByteData(format: ImageByteFormat.png)`, which
/// returns a wrongly sized PNG in WebAssembly builds on older Flutter versions.
Future<Uint8List?> encodePng(ui.Image image) {
  return impl.encodePng(image);
}
