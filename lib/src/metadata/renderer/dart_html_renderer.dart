import 'dart:js_interop';

import 'package:wiredash/src/metadata/renderer/renderer.dart';

@JS('flutterCanvasKit')
external JSAny? get _flutterCanvasKit;

/// Whether this build was compiled to WebAssembly. `kIsWasm` only exists since
/// Flutter 3.22.
const bool _isWasm = bool.fromEnvironment('dart.tool.dart2wasm');

Renderer getRenderer() {
  if (isCanvasKitRenderer) {
    return Renderer.canvasKit;
  }
  if (_isWasm) {
    // skwasm doesn't set `window.flutterCanvasKit`, but renders to a canvas
    // just like CanvasKit does
    return Renderer.skwasm;
  }
  return Renderer.html;
}

bool get isCanvasKitRenderer {
  return _flutterCanvasKit != null;
}
