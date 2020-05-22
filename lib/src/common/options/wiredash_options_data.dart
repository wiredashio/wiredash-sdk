import 'package:flutter/foundation.dart';

class WiredashOptionsData {
  WiredashOptionsData({
    bool showDebugFloatingEntryPoint,
  }) : showDebugFloatingEntryPoint = showDebugFloatingEntryPoint ?? kDebugMode;

  /// Show a floating button with the Wiredash logo to easily report issues
  /// while debugging the app
  final bool showDebugFloatingEntryPoint;
}
