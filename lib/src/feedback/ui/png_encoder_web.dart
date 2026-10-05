import 'dart:js_interop';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:web/web.dart' as web;
import 'package:wiredash/src/feedback/ui/png_encoder_io.dart' as io;

/// Whether this build was compiled to WebAssembly. `kIsWasm` only exists since
/// Flutter 3.22.
const bool _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

Future<Uint8List?> encodePng(ui.Image image) async {
  if (!_isWasm) {
    return io.encodePng(image);
  }

  // With skwasm, Flutter 3.44 encodes a PNG that has the size of the browser
  // window instead of the size of the image, with the image drawn unscaled
  // into its top left corner. The screenshot then shows up cropped or with an
  // empty margin, depending on the device pixel ratio. Flutter 3.47 encodes it
  // correctly.
  //
  // The raw pixels are correct in every version, so let the browser encode
  // them. Remove this once the minimum Flutter version has the fix.
  final pixels = await image.toByteData(
    format: ui.ImageByteFormat.rawStraightRgba,
  );
  if (pixels == null) {
    return null;
  }
  final canvas = web.OffscreenCanvas(image.width, image.height);
  final context =
      canvas.getContext('2d')! as web.OffscreenCanvasRenderingContext2D;
  final clamped = pixels.buffer.asUint8ClampedList(
    pixels.offsetInBytes,
    pixels.lengthInBytes,
  );
  context.putImageData(
    web.ImageData(clamped.toJS, image.width, image.height.toJS),
    0,
    0,
  );
  final blob = await canvas.convertToBlob().toDart;
  final buffer = await blob.arrayBuffer().toDart;
  return buffer.toDart.asUint8List();
}
