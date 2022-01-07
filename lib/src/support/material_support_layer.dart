// ignore_for_file: join_return_with_assignment

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Provides parent Widgets that are required by material widgets that are
/// not wrapped into an [MaterialApp]
class MaterialSupportLayer extends StatefulWidget {
  const MaterialSupportLayer({
    Key? key,
    required this.child,
    this.locale,
  }) : super(key: key);

  final Widget child;
  final Locale? locale;

  @override
  State<MaterialSupportLayer> createState() => _MaterialSupportLayerState();
}

class _MaterialSupportLayerState extends State<MaterialSupportLayer> {
  OverlayEntry? _entry;

  @override
  void didUpdateWidget(covariant MaterialSupportLayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    _entry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    //Overlay is required for text edit functions such as copy/paste on mobile
    _entry = OverlayEntry(
      builder: (context) {
        // use a stateful widget as direct child or hot reload will not
        // work for that widget
        return widget.child;
      },
    );

    Widget child = Overlay(initialEntries: [_entry!]);

    // Localizations required for Flutter UI widgets.
    // I.e. copy/paste dialogs for TextFields
    child = Localizations(
      locale: widget.locale ?? window.locale,
      delegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      child: child,
    );

    // Make Wiredash a Material widget to support TextFields, etc.
    child = Material(
      color: Colors.transparent,
      child: child,
    );
    return child;
  }
}
