// ignore_for_file: join_return_with_assignment

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

/// Wrapper with default that most widgets required that are now wrapped by a
/// [WidgetsApp]
class NotAWidgetsApp extends StatefulWidget {
  const NotAWidgetsApp({
    required this.child,
    this.textDirection,
    Key? key,
  }) : super(key: key);

  final Widget child;

  final TextDirection? textDirection;

  @override
  State<NotAWidgetsApp> createState() => _NotAWidgetsAppState();
}

class _NotAWidgetsAppState extends State<NotAWidgetsApp> {
  @override
  Widget build(BuildContext context) {
    Widget child = widget.child;

    // Any Text requires a directionality
    child = Directionality(
      textDirection: widget.textDirection ?? TextDirection.ltr,
      child: child,
    );

    // Inject a MediaQuery with information from the app window
    child = MediaQuery.fromWindow(
      child: child,
    );

    return child;
  }
}

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
