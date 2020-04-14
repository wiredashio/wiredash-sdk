import 'package:flutter/widgets.dart';
import 'package:wiredash/src/common/translation/wiredash_translation_data.dart';

class WiredashTranslation extends StatelessWidget {
  const WiredashTranslation({@required this.data, @required this.child});

  final WiredashTranslationData data;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return _InheritedWiredashTranslation(translation: this, child: child);
  }

  static WiredashTranslationData of(BuildContext context) {
    final _InheritedWiredashTranslation inheritedTranslation = context
        .dependOnInheritedWidgetOfExactType<_InheritedWiredashTranslation>();
    return inheritedTranslation.translation.data;
  }
}

class _InheritedWiredashTranslation extends InheritedWidget {
  const _InheritedWiredashTranslation({
    Key key,
    @required this.translation,
    @required Widget child,
  })  : assert(translation != null),
        super(key: key, child: child);

  final WiredashTranslation translation;

  @override
  bool updateShouldNotify(_InheritedWiredashTranslation oldWidget) =>
      translation != oldWidget.translation;
}
