import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

void main() => runApp(ExampleApp());

class ExampleApp extends StatefulWidget {
  @override
  _ExampleAppState createState() => _ExampleAppState();
}

class _ExampleAppState extends State<ExampleApp> {
  final _navigatorKey = GlobalKey<NavigatorState>();
  var _brightness = Brightness.light;

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "YOUR-PROJECT-ID",
      secret: "YOUR-SECRET",
      theme: WiredashThemeData(brightness: _brightness),
      navigatorKey: _navigatorKey,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Wiredash Demo',
        theme: ThemeData(brightness: _brightness),
        home: DemoHomePage(
          brightness: _brightness,
          onBrightnessChange: () {
            setState(() {
              if (_brightness == Brightness.light) {
                _brightness = Brightness.dark;
              } else {
                _brightness = Brightness.light;
              }
            });
          },
        ),
      ),
    );
  }
}

class DemoHomePage extends StatelessWidget {
  final Brightness brightness;
  final VoidCallback onBrightnessChange;

  const DemoHomePage(
      {@required this.brightness, @required this.onBrightnessChange, Key key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Wiredash Demo'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.help_outline),
            onPressed: () => Wiredash.of(context).show(),
          )
        ],
      ),
      body: const Center(
        child: Text(
          'Press the FAB to change the theme.',
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: onBrightnessChange,
        tooltip: 'Change Brightness',
        child: Icon(Icons.brightness_medium),
      ),
    );
  }
}
