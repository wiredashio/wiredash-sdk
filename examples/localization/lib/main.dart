import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

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
        localizationDelegate: CustomWiredashTranslationsDelegate(),
      ),

      /// You can adjust the colors of Wiredash to your liking.
      /// But first check if the automatic theming with
      /// `Wiredash.of(context).show(inheritMaterialTheme: true)` works for you
      theme: WiredashThemeData.fromColor(
        // Customize Brightness and Colors
        // Primary button color, step indicator, focused input border
        primaryColor: Colors.indigo,
        // Secondary button color
        secondaryColor: Colors.purple,
        brightness: Brightness.light,
      ).copyWith(
        // Customize the Font Family
        fontFamily: 'Monospace',

        // i.e. selected labels, buttons on cards, input border
        primaryContainerColor: Colors.cyan,
        textOnPrimaryContainerColor: Colors.black,

        // i.e. labels when not selected
        secondaryContainerColor: Colors.blue,
        textOnSecondaryContainerColor: Colors.white,

        // the color behind the application, only visible when your app is
        // translucent
        appBackgroundColor: Colors.white,
        // The color of the "Return to app" bar
        appHandleBackgroundColor: Colors.blue[700],

        // The background gradient, top to bottom
        primaryBackgroundColor: Colors.white,
        secondaryBackgroundColor: Color(0xFFEDD9F6),

        errorColor: Colors.deepOrange,

        firstPenColor: Colors.yellow,
        secondPenColor: Colors.white,
        thirdPenColor: Color(0xffffebeb),
        fourthPenColor: Color(0xffced9e3),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
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
              // Wiredash.of(context).show(inheritMaterialTheme: true);
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

class CustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const CustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) => locale.languageCode == 'en';

  @override
  Future<WiredashLocalizations> load(Locale locale) =>
      SynchronousFuture(_CustomTranslationsEn());

  @override
  bool shouldReload(CustomWiredashTranslationsDelegate old) => false;
}

/// This english translation extends the default english Wiredash translations.
/// This makes is robost to changes when new terms are added.
class _CustomTranslationsEn extends WiredashLocalizationsEn {
  @override
  String get feedbackStep1MessageTitle => 'feedbackStep1MessageTitle';

  @override
  String get feedbackStep1MessageDescription =>
      'feedbackStep1MessageDescription';

  @override
  String get feedbackStep1MessageHint => 'feedbackStep1MessageHint';
}