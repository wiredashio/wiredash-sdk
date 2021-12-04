import 'package:flutter/widgets.dart';

class OffsetTransition extends AnimatedWidget {
  const OffsetTransition({
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
