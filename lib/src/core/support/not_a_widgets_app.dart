// ignore_for_file: join_return_with_assignment

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

    // Allow inspection of widgets, use to debug layout issues
    // Not part of the codebase since https://github.com/flutter/flutter/pull/158219 introduced a breaking API change.
    // Re-enable when we drop support for Flutter v3.27.0
    // if (kDebugMode && WidgetsApp.debugShowWidgetInspectorOverride) {
    //   child = WidgetInspector(
    //     exitWidgetSelectionButtonBuilder: (
    //       BuildContext context, {
    //       required VoidCallback onPressed,
    //       required GlobalKey key,
    //     }) {
    //       final ThemeData theme = Theme.of(context);
    //       return FloatingActionButton(
    //         key: key,
    //         onPressed: onPressed,
    //         mini: true,
    //         backgroundColor: theme.colorScheme.onPrimaryContainer,
    //         foregroundColor: theme.colorScheme.primaryContainer,
    //         child: const Icon(
    //           Icons.close,
    //           semanticLabel: 'Exit Select Widget mode.',
    //         ),
    //       );
    //     },
    //     moveExitWidgetSelectionButtonBuilder: (
    //       BuildContext context, {
    //       required VoidCallback onPressed,
    //       bool isLeftAligned = true,
    //     }) {
    //       final ThemeData theme = Theme.of(context);
    //       return IconButton(
    //         color: theme.colorScheme.onPrimaryContainer,
    //         padding: EdgeInsets.zero,
    //         iconSize: 32,
    //         onPressed: onPressed,
    //         constraints: const BoxConstraints(
    //           minWidth: 40,
    //           minHeight: 40,
    //         ),
    //         icon: Icon(
    //           isLeftAligned ? Icons.arrow_right : Icons.arrow_left,
    //           semanticLabel:
    //               'Move "Exit Select Widget mode" button to the ${isLeftAligned ? 'right' : 'left'}.',
    //         ),
    //       );
    //     },
    //     child: child,
    //   );
    // }

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
