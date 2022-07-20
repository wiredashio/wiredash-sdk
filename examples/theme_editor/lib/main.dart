import 'dart:math';

import 'package:device_frame/device_frame.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_theme_editor/marianos_clones/whatsapp_clone.dart';

void main() {
  runApp(const CustomizerApp());
}

class CustomizerApp extends StatefulWidget {
  const CustomizerApp();

  @override
  State<CustomizerApp> createState() => _CustomizerAppState();
}

class _CustomizerAppState extends State<CustomizerApp> {
  Brightness _brightness = Brightness.light;

  Brightness get brightness => _brightness;

  set brightness(Brightness brightness) {
    setState(() {
      _brightness = brightness;
    });
  }

  final _lightModel = ThemeModel(brightness: Brightness.light);
  final _darkModel = ThemeModel(brightness: Brightness.dark);

  @override
  void initState() {
    super.initState();
    _lightModel.addListener(_colorUpdate);
    _darkModel.addListener(_colorUpdate);
  }

  void _colorUpdate() {
    // dark model
    if (!_darkModel.primary.hasBeenManuallyAdjusted) {
      _darkModel.primary.color = _lightModel.primary.color;
    }
    _lightModel.autoGenerate();
    _darkModel.autoGenerate();
  }

  @override
  void dispose() {
    _lightModel.dispose();
    _darkModel.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ThemeModelProvider<ThemeModel>(
      themeModel: _brightness == Brightness.light ? _lightModel : _darkModel,
      child: MaterialApp(
        theme: ThemeData.light(),
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
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return MediaQuery(
                      data: MediaQuery.of(context).copyWith(
                        size: Size(
                          constraints.maxWidth,
                          constraints.maxHeight,
                        ),
                        padding: EdgeInsets.zero,
                        viewPadding: EdgeInsets.zero,
                        viewInsets: EdgeInsets.zero,
                      ),
                      child: DeviceFrame(
                        device: Devices.ios.iPhone12Mini,
                        screen: Wiredash(
                          projectId: "Project ID from console.wiredash.io",
                          secret: "API Key from console.wiredash.io",
                          feedbackOptions: WiredashFeedbackOptions(
                            labels: [
                              Label(id: 'asdf', title: 'Bug'),
                              Label(id: 'qwer', title: 'Feature Request'),
                            ],
                          ),
                          theme: WiredashThemeData(
                            brightness: context
                                .findAncestorStateOfType<_CustomizerAppState>()!
                                .brightness,
                            primaryColor: context.watchThemeModel.primary.color,
                            secondaryColor:
                                context.watchThemeModel.secondary.color,
                            primaryBackgroundColor:
                                context.watchThemeModel.primaryBackground.color,
                            secondaryBackgroundColor: context
                                .watchThemeModel.secondaryBackground.color,
                            appBackgroundColor:
                                context.watchThemeModel.appBackground.color,
                            appHandleBackgroundColor: context
                                .watchThemeModel.appHandleBackground.color,
                            primaryContainerColor: context
                                .watchThemeModel.primaryContainerColor.color,
                            textOnPrimaryContainerColor: context.watchThemeModel
                                .textOnPrimaryContainerColor.color,
                            secondaryContainerColor: context
                                .watchThemeModel.secondaryContainerColor.color,
                            textOnSecondaryContainerColor: context
                                .watchThemeModel
                                .textOnSecondaryContainerColor
                                .color,
                          ),
                          child: WhatsApp(),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class ColorModel {
  ColorModel({required this.notifyListeners, required this.autoColor});

  void Function() notifyListeners;
  Color Function() autoColor;

  Color? _color;
  Color get color => _color ?? Color(0xFFFFFFFF);
  Color? get manuallyPickedColor => _hasBeenManuallyAdjusted ? _color : null;
  set color(Color value) {
    if (color == value) return;
    _color = value;
    notifyListeners();
  }

  bool _hasBeenManuallyAdjusted = false;

  bool get hasBeenManuallyAdjusted => _hasBeenManuallyAdjusted;

  bool get isDefault => _color == autoColor();

  void markAsTouched() {
    _hasBeenManuallyAdjusted = true;
    notifyListeners();
  }

  void reset() {
    _hasBeenManuallyAdjusted = false;
    color = autoColor();
  }
}

class ThemeModel extends ChangeNotifier {
  late final ColorModel primary;
  late final ColorModel secondary;
  late final ColorModel primaryBackground;
  late final ColorModel secondaryBackground;
  late final ColorModel appBackground;
  late final ColorModel appHandleBackground;
  late final ColorModel primaryContainerColor;
  late final ColorModel textOnPrimaryContainerColor;
  late final ColorModel secondaryContainerColor;
  late final ColorModel textOnSecondaryContainerColor;

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

  final Brightness brightness;

  ThemeModel({required this.brightness}) {
    primary = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => defaultThemeData.primaryColor,
    );
    secondary = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.secondaryColor,
    );
    primaryBackground = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.primaryBackgroundColor,
    );
    secondaryBackground = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.secondaryBackgroundColor,
    );
    appBackground = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.appBackgroundColor,
    );
    appHandleBackground = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.appHandleBackgroundColor,
    );
    primaryContainerColor = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.primaryContainerColor,
    );
    textOnPrimaryContainerColor = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.primaryTextOnBackgroundColor,
    );
    secondaryContainerColor = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.secondaryContainerColor,
    );
    textOnSecondaryContainerColor = ColorModel(
      notifyListeners: notifyListeners,
      autoColor: () => autoThemeData.textOnSecondaryContainerColor,
    );
    resetToDefaults();
  }

  void autoGenerate() {
    final auto = autoThemeData;
    if (!secondary.hasBeenManuallyAdjusted) {
      secondary.color = auto.secondaryColor;
    }
    if (!primaryBackground.hasBeenManuallyAdjusted) {
      primaryBackground.color = auto.primaryBackgroundColor;
    }
    if (!secondaryBackground.hasBeenManuallyAdjusted) {
      secondaryBackground.color = auto.secondaryBackgroundColor;
    }
    if (!appBackground.hasBeenManuallyAdjusted) {
      appBackground.color = auto.appBackgroundColor;
    }
    if (!appHandleBackground.hasBeenManuallyAdjusted) {
      appHandleBackground.color = auto.appHandleBackgroundColor;
    }
    if (!primaryContainerColor.hasBeenManuallyAdjusted) {
      primaryContainerColor.color = auto.primaryContainerColor;
    }
    if (!textOnPrimaryContainerColor.hasBeenManuallyAdjusted) {
      textOnPrimaryContainerColor.color = auto.primaryTextOnBackgroundColor;
    }
    if (!secondaryContainerColor.hasBeenManuallyAdjusted) {
      secondaryContainerColor.color = auto.secondaryContainerColor;
    }
    if (!textOnSecondaryContainerColor.hasBeenManuallyAdjusted) {
      textOnSecondaryContainerColor.color = auto.secondaryTextOnBackgroundColor;
    }
  }

  WiredashThemeData get autoThemeData => WiredashThemeData.fromColor(
        primaryColor: primary.color,
        secondaryColor: secondary.manuallyPickedColor,
        brightness: brightness,
      );

  WiredashThemeData get defaultThemeData => WiredashThemeData.fromColor(
        primaryColor: WiredashThemeData().primaryColor,
        brightness: brightness,
      );

  void resetToDefaults() {
    primary.reset();
    secondary.reset();
    primaryBackground.reset();
    secondaryBackground.reset();
    appBackground.reset();
    appHandleBackground.reset();
    primaryContainerColor.reset();
    textOnPrimaryContainerColor.reset();
    secondaryContainerColor.reset();
    textOnSecondaryContainerColor.reset();
  }
}

class ThemeModelProvider<T extends ThemeModel> extends InheritedNotifier<T> {
  const ThemeModelProvider({
    Key? key,
    required T themeModel,
    required Widget child,
  }) : super(key: key, notifier: themeModel, child: child);
}

extension on BuildContext {
  ThemeModel get watchThemeModel => ThemeModel.of(this);

  ThemeModel get readThemeModel => ThemeModel.of(this, listen: false);
}

class ThemeControls extends StatefulWidget {
  const ThemeControls({Key? key}) : super(key: key);

  @override
  State<ThemeControls> createState() => _ThemeControlsState();
}

class _ThemeControlsState extends State<ThemeControls> {
  @override
  Widget build(BuildContext context) {
    _entry.markNeedsBuild();
    return Overlay(
      initialEntries: [_entry],
    );
  }

  late final _entry = OverlayEntry(builder: _buildEntryContent);

  Widget _buildEntryContent(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectableText(
              'Base Configuration',
              style: TextStyle(fontSize: 20),
            ),
            SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'primaryColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker(
                        color: context.watchThemeModel.primary.color,
                        onColorChanged: (color) {
                          final colorModel = context.readThemeModel.primary;
                          if (colorModel.color != color) {
                            colorModel
                              ..markAsTouched()
                              ..color = color;
                          }
                        },
                        isSynced: !context
                            .watchThemeModel.primary.hasBeenManuallyAdjusted,
                        onSync: context.watchThemeModel.brightness ==
                                Brightness.light
                            ? null
                            : () {
                                final darkModel = context.readThemeModel;
                                final lightModel = context
                                    .findAncestorStateOfType<
                                        _CustomizerAppState>()!
                                    ._lightModel;
                                darkModel.primary.reset();
                                darkModel.primary.color =
                                    lightModel.primary.color;
                                darkModel.autoGenerate();
                              },
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'secondaryColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context.watchThemeModel.secondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                SelectableText(
                  'darkMode',
                  style: GoogleFonts.droidSansMono(),
                ),
                Switch(
                  value: context.watchThemeModel.brightness == Brightness.dark,
                  onChanged: (value) {
                    final state =
                        context.findAncestorStateOfType<_CustomizerAppState>();
                    state!.brightness =
                        value ? Brightness.dark : Brightness.light;
                  },
                ),
              ],
            ),
            SizedBox(height: 8),
            Wrap(
              spacing: 20,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    context.readThemeModel.resetToDefaults();
                  },
                  child: Text('Reset'),
                ),
              ],
            ),
            SizedBox(height: 20),
            Divider(),
            SizedBox(height: 20),
            SelectableText('Swatches', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'primaryContainerColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context.watchThemeModel.primaryContainerColor,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'textOnPrimaryContainerColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model:
                            context.watchThemeModel.textOnPrimaryContainerColor,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            Wrap(
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'secondaryContainerColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context.watchThemeModel.secondaryContainerColor,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'secondaryTextOnBackgroundColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context
                            .watchThemeModel.textOnSecondaryContainerColor,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            SelectableText('Background Colors', style: TextStyle(fontSize: 20)),
            SizedBox(height: 20),
            Wrap(
              spacing: 20,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'primaryBackgroundColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context.watchThemeModel.primaryBackground,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SelectableText(
                      'secondaryBackgroundColor',
                      style: GoogleFonts.droidSansMono(),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: WiredashColorPicker.bindColorModel(
                        model: context.watchThemeModel.secondaryBackground,
                        withAlpha: true,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'appBackgroundColor',
                  style: GoogleFonts.droidSansMono(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: WiredashColorPicker.bindColorModel(
                    model: context.watchThemeModel.appBackground,
                    withAlpha: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SelectableText(
                  'appHandleBackgroundColor',
                  style: GoogleFonts.droidSansMono(),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: WiredashColorPicker.bindColorModel(
                    model: context.watchThemeModel.appHandleBackground,
                    withAlpha: true,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            SizedBox(height: 300),
          ],
        ),
      ),
    );
  }
}

class WiredashColorPicker extends StatefulWidget {
  const WiredashColorPicker({
    Key? key,
    required this.color,
    required this.onColorChanged,
    required this.isSynced,
    this.withAlpha = false,
    this.onSync,
  }) : super(key: key);

  factory WiredashColorPicker.bindColorModel({
    required ColorModel model,
    bool withAlpha = false,
  }) {
    return WiredashColorPicker(
      withAlpha: withAlpha,
      color: model.color,
      onColorChanged: (color) {
        if (model.color != color) {
          model
            ..markAsTouched()
            ..color = color;
        }
      },
      isSynced: !model.hasBeenManuallyAdjusted,
      onSync: () {
        model.reset();
      },
    );
  }

  final Color color;
  final void Function(Color) onColorChanged;
  final bool withAlpha;
  final bool? isSynced;
  final void Function()? onSync;

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

    _textEditingController.addListener(() {
      final color = colorFromHex(_textEditingController.text);
      if (color != null) {
        widget.onColorChanged(color);
      }
    });
  }

  @override
  void didUpdateWidget(WiredashColorPicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.color != widget.color) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _textEditingController.text = colorToHex(widget.color);
      });
    }
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
      width: 240,
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
                  width: 60,
                  child: Material(
                    elevation: 5,
                    color: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: InkWell(
                        onTap: () {
                          openColorPicker();
                        },
                        child: Stack(
                          children: [
                            Positioned.fill(
                              child: const CustomPaint(
                                painter: CheckerPainter(),
                              ),
                            ),
                            Container(color: widget.color),
                          ],
                        ),
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
                        borderSide: BorderSide(),
                        gapPadding: 0,
                      ),
                      contentPadding: EdgeInsets.symmetric(vertical: 12),
                      isDense: true,
                      counterText: '',
                    ),
                    maxLength: 9,
                    style: TextStyle(fontSize: 14),
                    inputFormatters: [
                      UpperCaseTextFormatter(),
                      FilteringTextInputFormatter.allow(
                        RegExp(kValidHexPattern),
                      ),
                    ],
                  ),
                ),
                Visibility(
                  maintainSize: true,
                  maintainAnimation: true,
                  maintainState: true,
                  visible: widget.onSync != null,
                  child: IconButton(
                    iconSize: 16,
                    color: widget.isSynced == true ? Colors.black : Colors.grey,
                    icon: Transform.rotate(
                      angle: pi * -0.25,
                      child: Icon(
                        widget.isSynced == true ? Icons.link : Icons.link_off,
                      ),
                    ),
                    onPressed: widget.onSync,
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
                        enableAlpha: widget.withAlpha,
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
