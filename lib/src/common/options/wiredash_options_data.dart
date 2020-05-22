import 'package:flutter/foundation.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    bool showDebugFloatingEntryPoint,
  }) : showDebugFloatingEntryPoint =
            kDebugMode && (showDebugFloatingEntryPoint ?? true);

  final bool showDebugFloatingEntryPoint;
}
