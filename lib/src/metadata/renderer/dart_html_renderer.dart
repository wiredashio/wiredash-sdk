import 'dart:js_interop';

import 'package:wiredash/src/metadata/renderer/renderer.dart';

@JS('flutterCanvasKit')
external JSAny? get _flutterCanvasKit;

Renderer getRenderer() {
  return isCanvasKitRenderer ? Renderer.canvasKit : Renderer.html;
}

bool get isCanvasKitRenderer {
  return _flutterCanvasKit != null;
}
