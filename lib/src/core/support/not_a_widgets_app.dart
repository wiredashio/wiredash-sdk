// ignore_for_file: join_return_with_assignment

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Wrapper with default that most widgets required that are now wrapped by a
/// [WidgetsApp]
class NotAWidgetsApp extends StatefulWidget {
  const NotAWidgetsApp({
    required this.child,
    this.textDirection,
    super.key,
  });

  final Widget child;

  final TextDirection? textDirection;

  @override
  State<NotAWidgetsApp> createState() => _NotAWidgetsAppState();
}

class _NotAWidgetsAppState extends State<NotAWidgetsApp> {
  final GlobalKey _childKey = GlobalKey(debugLabel: 'WidgetsApp child');

  @override
  Widget build(BuildContext context) {
    Widget child = KeyedSubtree(
      key: _childKey,
      child: widget.child,
    );

    // Allow inspection of widgets
    if (kDebugMode && WidgetsApp.debugShowWidgetInspectorOverride) {
      child = WidgetInspector(
        selectButtonBuilder: (BuildContext context, void Function() onPressed) {
          return FloatingActionButton(
            onPressed: onPressed,
            mini: true,
            child: const Icon(Icons.search),
          );
        },
        child: child,
      );
    }

    // Any Text requires a directionality
    child = Directionality(
      textDirection: widget.textDirection ?? TextDirection.ltr,
      child: child,
    );

    final parentMq = MediaQuery.maybeOf(context);
    if (parentMq == null) {
      // Inject a MediaQuery with information from the app window

      // Replace with MediaQuery.fromView when we drop support for Flutter v3.7.0-32.0.pre.
      // ignore: deprecated_member_use
      child = MediaQuery.fromWindow(
        child: child,
      );
    }

    return child;
  }
}
