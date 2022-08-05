import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash/wiredash_preview.dart';

void main() {
  runApp(WiredashExampleApp());
}

/// The first widget put into `runApp` should be stateful to make hot reload
/// work
class WiredashExampleApp extends StatefulWidget {
  WiredashExampleApp({Key? key}) : super(key: key);

  @override
  _WiredashExampleAppState createState() => _WiredashExampleAppState();
}

class _WiredashExampleAppState extends State<WiredashExampleApp> {
  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "Project ID from console.wiredash.io",
      secret: "API Key from console.wiredash.io",

      options: WiredashOptionsData(
        /// Change the locale of the Wiredash UI
        locale: Locale('en'),

        /// Uncomment below to set custom translations work
        // localizationDelegate: CustomWiredashTranslationsDelegate(),
      ),

      npsOptions: NpsOptions(
        collectMetaData: (metaData) => metaData..userEmail = 'dash@wiredash.io',
      ),

      /// You can adjust the colors of Wiredash to your liking.
      /// But first check if the automatic theming with
      /// `Wiredash.of(context).show(inheritMaterialTheme: true)` works for you
      theme: WiredashThemeData.fromColor(
        // Customize Brightness and Colors
        // Primary button color, step indicator, focused input border
        primaryColor: Colors.red,
        // Secondary button color is optional
        // secondaryColor: Colors.purple,
        brightness: Brightness.dark,
      ).copyWith(
        // // Customize the Font Family
        // fontFamily: 'Monospace',
        textTheme: WiredashTextTheme(
          headlineMedium: TextStyle(fontSize: 36, fontWeight: FontWeight.w100),
          headlineSmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w100),
        ),
        // i.e. selected labels, buttons on cards, input border
        primaryContainerColor: Colors.red[800],
        textOnPrimaryContainerColor: Colors.white,

        // i.e. labels when not selected
        secondaryContainerColor: Colors.red[400],
        textOnSecondaryContainerColor: Colors.white,

        // the color behind the application, only visible when your app is
        // translucent
        appBackgroundColor: Colors.white,
        // The color of the "Return to app" bar
        appHandleBackgroundColor: Colors.red[1000],

        // The background gradient, top to bottom
        primaryBackgroundColor: Colors.black,
        secondaryBackgroundColor: Colors.black,

        errorColor: Colors.orange,

        firstPenColor: Colors.yellow,
        secondPenColor: Colors.black,
        thirdPenColor: Color(0xffff0beb),
        fourthPenColor: Color(0xff0ed9e3),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.red,
          brightness: Brightness.dark,
        ),
        home: _HomePage(),
      ),
    );
  }
}

class _HomePage extends StatelessWidget {
  _HomePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wiredash Demo'),
      ),
      body: ListView.builder(
        itemBuilder: (BuildContext context, int index) {
          return ListTile(
            title: Text('Sample Item #$index'),
            subtitle: Text('Tap me to open a new page'),
            onTap: () => _openDetailsPage(context, index),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // manually opens wiredash
          Wiredash.of(context).showNps();
        },
        child: Icon(Icons.feedback_outlined),
      ),
    );
  }

  void _openDetailsPage(BuildContext context, int which) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (BuildContext context) {
          return _DetailsPage(index: which);
        },
      ),
    );
  }
}

class _DetailsPage extends StatelessWidget {
  _DetailsPage({
    Key? key,
    required this.index,
  }) : super(key: key);

  final int index;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Details Page #$index'),
        actions: [
          TextButton(
            onPressed: () {
              Wiredash.of(context).show();
            },
            child: Text(
              "Send feedback",
              style: TextStyle(
                color: Theme.of(context).primaryIconTheme.color,
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Details page #$index',
                style: Theme.of(context).textTheme.headline6,
              ),
              SizedBox(height: 32),
              Text('Try navigating here in feedback mode.'),
              ConstrainedBox(
                constraints: BoxConstraints(maxWidth: 400),
                child: TextField(
                  textAlign: TextAlign.center,
                  decoration: InputDecoration(
                    hintText: 'You can even write text in capture mode',
                  ),
                ),
              ),
              SizedBox(height: 32),
              Text('Secret data can be hidden with the Confidential Widget'),
              SizedBox(height: 16),
              Confidential(
                // mode: ConfidentialMode.invisible,
                child: Text(
                  'Secret: "wiredash rocks!"',
                  style: TextStyle(fontWeight: FontWeight.w200, fontSize: 20),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
