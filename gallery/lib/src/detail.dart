// ignore_for_file: implementation_imports

import 'package:flutter/material.dart';
import 'package:stage_craft/stage_craft.dart';
import 'package:wiredash/src/core/widgets/tron/tron_button.dart';
import 'package:wiredash/src/core/theme/wiredash_theme.dart';
import 'package:wiredash/wiredash.dart';

class WidgetDetailPage extends StatefulWidget {
  const WidgetDetailPage({super.key});

  @override
  State<WidgetDetailPage> createState() => _WidgetDetailPageState();
}

class _WidgetDetailPageState extends State<WidgetDetailPage> {
  late StageController _controller;

  @override
  void initState() {
    super.initState();
    _controller = StageController(
      // bug size doesn't work
      // Remove set stageSize, only the user should be able to change it
      stageSize: Size(48, 120),
      // I should be able to change the background color based on a FieldConfigurator
      backgroundColor: Colors.black,
      // does nothing?
      stagePosition: Offset(0, 100),
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // nice!
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Why is the background black
    // Where can I change the zoom control colors?
    // Where to set the background color of the ConfigurationBar?
    // Why no configurationBarHeader?
    return Scaffold(
      body: ColoredBox(
        color: Color(0xFFEFEFEF),
        child: StageCraft(
          stageController: _controller,
          // bug size doesn't work
          // change to startSize because the user can change it
          stageSize: Size(48, 120), // maybe just size? or aspect ratio?
          // padding for the widget inside
          configurationBarFooter: Placeholder(),

          // ConfigurationBar requires Material (localizations)
          // https://welsch.link/4662cLw
          // https://welsch.link/3MB6K5z
          // Add test to make StageCraft work with WidgetsApp
          // It can use Material under the hood, but should not expect the user to include it

          stageData: MyButtonStageData(),
          // data is not a good name
          // a better small an concise name would be:
          // something something provider or configurator

          settings: StageCraftSettings(
            // Ball size :grin:
            handleBallSize: 12, // what about ballDiameter
            handleBallColor: Color(0xFFE35D18).withOpacity(0.8),
            // Why is handleBallColor a required parameter, should be nullable
          ),
        ),
      ),
    );
  }
}

class MyButtonStageData extends StageData {
  @override
  String get name => 'TronButton';

  final textField = StringFieldConfigurator(
    name: 'text',
    value: 'Hello',
    // default group: 'widget',
  );

  final brightness = EnumFieldConfigurator(
    name: 'brightness',
    value: Brightness.light,
    enumValues: Brightness.values,
    // group: 'theme',
  );

  final primaryColor = ColorFieldConfigurator(
    name: 'primaryColor',
    value: Colors.blue,
    // group: 'theme',
  );

  // combine stageConfigurators and widgetConfigurators?

  @override
  List<FieldConfigurator> get stageConfigurators => [
        brightness,
        primaryColor,
      ];

  @override
  List<FieldConfigurator> get widgetConfigurators => [
        textField,
      ];

  @override
  Widget widgetBuilder(BuildContext context) {
    return WiredashTheme(
      data: WiredashThemeData.fromColor(
          primaryColor: primaryColor.value, brightness: brightness.value),
      child: TronButton(
        child: Text(textField.value),
      ),
    );
  }
}
