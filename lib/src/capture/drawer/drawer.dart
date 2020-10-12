import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/capture_provider.dart';
import 'package:wiredash/src/capture/drawer/color_picker.dart';
import 'package:wiredash/src/capture/drawer/pen.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

// ignore: use_key_in_widget_constructors
class Drawer extends StatelessWidget {
  static const width = 80.0;

  @override
  Widget build(BuildContext context) {
    final controller = context.sketcherController;

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
                ),
              ),
              Align(
                alignment: AlignmentDirectional.bottomEnd,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: <Widget>[
                      const SizedBox(height: 80),
                      GestureDetector(
                        onTap: controller.undoGesture,
                        child: Icon(
                          WiredashIcons.undo,
                          color: WiredashTheme.of(context).dividerColor,
                        ),
                      ),
                      const SizedBox(height: 20),
                      ColorPicker(
                        selectedColor: controller.color,
                        onChanged: (newColor) {
                          controller.color = newColor;
                        },
                      ),
                      const SizedBox(height: 20),
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
