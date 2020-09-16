import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';

class SimpleButton extends StatelessWidget {
  const SimpleButton({
    Key key,
    @required this.mainAxisAlignment,
    @required this.onPressed,
    @required this.text,
    this.icon,
  })  : assert(mainAxisAlignment != null),
        assert(onPressed != null),
        assert(text != null),
        super(key: key);

  final VoidCallback onPressed;
  final MainAxisAlignment mainAxisAlignment;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: onPressed,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8),
        constraints: const BoxConstraints(minHeight: 48),
        child: AnimatedFadeIn(
          changeKey: ValueKey(text),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: mainAxisAlignment,
            children: [
              Expanded(
                child: Text(
                  text,
                  style: icon != null
                      ? WiredashTheme.of(context).buttonStyle
                      : WiredashTheme.of(context).buttonCancel,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: mainAxisAlignment == MainAxisAlignment.end
                      ? TextAlign.end
                      : TextAlign.start,
                ),
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
