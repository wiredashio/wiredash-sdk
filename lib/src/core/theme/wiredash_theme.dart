import 'package:flutter/widgets.dart';
import 'package:wiredash/src/core/theme/wiredash_theme_data.dart';

class WiredashTheme extends StatelessWidget {
  const WiredashTheme({
    Key? key,
    required this.data,
    required this.child,
  }) : super(key: key);

  final WiredashThemeData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final deviceClass = _calculateDeviceClass(constraints);
        final themeData = data.copyWith(
          deviceClass: deviceClass,
          windowSize: constraints.biggest,
        );
        return _InheritedWiredashTheme(
          themeData: themeData,
          child: child,
        );
      },
    );
  }

  static WiredashThemeData? of(BuildContext context, {bool listen = true}) {
    if (listen) {
      final _InheritedWiredashTheme? inheritedTheme =
          context.dependOnInheritedWidgetOfExactType<_InheritedWiredashTheme>();
      return inheritedTheme?.themeData;
    }
    final _InheritedWiredashTheme? theme =
        context.findAncestorWidgetOfExactType<_InheritedWiredashTheme>();
    return theme?.themeData;
  }

  static DeviceClass _calculateDeviceClass(BoxConstraints constraints) {
    final normalized = constraints.normalize();
    final width = normalized.maxWidth;

    if (width >= 1440) return DeviceClass.desktopLarge1440;
    if (width >= 1024) return DeviceClass.desktopSmall1024;
    if (width >= 720) return DeviceClass.tabletLarge720;
    if (width >= 600) return DeviceClass.tabletSmall600;
    if (width >= 400) return DeviceClass.handsetLarge400;
    if (width >= 360) return DeviceClass.handsetMedium360;
    return DeviceClass.handsetSmall320;
  }
}

class _InheritedWiredashTheme extends InheritedWidget {
  const _InheritedWiredashTheme({
    Key? key,
    required this.themeData,
    required Widget child,
  }) : super(key: key, child: child);

  final WiredashThemeData themeData;

  @override
  bool updateShouldNotify(_InheritedWiredashTheme oldWidget) =>
      themeData != oldWidget.themeData;
}

extension WiredashThemeExtension on BuildContext {
  WiredashThemeData get theme => WiredashTheme.of(this)!;
}

extension WiredashTextThemeExtension on BuildContext {
  SurfaceBasedTextStyle get text => theme.text;
}
