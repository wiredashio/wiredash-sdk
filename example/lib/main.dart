import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_example/custom_demo_translations.dart';

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
    /// The `Wiredash` widget wraps the top level application widget.
    ///
    /// `Wiredash` requires the `Project ID` and the `API Key` obtained from the
    /// "Settings" tab of the console.
    ///
    /// Wiredash also allows you to set custom themes using `WiredashThemeData`.
    /// The behaviour as well as the locale and translations can be customized
    /// using `WiredashOptionsData`.
    /// Both of these are optional but they enable you to make Wiredash your
    /// own.
    /// Read more about translations support in the package's README.
    return Wiredash(
      projectId: "Project ID from console.wiredash.io",
      secret: "API Key from console.wiredash.io",
      feedbackOptions: WiredashFeedbackOptions(
        /// Uncomment below to ask users for their email
        askForUserEmail: true,

        /// Uncomment below to disable the screenshot step
        // screenshotStep: false,

        /// Attach cusotm metada to a feedback
        collectMetaData: (metaData) => metaData
          ..userEmail = 'dash@wiredash.io'
          ..custom['isPremium'] = false
          ..custom['nested'] = {'wire': 'dash'},

        labels: [
          // Take the label ids from your project console
          // https://console.wiredash.io/ -> Settings -> Labels
          Label(
            id: 'lbl-r65egsdf',
            title: 'Bug',
          ),
          Label(
            id: 'lbl-6543df23s',
            title: 'Improvement',
          ),
          Label(
            id: 'lbl-de3w2fds',
            title: 'UX/UI',
          ),
          Label(
            id: 'lbl-2r98yas4',
            title: 'Payment',
          ),
        ],
      ),

      options: WiredashOptionsData(
        /// Change the locale of the Wiredash UI
        locale: Locale('en'),

        /// Uncomment below to set custom translations work
        // localizationDelegate: CustomWiredashTranslationsDelegate(),
      ),

      /// You can adjust the colors of Wiredash to your liking.
      /// But first check if the automatic theming with
      /// `Wiredash.of(context).show(inheritMaterialTheme: true)` works for you
      theme: WiredashThemeData.fromColor(
        // Customize Brightness and Colors
        // Primary button color, step indicator, focused input border
        primaryColor: Colors.cyanAccent,
        // Secondary button color
        secondaryColor: Colors.cyan,
        brightness: Brightness.light,
      ).copyWith(
        // Customize the Font Family
        fontFamily: 'Monospace',

        // i.e. selected labels, buttons on cards, input border
        primaryContainerColor: Colors.green,
        textOnPrimaryContainerColor: Colors.black,

        // i.e. labels when not selected
        secondaryContainerColor: Colors.greenAccent,
        textOnSecondaryContainerColor: Colors.white,

        // the color behind the application, only visible when your app is
        // translucent
        appBackgroundColor: Colors.white,
        // The color of the "Return to app" bar
        appHandleBackgroundColor: Colors.blue[700],

        // The background gradient, top to bottom
        primaryBackgroundColor: Colors.white,
        secondaryBackgroundColor: Color(0xFFF4FFF4),

        errorColor: Colors.deepOrange,

        // firstPenColor: Colors.orange,
        // secondPenColor: Colors.green,
        // thirdPenColor: Colors.yellow,
        // fourthPenColor: Colors.deepPurpleAccent,
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
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
        /// Showing the Wiredash Dialog is as easy as calling:
        /// Wiredash.of(context).show()
        /// Since the `Wiredash` widget is at the root of the widget tree this
        /// method can be accessed from anywhere in the code.
        onPressed: () {
          // When using the Wiredash theme
          // Wiredash.of(context).show();

          // Automatically generate a theme
          Wiredash.of(context).show(inheritMaterialTheme: true);
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
              Wiredash.of(context).show(inheritMaterialTheme: true);
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
              SizedBox(height: 8),
              Text('Try navigating here in feedback mode.')
            ],
          ),
        ),
      ),
    );
  }
}
