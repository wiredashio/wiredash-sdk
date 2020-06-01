import 'package:flutter/material.dart';
import 'package:wiredash/src/common/translation/l10n.dart';
import 'package:wiredash/src/common/widgets/list_tile_button.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

class SuccessComponent extends StatelessWidget {
  final VoidCallback onClosedCallback;

  const SuccessComponent(
    this.onClosedCallback, {
    Key key,
  })  : assert(onClosedCallback != null),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Column(
        children: <Widget>[
          const SizedBox(height: 8),
          ListTileButton(
            icon: WiredashIcons.exit,
            iconColor: const Color(0xff9c4db1),
            iconBackgroundColor: const Color(0xffffc4f0),
            title: WiredashLocalizations.of(context)
                .feedbackStateSuccessCloseTitle,
            subtitle:
                WiredashLocalizations.of(context).feedbackStateSuccessCloseMsg,
            onPressed: onClosedCallback,
          ),
        ],
      ),
    );
  }
}
