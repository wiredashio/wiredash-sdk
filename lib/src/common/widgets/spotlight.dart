import 'dart:async';

import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/theme/wiredash_theme_data.dart';

class Spotlight extends StatefulWidget {
  final Widget child;

  const Spotlight({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  SpotlightState createState() => SpotlightState();
}

class SpotlightState extends State<Spotlight>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _opacityAnimation;
  Widget? _spotlightWidget;
  IconData? _icon;
  String? _title;
  String? _msg;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _opacityAnimation = CurvedAnimation(
      parent: _animationController,
      curve: const Interval(0.3, 1.0, curve: Curves.easeInOut),
    );

    _animationController.addStatusListener((AnimationStatus status) {
      if (status == AnimationStatus.dismissed && mounted) {
        setState(() {
          _timer?.cancel();
          _spotlightWidget = null;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        widget.child,
        if (_spotlightWidget != null)
          FadeTransition(
            opacity: _opacityAnimation,
            child: _spotlightWidget,
          ),
      ],
    );
  }

  Widget _buildSpotlightWidget() {
    return GestureDetector(
      onTap: hide,
      child: Container(
        padding: const EdgeInsets.all(32),
        alignment: Alignment.center,
        color: const Color(0x00000000).withOpacity(0.77),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              _icon,
              size: 80,
              color: WiredashThemeData.white,
            ),
            const SizedBox(height: 32),
            Text(
              _title?.toUpperCase() ?? "-",
              style: WiredashTheme.of(context)!.spotlightTitleStyle,
            ),
            const SizedBox(height: 12),
            Text(
              _msg ?? "-",
              textAlign: TextAlign.center,
              style: WiredashTheme.of(context)!.spotlightTextStyle,
            ),
          ],
        ),
      ),
    );
  }

  void hide() {
    _timer?.cancel();
    _animationController.reverse();
  }

  void show(IconData icon, String title, String message) {
    _icon = icon;
    _title = title;
    _msg = message;

    _timer?.cancel();
    _timer = Timer(const Duration(seconds: 4), hide);

    setState(() {
      _spotlightWidget = _buildSpotlightWidget();
      _animationController.forward();
    });
  }
}
