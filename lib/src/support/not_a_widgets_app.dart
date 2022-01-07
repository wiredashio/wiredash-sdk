// ignore_for_file: join_return_with_assignment

import 'package:flutter/material.dart';

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
