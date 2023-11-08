import 'package:flutter/material.dart';
import 'package:wiredash_gallery/src/detail.dart';
import 'package:wiredash_gallery/src/home.dart';

void main() {
  runApp(const WidgetGalleryApp());
}

class WidgetGalleryApp extends StatelessWidget {
  const WidgetGalleryApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      color: const Color(0xFF123456),
      initialRoute: '/',
      routes: {
        '/': (context) => const WidgetGalleryHome(),
        '/detail': (context) => const WidgetDetailPage(),
      },
    );
  }
}
