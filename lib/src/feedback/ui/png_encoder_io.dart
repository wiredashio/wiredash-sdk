import 'dart:typed_data';
import 'dart:ui' as ui;

Future<Uint8List?> encodePng(ui.Image image) async {
  final bytes = await image.toByteData(format: ui.ImageByteFormat.png);
  return bytes?.buffer.asUint8List();
}
