export 'dart_ui_fake.dart'
    if (dart.library.ui_web) 'dart:ui_web'
    if (dart.library.html) 'dart_ui_real.dart';
