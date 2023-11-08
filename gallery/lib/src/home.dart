import 'package:flutter/material.dart';
// ignore: unnecessary_import
import 'package:flutter/widgets.dart';

class WidgetGalleryHome extends StatelessWidget {
  const WidgetGalleryHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: ElevatedButton(
          child: const Text('Go to detail'),
          onPressed: () {
            Navigator.of(context).pushNamed('/detail');
          },
        ),
      ),
    );
  }
}
