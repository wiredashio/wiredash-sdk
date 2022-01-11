// ignore_for_file: join_return_with_assignment

import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';

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
    // Rebuild wrapped widget tree when something changes
    // This fixes Hot-Reload
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

    final wiredashTheme = context.theme;
    final materialTheme = wiredashTheme.brightness == Brightness.dark
        ? ThemeData.dark()
        : ThemeData.light();
    child = Theme(
      data: materialTheme,
      child: child,
    );

    // Make Wiredash a Material widget to support TextFields, etc.
    child = Material(
      color: Colors.transparent,
      child: child,
    );

    // allow text editing (i.e. delete on macos)
    child = DefaultTextEditingShortcuts(
      child: child,
    );
    // allow deletion of text on macos
    child = DefaultTextEditingActions(
      child: child,
    );

    return child;
  }
}
