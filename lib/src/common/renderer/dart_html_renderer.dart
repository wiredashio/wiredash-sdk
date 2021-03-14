import 'dart:js' as js;

import 'package:wiredash/src/common/renderer/renderer.dart';

Renderer getRenderer() {
  return isCanvasKitRenderer ? Renderer.canvasKit : Renderer.html;
}

bool get isCanvasKitRenderer {
  var r = js.context['flutterCanvasKit'];
  return r != null;
}
