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
        deviceClass: DeviceClass.largeDesktop,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 256,
        maxBodyWidth: 1040,
      );
    }
    if (width >= 1600) {
      // MacBook Pro 16" 2019 (default scale) width: 1792
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.largeDesktop,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
        maxBodyWidth: 1040,
      );
    }
    if (width >= 1440) {
      // MacBook Pro 16" 2019 (medium scale) width: 1536
      // MacBook Pro 15" 2018 width: 1440
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.largeDesktop,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
        maxBodyWidth: 1040,
      );
    }
    if (width >= 1280) {
      // iPad Pro 12.9 landscape width: 1366
      // Macbook Pro 13" 2018: 1280
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.desktop,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 128,
        maxBodyWidth: 1040,
      );
    }
    if (width >= 1024) {
      // iPad Pro 11 landscape with: 1194
      // iPad Pro 10.5 landscape with: 1112
      // iPad landscape with: 1024
      // iPad Pro 12" width: 1024
      // 	Microsoft Surface Pro 3 width: 1024
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.desktop,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 64,
        maxBodyWidth: 840,
      );
    }
    if (width >= 960) {
      // 	Microsoft Surface Book width: 1000
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.largeTablet,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 64,
        maxBodyWidth: 840,
      );
    }
    if (width >= 840) {
      // Apple iPhone 12 Pro Max (2020) landscape width: 926
      // MacBook Pro 16" 2019 (default scale) split screen width: 896
      // Samsung Galaxy Z Fold2 (2020) width: 884
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.largeTablet,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
        maxBodyWidth: 840,
      );
    }
    if (width >= 720) {
      // iPad Pro portrait width: 834
      // iPad Air 4 portrait width: 820
      // iPad portrait width: 768
      return WiredashResponsiveLayoutData(
        gutters: 24,
        deviceClass: DeviceClass.largeTablet,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
        maxBodyWidth: width,
      );
    }
    if (width >= 600) {
      // Amazon Kindle Fire portrait width: 600
      return WiredashResponsiveLayoutData(
        gutters: 16,
        deviceClass: DeviceClass.smallTablet,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
        maxBodyWidth: width,
      );
    }
    if (width >= 480) {
      // 	Sony Xperia Z4 portrait width: 534
      return WiredashResponsiveLayoutData(
        gutters: 16,
        deviceClass: DeviceClass.largeHandset,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
        maxBodyWidth: width,
      );
    }
    if (width >= 400) {
      // iPhone 12 pro max (2020) width: 428
      // iPhone 6+, 6S+, 7+, 8+ width: 414
      // Google Pixel 4 XL width: 412
      return WiredashResponsiveLayoutData(
        gutters: 16,
        deviceClass: DeviceClass.largeHandset,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 32,
        maxBodyWidth: width,
      );
    }
    if (width >= 360) {
      // Pixel 4A/5 width: 393
      // Samsung Galaxy S21 Ultra (2021) width: 384
      // iPhone 12 mini (2020) width: 360
      return WiredashResponsiveLayoutData(
        gutters: 16,
        deviceClass: DeviceClass.mediumHandset,
        screenSize: size,
        isLandscape: isLandscape,
        horizontalMargin: 16,
        maxBodyWidth: width,
      );
    }
    return WiredashResponsiveLayoutData(
      gutters: 16,
      deviceClass: DeviceClass.smallHandset,
      screenSize: size,
      isLandscape: isLandscape,
      horizontalMargin: 8,
      maxBodyWidth: width,
    );
  }
}

extension WiredashResponsiveLayoutExtension on BuildContext {
  WiredashResponsiveLayoutData get responsiveLayout =>
      WiredashResponsiveLayout.of(this);
}

class WiredashResponsiveLayoutData {
  const WiredashResponsiveLayoutData({
    required this.deviceClass,
    required this.screenSize,
    required this.isLandscape,
    required this.gutters,
    required this.horizontalMargin,
    required this.maxBodyWidth,
  });

  final DeviceClass deviceClass;

  final Size screenSize;

  final bool isLandscape;

  final double gutters;

  final double horizontalMargin;

  final double maxBodyWidth;

  @override
  String toString() {
    return 'WiredashResponsiveLayoutData{layoutClass: $deviceClass, screenSize: $screenSize, isLandscape: $isLandscape, gutter: $gutters, horizontalMargin: $horizontalMargin, maxBodyWidth: $maxBodyWidth}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashResponsiveLayoutData &&
          runtimeType == other.runtimeType &&
          deviceClass == other.deviceClass &&
          screenSize == other.screenSize &&
          isLandscape == other.isLandscape &&
          gutters == other.gutters &&
          horizontalMargin == other.horizontalMargin;

  @override
  int get hashCode =>
      deviceClass.hashCode ^
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

class DeviceClass {
  const DeviceClass(this.minWidth, {this.name});

  final double minWidth;
  final String? name;

  static const smallHandset = DeviceClass(0, name: 'smallHandset');
  static const mediumHandset = DeviceClass(360, name: 'mediumHandset');
  static const largeHandset = DeviceClass(400, name: 'largeHandset');
  static const smallTablet = DeviceClass(600, name: 'smallTablet');
  static const largeTablet = DeviceClass(720, name: 'largeTablet');
  static const desktop = DeviceClass(1024, name: 'desktop');
  static const largeDesktop = DeviceClass(1440, name: 'largeDesktop');

  /// Whether this [DeviceClass] is larger than [other].
  bool operator >(DeviceClass other) => minWidth > other.minWidth;

  /// Whether this [DeviceClass] is larger than or equal to [other].
  bool operator >=(DeviceClass other) => minWidth >= other.minWidth;

  /// Whether this [DeviceClass] is smaller than [other].
  bool operator <(DeviceClass other) => minWidth < other.minWidth;

  /// Whether this [WindowSize] is smaller than or equal to [other].
  bool operator <=(DeviceClass other) => minWidth <= other.minWidth;

  @override
  String toString() {
    return 'LayoutClass{${name ?? ''}minWidth: $minWidth}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeviceClass &&
          runtimeType == other.runtimeType &&
          minWidth == other.minWidth &&
          name == other.name;

  @override
  int get hashCode => minWidth.hashCode ^ name.hashCode;
}
