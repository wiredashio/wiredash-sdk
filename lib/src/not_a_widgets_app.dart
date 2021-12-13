import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:wiredash/src/media_query_from_window.dart';

/// Wrapper for widgets like [TextField] that expect,
/// but don't have a [WidgetsApp] as parent.
class NotAWidgetsApp extends StatelessWidget {
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
  Widget build(BuildContext context) {
    // Overlay is required for text edit functions such as copy/paste on mobile
    Widget widget = Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            // use a stateful widget as direct child or hot reload will not
            // work for that widget
            return child;
          },
        ),
      ],
    );

    // Any Text requires a directionality
    widget = Directionality(
      textDirection: textDirection ?? TextDirection.ltr,
      // Localizations required for Flutter UI widgets.
      // I.e. copy/paste dialogs for TextFields
      child: Localizations(
        locale: locale ?? window.locale,
        delegates: const [
          DefaultMaterialLocalizations.delegate,
          DefaultWidgetsLocalizations.delegate,
        ],
        child: widget,
      ),
    );

    // Both DefaultTextEditingShortcuts and DefaultTextEditingActions are
    // required to make text edits like deletion of characters possible on macOS
    widget = DefaultTextEditingShortcuts(
      child: widget,
    );

    // Inject a MediaQuery with information from the app window
    widget = MediaQueryFromWindow(
      child: widget,
    );

    // Make Wiredash a Material widget to support TextFields, etc.
    widget = Material(
      child: widget,
    );

    return widget;
  }
}
