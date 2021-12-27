import 'package:flutter/widgets.dart';

/// Animated version of an [Transform.translate] that animates its
/// [Transform.origin] property.
class TranslateTransition extends AnimatedWidget {
  const TranslateTransition({
    Key? key,
    required Animation<Offset> offset,
    this.child,
  }) : super(key: key, listenable: offset);

  Animation<Offset> get offset => listenable as Animation<Offset>;

  final Widget? child;

  @override
  Widget build(BuildContext context) {
    return Transform.translate(
      offset: offset.value,
      child: child,
    );
  }
}
