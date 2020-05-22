import 'package:flutter/foundation.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    bool showDebugFloatingEntryPoint,
  }) : showDebugFloatingEntryPoint = showDebugFloatingEntryPoint ?? kDebugMode;

  final bool showDebugFloatingEntryPoint;
}
