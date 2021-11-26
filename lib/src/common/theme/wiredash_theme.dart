import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/device_class.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

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
        // TODO copyWith new deviceClass
        return _InheritedWiredashTheme(theme: this, child: child);
      },
    );
  }

  static WiredashThemeData? of(BuildContext context) {
    final _InheritedWiredashTheme? inheritedTheme =
        context.dependOnInheritedWidgetOfExactType<_InheritedWiredashTheme>();
    return inheritedTheme?.theme.data;
  }

  static DeviceClass _calculateDeviceClass(BoxConstraints constraints) {
    final normalized = constraints.normalize();
    final width = normalized.maxWidth;
    final size = Size(normalized.maxWidth, normalized.maxHeight);
    final isLandscape = normalized.maxWidth > normalized.maxHeight;

    if (width >= 1440) return DeviceClass.desktopLarge;
    if (width >= 1024) return DeviceClass.desktopSmall;
    if (width >= 720) return DeviceClass.tabletLarge;
    if (width >= 600) return DeviceClass.tabletSmall;
    if (width >= 400) return DeviceClass.handsetLarge;
    if (width >= 360) return DeviceClass.handsetMedium;
    return DeviceClass.handsetSmall;
  }
}

class _InheritedWiredashTheme extends InheritedWidget {
  const _InheritedWiredashTheme({
    Key? key,
    required this.theme,
    required Widget child,
  }) : super(key: key, child: child);

  final WiredashTheme theme;

  @override
  bool updateShouldNotify(_InheritedWiredashTheme oldWidget) =>
      theme != oldWidget.theme;
}

extension WiredashThemeExtension on BuildContext {
  WiredashThemeData get theme => WiredashTheme.of(this)!;
}
