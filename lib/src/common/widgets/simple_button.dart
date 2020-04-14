import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';

class SimpleButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  const SimpleButton(
      {Key key, @required this.onPressed, @required this.text, this.icon})
      : assert(text != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        constraints: const BoxConstraints(minHeight: 48),
        child: AnimatedFadeIn(
          changeKey: ObjectKey(text),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                text,
                style: icon != null
                    ? WiredashTheme.of(context).buttonStyle
                    : WiredashTheme.of(context).buttonCancel,
              ),
              if (icon != null)
                Padding(
                  padding: const EdgeInsets.only(left: 4, bottom: 2),
                  child: Icon(
                    icon,
                    size: 12,
                    color: WiredashTheme.of(context).primaryColor,
                  ),
                )
            ],
          ),
        ),
      ),
    );
  }
}
