import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

/// Provides responsive layout information down the widget tree via
/// `WiredashResponsiveLayout.of(context)`
///
/// Inspired by https://github.com/fluttercommunity/breakpoint/ which is based
/// on material design. Wiredash does not 100% follow those values, thus the fork.
class WiredashResponsiveLayout extends StatelessWidget {
  const WiredashResponsiveLayout({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final data = _calcBreakpoints(constraints);
      return _ResponsiveLayoutInheritedWidget(data: data, child: child);
    });
  }

  /// Better use the extension `context.responsiveLayout`
  static WiredashResponsiveLayoutData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ResponsiveLayoutInheritedWidget>()!
        .data;
  }

  static WiredashResponsiveLayoutData _calcBreakpoints(
      BoxConstraints constraints) {
    final normalized = constraints.normalize();
    final width = normalized.maxWidth;
    final size = Size(normalized.maxWidth, normalized.maxHeight);
    final isLandscape = normalized.maxWidth > normalized.maxHeight;

    if (width >= 1920) {
      // MacBook Pro 16" 2019 (more space) width: 2048
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.desktop,
        window: WindowSize.xlarge,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 256,
      );
    }
    if (width >= 1600) {
      // MacBook Pro 16" 2019 (default scale) width: 1792
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.desktop,
        window: WindowSize.large,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
      );
    }
    if (width >= 1440) {
      // MacBook Pro 16" 2019 (medium scale) width: 1536
      // MacBook Pro 15" 2018 width: 1440
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.desktop,
        window: WindowSize.large,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
      );
    }
    if (width >= 1280) {
      // iPad Pro 12.9 landscape width: 1366
      // Macbook Pro 13" 2018: 1280
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.desktop,
        window: WindowSize.medium,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
      );
    }
    if (width >= 1024) {
      // iPad Pro 11 landscape with: 1194
      // iPad Pro 10.5 landscape with: 1112
      // iPad landscape with: 1024
      // iPad Pro 12" width: 1024
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.desktop,
        window: WindowSize.medium,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 64,
      );
    }
    if (width >= 960) {
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.largeTablet,
        window: WindowSize.small,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 64,
      );
    }
    if (width >= 840) {
      // Apple iPhone 12 Pro Max (2020) landscape width: 926
      // MacBook Pro 16" 2019 (default scale) split screen width: 896
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.largeTablet,
        window: WindowSize.small,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
      );
    }
    if (width >= 720) {
      // iPad portrait width: 768
      // iPad Air 4 portrait width: 820
      // iPad Pro portrait width: 834
      return WiredashResponsiveLayoutData(
        gutters: 24,
        device: LayoutClass.largeTablet,
        window: WindowSize.small,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
      );
    }
    if (width >= 600) {
      return WiredashResponsiveLayoutData(
        gutters: 16,
        device: LayoutClass.smallTablet,
        window: WindowSize.small,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
      );
    }
    if (width >= 480) {
      return WiredashResponsiveLayoutData(
        gutters: 16,
        device: LayoutClass.largeHandset,
        window: WindowSize.xsmall,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
      );
    }
    if (width >= 400) {
      // iPhone 12 pro max (2020) width: 428
      // iPhone 6+, 6S+, 7+, 8+ width: 414
      return WiredashResponsiveLayoutData(
        gutters: 16,
        device: LayoutClass.largeHandset,
        window: WindowSize.xsmall,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
      );
    }
    if (width >= 360) {
      // iPhone 12 mini (2020) width: 360
      return WiredashResponsiveLayoutData(
        gutters: 16,
        device: LayoutClass.mediumHandset,
        window: WindowSize.xsmall,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 16,
      );
    }
    return WiredashResponsiveLayoutData(
      gutters: 16,
      device: LayoutClass.smallHandset,
      window: WindowSize.xsmall,
      screenSize: size,
      isLandscape: isLandscape,
      horizontalMargin: 8,
    );
  }
}

extension WiredashResponsiveLayoutExtension on BuildContext {
  WiredashResponsiveLayoutData get responsiveLayout =>
      WiredashResponsiveLayout.of(this);
}

class WiredashResponsiveLayoutData {
  const WiredashResponsiveLayoutData({
    required this.window,
    required this.device,
    required this.screenSize,
    required this.isLandscape,
    required this.gutters,
    required this.horizontalMargin,
  });

  final WindowSize window;

  final LayoutClass device;

  final Size screenSize;

  final bool isLandscape;

  final double gutters;

  final double horizontalMargin;

  @override
  String toString() {
    return 'WiredashResponsiveLayoutData{windowSize: $window, layoutClass: $device, screenSize: $screenSize, isLandscape: $isLandscape, gutter: $gutters, horizontalMargin: $horizontalMargin}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashResponsiveLayoutData &&
          runtimeType == other.runtimeType &&
          window == other.window &&
          device == other.device &&
          screenSize == other.screenSize &&
          isLandscape == other.isLandscape &&
          gutters == other.gutters &&
          horizontalMargin == other.horizontalMargin;

  @override
  int get hashCode =>
      window.hashCode ^
      device.hashCode ^
      screenSize.hashCode ^
      isLandscape.hashCode ^
      gutters.hashCode ^
      horizontalMargin.hashCode;
}

class _ResponsiveLayoutInheritedWidget extends InheritedWidget {
  const _ResponsiveLayoutInheritedWidget({
    Key? key,
    required this.data,
    required Widget child,
  }) : super(key: key, child: child);

  final WiredashResponsiveLayoutData data;

  @override
  bool updateShouldNotify(_ResponsiveLayoutInheritedWidget old) =>
      data != old.data;
}

enum WindowSize {
  xsmall,
  small,
  medium,
  large,
  xlarge,
}

enum LayoutClass {
  smallHandset,
  mediumHandset,
  largeHandset,
  smallTablet,
  largeTablet,
  desktop,
}

extension WindowSizeOperators on WindowSize {
  int get value => WindowSize.values.indexOf(this);

  /// Whether this [WindowSize] is larger than [other].
  bool operator >(WindowSize other) => value > other.value;

  /// Whether this [WindowSize] is larger than or equal to [other].
  bool operator >=(WindowSize other) => value >= other.value;

  /// Whether this [WindowSize] is smaller than [other].
  bool operator <(WindowSize other) => value < other.value;

  /// Whether this [WindowSize] is smaller than or equal to [other].
  bool operator <=(WindowSize other) => value <= other.value;
}

extension LayoutClassOperators on LayoutClass {
  int get value => LayoutClass.values.indexOf(this);

  /// Whether this [LayoutClass] is larger than [other].
  bool operator >(LayoutClass other) => value > other.value;

  /// Whether this [LayoutClass] is larger than or equal to [other].
  bool operator >=(LayoutClass other) => value >= other.value;

  /// Whether this [LayoutClass] is smaller than [other].
  bool operator <(LayoutClass other) => value < other.value;

  /// Whether this [WindowSize] is smaller than or equal to [other].
  bool operator <=(LayoutClass other) => value <= other.value;
}
