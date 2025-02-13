// ignore_for_file: avoid_web_libraries_in_flutter
// ignore: deprecated_member_use
import 'dart:js' as js;

import 'package:wiredash/src/metadata/renderer/renderer.dart';

Renderer getRenderer() {
  return isCanvasKitRenderer ? Renderer.canvasKit : Renderer.html;
}

bool get isCanvasKitRenderer {
  final flutterCanvasKit = js.context['flutterCanvasKit'];
  return flutterCanvasKit != null;
}
