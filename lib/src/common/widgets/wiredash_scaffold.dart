import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/options/wiredash_options.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';

class WiredashScaffold extends StatefulWidget {
  const WiredashScaffold({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  _WiredashScaffoldState createState() => _WiredashScaffoldState();
}

class _WiredashScaffoldState extends State<WiredashScaffold>
    with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MediaQuery(
      data: MediaQueryData.fromWindow(WidgetsBinding.instance!.window),
      child: Directionality(
        textDirection: WiredashOptions.of(context)!.textDirection,
        child: Container(
          color: WiredashTheme.of(context)!.backgroundColor,
          child: widget.child,
        ),
      ),
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  @override
  void didChangeMetrics() {
    setState(() {
      // Update when MediaQuery properties change
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
