import 'package:flutter/widgets.dart';
import 'package:wiredash/src/capture/drawer/color_picker.dart';
import 'package:wiredash/src/capture/drawer/pen.dart';
import 'package:wiredash/src/capture/state/capture_state.dart';
import 'package:wiredash/src/common/theme/wiredash_theme.dart';
import 'package:wiredash/src/common/widgets/wiredash_icons.dart';

class CaptureDrawer extends StatefulWidget {
  static const width = 80.0;

  @override
  _CaptureDrawerState createState() => _CaptureDrawerState();
}

class _CaptureDrawerState extends State<CaptureDrawer> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: CaptureDrawer.width,
      child: Stack(
        children: <Widget>[
          Container(
            alignment: Alignment.topCenter,
            margin: const EdgeInsets.only(top: 24),
            child: Image.asset(
              'assets/images/logo_draw.png',
              width: 40,
              package: 'wiredash',
            ),
          ),
          Align(
            alignment: Alignment.bottomRight,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const SizedBox(height: 80),
                  GestureDetector(
                    onTap: CaptureState.of(context).sketcherModel.undoGesture,
                    child: Icon(
                      WiredashIcons.undo,
                      color: WiredashTheme.of(context).dividerColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ColorPicker(
                    selectedColor: CaptureState.of(context).selectedPenColor,
                    onColorSelected: (newColor) =>
                        CaptureState.of(context).selectedPenColor = newColor,
                  ),
                  const SizedBox(height: 20),
                  FeedbackPen(color: CaptureState.of(context).selectedPenColor),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
