// import a web (dart:js_interop) or dart:io version of `getRenderer`
// if non are available the stub is used
import 'package:wiredash/src/metadata/renderer/renderer_stub.dart'
    if (dart.library.js_interop) 'package:wiredash/src/metadata/renderer/dart_html_renderer.dart'
    if (dart.library.io) 'package:wiredash/src/metadata/renderer/dart_io_renderer.dart'
    as impl;

/// Returns the renderer used by Flutter
Renderer getRenderer() {
  return impl.getRenderer();
}

/// Flutter renderer
enum Renderer {
  skia,
  canvasKit,
  html,
}
