import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/src/media_query_from_window.dart';

/// Wrapper for widgets like [TextField] that expect,
/// but don't have a [WidgetsApp] as parent.
class NotAWidgetsApp extends StatefulWidget {
  const NotAWidgetsApp({
    required this.child,
    this.textDirection,
    this.locale,
    Key? key,
  }) : super(key: key);

  final Widget child;

  final TextDirection? textDirection;
  final Locale? locale;

  @override
  State<NotAWidgetsApp> createState() => _NotAWidgetsAppState();
}

class _NotAWidgetsAppState extends State<NotAWidgetsApp> {
  OverlayEntry? entry;

  @override
  void didUpdateWidget(covariant NotAWidgetsApp oldWidget) {
    super.didUpdateWidget(oldWidget);
    entry?.markNeedsBuild();
  }

  @override
  Widget build(BuildContext context) {
    // Overlay is required for text edit functions such as copy/paste on mobile
    entry = OverlayEntry(
      builder: (context) {
        // use a stateful widget as direct child or hot reload will not
        // work for that widget
        return widget.child;
      },
    );

    Widget child = Overlay(initialEntries: [entry!]);

    // Any Text requires a directionality
    child = Directionality(
      textDirection: widget.textDirection ?? TextDirection.ltr,
      // Localizations required for Flutter UI widgets.
      // I.e. copy/paste dialogs for TextFields
      child: Localizations(
        locale: widget.locale ?? window.locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
          DefaultCupertinoLocalizations.delegate,
        ],
        child: child,
      ),
    );

    // Both DefaultTextEditingShortcuts and DefaultTextEditingActions are
    // required to make text edits like deletion of characters possible on macOS
    child = DefaultTextEditingShortcuts(
      child: child,
    );

    // Inject a MediaQuery with information from the app window
    child = MediaQueryFromWindow(
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
