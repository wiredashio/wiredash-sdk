import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';

/// Replica of [WidgetsApp]'s [_MediaQueryFromWindow]
class MediaQueryFromWindow extends StatefulWidget {
  const MediaQueryFromWindow({Key? key, required this.child}) : super(key: key);

  final Widget child;

  @override
  MediaQueryFromWindowsState createState() => MediaQueryFromWindowsState();
}

class MediaQueryFromWindowsState extends State<MediaQueryFromWindow> with WidgetsBindingObserver {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance!.addObserver(this);
  }

  // ACCESSIBILITY

  @override
  void didChangeAccessibilityFeatures() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  // METRICS

  @override
  void didChangeMetrics() {
    setState(() {
      // The properties of window have changed. We use them in our build
      // function, so we need setState(), but we don't cache anything locally.
    });
  }

  @override
  void didChangeTextScaleFactor() {
    setState(() {
      // The textScaleFactor property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  // RENDERING

  @override
  void didChangePlatformBrightness() {
    setState(() {
      // The platformBrightness property of window has changed. We reference
      // window in our build function, so we need to call setState(), but
      // we don't need to cache anything locally.
    });
  }

  @override
  Widget build(BuildContext context) {
    MediaQueryData data = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);
    if (!kReleaseMode) {
      data = data.copyWith(platformBrightness: debugBrightnessOverride);
    }
    return MediaQuery(
      data: data,
      child: widget.child,
    );
  }

  @override
  void dispose() {
    WidgetsBinding.instance!.removeObserver(this);
    super.dispose();
  }
}
