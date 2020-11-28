import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  runApp(const WiredashExampleApp());
}

class WiredashExampleApp extends StatefulWidget {
  const WiredashExampleApp({Key key}) : super(key: key);

  @override
  _WiredashExampleAppState createState() => _WiredashExampleAppState();
}

class _WiredashExampleAppState extends State<WiredashExampleApp> {
  /// Wiredash uses a navigation key to show and hide our overlay. This key must
  /// be passed to the `MaterialApp` and `Wiredash` widgets. Note you are not
  /// required to use `MaterialApp`, Wiredash will work perfectly fine with
  /// `CupertinoApp` and `WidgetsApp`.
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    /// Here we wrap our app at the top level using a `Wiredash` widget. This
    /// requires us to pass the `projectId` and `secret` obtained from the
    /// "configuration" section of your console. Notice we are also passing our
    /// `_navigatorKey` to both widgets. Wiredash also allows you to setup
    /// custom themes and translations using `WiredashThemeData` and
    /// `WiredashOptionsData`. Both of these are optional but should your heart
    /// desire an extra layer of customizability, you can make wiredash your
    /// own. Read more about translations support in the package's README.
    return Wiredash(
      projectId: "test-project-mh3sn7w",
      // "Project ID from console.wiredash.io",
      secret: "gnl438nzbuihgsaaiq1uspfcm38r0osc",
      // "API Key from console.wiredash.io"
      navigatorKey: _navigatorKey,
      options: WiredashOptionsData(
          // Uncomment below to disable the screenshot step
          // screenshotStep: false,

          // Uncomment below to disable different buttons
          // bugReportButton: false,
          // featureRequestButton: false,
          // praiseButton: false,

          // Uncomment below to see how custom translations work
          // customTranslations: {
          //   const Locale.fromSubtags(languageCode: 'en'):
          //       const DemoCustomTranslations(),
          //   const Locale.fromSubtags(languageCode: 'pl'):
          //       const DemoPolishTranslations(),
          // },

          // Uncomment below to override default device locale
          // locale: const Locale('de'),
          // textDirection: TextDirection.rtl,
          ),
      theme: WiredashThemeData(
          // Uncomment Blow to explore the various Theme Options!

          // Customize Font Family
          // fontFamily: 'Monospace',

          // Customize the Bottom Sheet Border Radius
          // sheetBorderRadius: BorderRadius.zero,

          // Customize Brightness and Colors
          // brightness: Brightness.light,
          // primaryColor: Colors.red,
          // secondaryColor: Colors.blue,

          // Customize the Pen Colors
          // Note: If you change the Pen Colors, please consider providing
          // custom translations to the WiredashOptions to ensure the app is
          // accessible to all. The default translations describe the default
          // pen colors.
          // firstPenColor: Colors.orange,
          // secondPenColor: Colors.green,
          // thirdPenColor: Colors.yellow,
          // fourthPenColor: Colors.deepPurpleAccent,
          ),
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        home: const _HomePage(),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  const _HomePage({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wiredash Demo'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(8),
        itemBuilder: (BuildContext context, int index) {
          return InkWell(
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (BuildContext context) {
                    return _DetailsPage(index: index);
                  },
                ),
              );
            },
            child: Card(
              child: ListTile(
                title: Text('ListTile #$index'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: Wiredash.of(context).show,
        child: Icon(Icons.help),
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  const _DetailsPage({
    Key key,
    @required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page #$index'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Text('The details page for list item number $index.'),
        ),
      ),
    );
  }
}
