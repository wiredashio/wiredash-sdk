import 'package:wiredash/src/metadata/renderer/renderer.dart';

Renderer getRenderer() {
  throw UnsupportedError('Cannot read renderer without dart:html or dart:io');
}
