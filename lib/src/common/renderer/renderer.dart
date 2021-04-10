// import a dart:html or dart:io version of `createDeviceInfoGenerator`
// if non are available the stub is used
import 'renderer_stub.dart'
    if (dart.library.html) 'dart_html_renderer.dart'
    if (dart.library.io) 'dart_io_renderer.dart' as impl;

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
