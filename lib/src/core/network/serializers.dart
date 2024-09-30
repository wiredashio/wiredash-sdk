import 'dart:ui';

import 'package:wiredash/src/metadata/build_info/build_info.dart';

// Remove when we drop support for Flutter v3.8.0-14.0.pre.
// ignore: deprecated_member_use
extension SerizalizeWindowPadding on WindowPadding {
  List<double> toRequestJsonArray() {
    return [left, top, right, bottom];
  }
}

extension SerializeSize on Size {
  List<double> toRequestJsonArray() {
    return [width, height];
  }
}

extension SerializeBrightness on Brightness {
  String toRequestJsonValue() {
    if (this == Brightness.dark) return 'dark';
    if (this == Brightness.light) return 'light';
    throw 'Unknown brightness value $this';
  }
}

extension SerializeCompilationMode on CompilationMode {
  String toRequestJsonValue() {
    switch (this) {
      case CompilationMode.release:
        return 'release';
      case CompilationMode.profile:
        return 'profile';
      case CompilationMode.debug:
        return 'debug';
    }
  }
}
