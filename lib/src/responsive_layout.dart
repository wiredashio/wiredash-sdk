import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';

class WiredashResponsiveLayout extends StatelessWidget {
  const WiredashResponsiveLayout({required this.child, Key? key})
      : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (context, constraints) {
      final size = Size(constraints.maxWidth, constraints.maxHeight);
      final data = WiredashResponsiveLayoutData(size);
      return _ResponsiveLayoutInheritedWidget(data: data, child: child);
    });
  }

  static WiredashResponsiveLayoutData of(BuildContext context) {
    return context
        .dependOnInheritedWidgetOfExactType<_ResponsiveLayoutInheritedWidget>()!
        .data;
  }
}

extension WiredashResponsiveLayoutExtension on BuildContext {
  WiredashResponsiveLayoutData get responsiveLayout =>
      WiredashResponsiveLayout.of(this);
}

class WiredashResponsiveLayoutData {
  WiredashResponsiveLayoutData(this.screenSize);

  final Size screenSize;

  bool get isMobile => screenSize.width < 600;
  bool get isTablet => screenSize.width >= 600;
  bool get isDesktop => screenSize.width >= 905;
  bool get isLargeDesktop => screenSize.width >= 1440;

  bool get isLandscape => screenSize.width >= screenSize.height;

  double get horizontalPadding {
    if (isLargeDesktop) return 256;
    if (isDesktop) return 128;
    if (isTablet) return 64;
    /*if (isMobile)*/ return 32;
  }

  @override
  String toString() {
    return 'ResponsiveLayoutData{${isDesktop ? 'desktop' : 'mobile'}, screenSize: $screenSize}';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WiredashResponsiveLayoutData &&
          runtimeType == other.runtimeType &&
          screenSize == other.screenSize;

  @override
  int get hashCode => screenSize.hashCode;
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
