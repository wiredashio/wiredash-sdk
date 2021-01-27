import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture_provider.dart';
import 'package:wiredash/src/capture/drawer/color_picker.dart';
import 'package:wiredash/src/capture/drawer/pen.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/translation/wiredash_localizations.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

// ignore: use_key_in_widget_constructors
class Drawer extends StatelessWidget {
  static const width = 80.0;

  @override
  Widget build(BuildContext context) {
    final controller = context.sketcherController!;

    return AnimatedBuilder(
      animation: controller,
      builder: (context, __) {
        return SizedBox(
          width: Drawer.width,
          child: Stack(
            children: <Widget>[
              Container(
                alignment: Alignment.topCenter,
                margin: const EdgeInsets.only(top: 24),
                child: Image.asset(
                  'assets/images/logo_grey.png',
                  width: 40,
                  package: 'wiredash',
                  semanticLabel:
                      WiredashLocalizations.of(context)!.companyLogoLabel,
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      UndoButton(onTap: controller.undoGesture),
                      ColorPicker(
                        selectedColor: controller.color,
                        onChanged: (newColor) {
                          controller.color = newColor;
                        },
                      ),
                      FeedbackPen(color: controller.color),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class UndoButton extends StatelessWidget {
  const UndoButton({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: WiredashLocalizations.of(context)!.undoButtonLabel,
      button: true,
      child: GestureDetector(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 20,
          ),
          child: Icon(
            WiredashIcons.undo,
            color: WiredashTheme.of(context)!.dividerColor,
          ),
        ),
      ),
    );
  }
}
