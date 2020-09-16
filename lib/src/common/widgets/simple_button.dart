import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/animated_fade_in.dart';

class CancelButton extends StatelessWidget {
  const CancelButton({
    Key key,
    @required this.onPressed,
    @required this.text,
  })  : assert(onPressed != null),
        assert(text != null),
        super(key: key);

  final VoidCallback onPressed;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = WiredashTheme.of(context);

    return _Wrapper(
      text: text,
      onPressed: onPressed,
      child: Row(
        children: [
          Text(
            text,
            style: theme.buttonCancel,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class NextButton extends StatelessWidget {
  const NextButton({
    Key key,
    @required this.onPressed,
    @required this.text,
    this.icon,
  })  : assert(onPressed != null),
        assert(text != null),
        super(key: key);

  final VoidCallback onPressed;
  final String text;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    final theme = WiredashTheme.of(context);

    return _Wrapper(
      text: text,
      onPressed: onPressed,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Expanded(
            child: Text(
              text,
              style: theme.buttonStyle,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.right,
            ),
          ),
          if (icon != null)
            Padding(
              padding: const EdgeInsets.only(left: 4, bottom: 2),
              child: Icon(
                icon,
                size: 12,
                color: theme.primaryColor,
              ),
            )
        ],
      ),
    );
  }
}

class _Wrapper extends StatelessWidget {
  const _Wrapper({
    Key key,
    @required this.text,
    @required this.onPressed,
    @required this.child,
  })  : assert(text != null),
        assert(onPressed != null),
        assert(child != null),
        super(key: key);

  final String text;
  final VoidCallback onPressed;
  final Widget child;

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
          child: child,
        ),
      ),
    );
  }
}
