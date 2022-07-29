import 'package:flutter/widgets.dart';

class TronIcon extends StatefulWidget {
  const TronIcon(
    this.icon, {
    this.color,
    Key? key,
    this.size,
    this.duration = const Duration(milliseconds: 250),
  }) : super(key: key);

  final Color? color;
  final Duration duration;
  final IconData icon;
  final double? size;

  @override
  State<TronIcon> createState() => _TronIconState();
}

class _TronIconState extends State<TronIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  IconData? _oldIcon;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration * 0.5,
      reverseDuration: widget.duration,
      debugLabel: 'TronIcon',
    );
    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _oldIcon = null;
          _controller.reverse();
        });
      }
    });
    _fadeAnimation = Tween(begin: 1.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOut,
        reverseCurve: Curves.easeIn,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant TronIcon oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.icon != widget.icon) {
      setState(() {
        _oldIcon = oldWidget.icon;
        _controller.forward();
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: Icon(
        _oldIcon ?? widget.icon,
        size: widget.size ?? 20,
        color: widget.color,
      ),
    );
  }
}
