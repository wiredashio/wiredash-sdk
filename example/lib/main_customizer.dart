import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_example/marianos_clones/whatsapp_clone.dart';

void main() {
  runApp(const CustomizerApp());
}

class CustomizerApp extends StatefulWidget {
  const CustomizerApp();

  @override
  State<CustomizerApp> createState() => _CustomizerAppState();
}

class _CustomizerAppState extends State<CustomizerApp> {
  final _model = ThemeModel();

  @override
  Widget build(BuildContext context) {
    return ThemeModelProvider(
      themeModel: _model,
      child: MaterialApp(
        color: Colors.green,
        theme: ThemeData.light().copyWith(
          primaryColor: Colors.green,
        ),
        home: const CustomizePage(),
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class CustomizePage extends StatefulWidget {
  const CustomizePage({Key? key}) : super(key: key);

  @override
  State<CustomizePage> createState() => _CustomizePageState();
}

class _CustomizePageState extends State<CustomizePage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: MinSize(
        minWidth: 800,
        child: Row(
          children: [
            Expanded(
              child: Container(
                color: Colors.white,
                child: ThemeControls(),
              ),
            ),
            Material(
              elevation: 4,
              color: Colors.white,
              child: Padding(
                padding: const EdgeInsets.only(
                  right: 10,
                  left: 16,
                  top: 8,
                  bottom: 8,
                ),
                child: DeviceFrame(
                  child: WhatsApp(),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class ThemeModel extends ChangeNotifier {
  Color _primaryColor = WiredashThemeData().primaryColor;

  Color get primaryColor => _primaryColor;

  set primaryColor(Color primaryColor) {
    _primaryColor = primaryColor;
    notifyListeners();
  }

  Color _secondaryColor = WiredashThemeData().secondaryColor;

  Color get secondaryColor => _secondaryColor;

  set secondaryColor(Color secondaryColor) {
    _secondaryColor = secondaryColor;
    notifyListeners();
  }

  static ThemeModel of(BuildContext context, {bool listen = true}) {
    if (listen) {
      return context
          .dependOnInheritedWidgetOfExactType<ThemeModelProvider>()!
          .notifier!;
    } else {
      return context
          .findAncestorWidgetOfExactType<ThemeModelProvider>()!
          .notifier!;
    }
  }
}

class ThemeModelProvider extends InheritedNotifier<ThemeModel> {
  const ThemeModelProvider({
    Key? key,
    required ThemeModel themeModel,
    required Widget child,
  }) : super(key: key, notifier: themeModel, child: child);
}

extension on BuildContext {
  ThemeModel get watchThemeModel => ThemeModel.of(this);

  ThemeModel get readThemeModel => ThemeModel.of(this, listen: false);
}

class ThemeControls extends StatelessWidget {
  const ThemeControls({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Overlay(
      initialEntries: [
        OverlayEntry(
          builder: (context) {
            return Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Primary Color'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: WiredashColorPicker(
                      color: context.watchThemeModel.primaryColor,
                      onColorChanged: (color) {
                        context.readThemeModel.primaryColor = color;
                      },
                    ),
                  ),
                  SizedBox(height: 20),
                  Text('Secondary Color'),
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: WiredashColorPicker(
                      color: context.watchThemeModel.secondaryColor,
                      onColorChanged: (color) {
                        context.readThemeModel.secondaryColor = color;
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}

class WiredashColorPicker extends StatefulWidget {
  const WiredashColorPicker({
    Key? key,
    required this.color,
    required this.onColorChanged,
  }) : super(key: key);

  final Color color;
  final void Function(Color) onColorChanged;

  @override
  State<WiredashColorPicker> createState() => _WiredashColorPickerState();
}

class _WiredashColorPickerState extends State<WiredashColorPicker> {
  late final TextEditingController _textEditingController;

  @override
  void initState() {
    super.initState();
    _textEditingController =
        TextEditingController(text: colorToHex(widget.color));
  }

  @override
  void dispose() {
    _textEditingController.dispose();
    super.dispose();
  }

  final _layerLink = LayerLink();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CompositedTransformTarget(
            link: _layerLink,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SizedBox(
                  height: 32,
                  width: 50,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: Material(
                      color: widget.color,
                      child: InkWell(
                        onTap: () {
                          openColorPicker();
                        },
                        highlightColor: widget.color.withAlpha(20),
                        child: Container(),
                      ),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: _textEditingController,
                    decoration: InputDecoration(
                      prefixIcon: Icon(Icons.tag, size: 14),
                      prefixIconConstraints:
                          BoxConstraints.tightFor(width: 30, height: 20),
                      border: OutlineInputBorder(
                          borderSide: BorderSide(), gapPadding: 0),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      counterText: '',
                    ),
                    maxLength: 9,
                    style: TextStyle(fontSize: 14),
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(
                          RegExp(kValidHexPattern)),
                    ],
                  ),
                ),
              ],
            ),
          ),
          SizedBox(height: 8),
        ],
      ),
    );
  }

  void openColorPicker() {
    final overlay = Overlay.of(context)!;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) {
        return GestureDetector(
          onTap: () {
            entry.remove();
          },
          child: Container(
            color: Colors.black12,
            child: Align(
              child: CompositedTransformFollower(
                followerAnchor: Alignment.topLeft,
                targetAnchor: Alignment.bottomLeft,
                link: _layerLink,
                child: Card(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: SizedBox(
                      width: 200,
                      height: 300,
                      child: ColorPicker(
                        colorPickerWidth: 200,
                        portraitOnly: true,
                        pickerAreaHeightPercent: 0.7,
                        enableAlpha: false,
                        displayThumbColor: true,
                        hexInputController: _textEditingController,
                        pickerColor: widget.color,
                        onColorChanged: widget.onColorChanged,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
    overlay.insert(entry);
  }
}

class DeviceFrame extends StatelessWidget {
  const DeviceFrame({
    Key? key,
    required this.child,
  }) : super(key: key);

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 400,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(26),
        color: Colors.black,
      ),
      child: Padding(
        padding: const EdgeInsets.only(
          top: 22,
          bottom: 16,
          left: 10,
          right: 10,
        ),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            color: Colors.white,
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return MediaQuery(
                data: MediaQuery.of(context).copyWith(
                  size: Size(
                    constraints.maxWidth,
                    constraints.maxHeight,
                  ),
                ),
                child: PrimaryScrollController(
                  controller: ScrollController(),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(16),
                    child: Wiredash(
                      projectId: "Project ID from console.wiredash.io",
                      secret: "API Key from console.wiredash.io",
                      theme: WiredashThemeData(
                        primaryColor: context.watchThemeModel.primaryColor,
                        secondaryColor: context.watchThemeModel.secondaryColor,
                      ),
                      child: child,
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

/// Starts scrolling [child] vertically and horizontally when the widget sizes
/// reaches below [minWidth] or [minHeight]
class MinSize extends StatefulWidget {
  const MinSize({
    Key? key,
    this.minWidth,
    this.minHeight,
    required this.child,
  }) : super(key: key);

  final Widget child;

  final double? minWidth;

  final double? minHeight;

  @override
  State<MinSize> createState() => _MinSizeState();
}

class _MinSizeState extends State<MinSize> {
  late final _verticalController = ScrollController();
  late final _horizontalController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final shouldScrollVertical = widget.minHeight != null &&
            constraints.maxHeight <= widget.minHeight!;
        final contentHeight =
            shouldScrollVertical ? widget.minHeight : constraints.maxHeight;
        final verticalPhysics = shouldScrollVertical
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();

        final shouldScrollHorizontal =
            widget.minWidth != null && constraints.maxWidth <= widget.minWidth!;
        final contentWidth =
            shouldScrollHorizontal ? widget.minWidth : constraints.maxWidth;
        final horizontalPhysics = shouldScrollHorizontal
            ? const AlwaysScrollableScrollPhysics()
            : const NeverScrollableScrollPhysics();

        return Scrollbar(
          controller: _verticalController,
          thumbVisibility: shouldScrollVertical,
          child: SingleChildScrollView(
            controller: _verticalController,
            scrollDirection: Axis.vertical,
            physics: verticalPhysics,
            child: Scrollbar(
              interactive: true,
              controller: _horizontalController,
              thumbVisibility: shouldScrollHorizontal,
              child: SingleChildScrollView(
                controller: _horizontalController,
                scrollDirection: Axis.horizontal,
                physics: horizontalPhysics,
                child: UnconstrainedBox(
                  child: SizedBox(
                    height: contentHeight,
                    width: contentWidth,
                    child: widget.child,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
