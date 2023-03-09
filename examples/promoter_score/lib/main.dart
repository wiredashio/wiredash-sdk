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
    return Wiredash(
      projectId: "Project ID from console.wiredash.io",
      secret: "API Key from console.wiredash.io",
      psOptions: PsOptions(
        collectMetaData: (metaData) => metaData..userEmail = 'dash@wiredash.io',
        // frequency: Duration(days: 90), // default
        // initialDelay: Duration(days: 7), // default
        // initialDelay: Duration.zero, // disable initial delay
        // minimumAppStarts: 3, // default
        // minimumAppStarts: 0, // disable minimum app starts
      ),
      feedbackOptions: WiredashFeedbackOptions(
        collectMetaData: (metaData) => metaData
          ..userEmail = 'dash@flutter.dev'
          ..userId = '007',
      ),
      theme: WiredashThemeData.fromColor(
        primaryColor: Colors.tealAccent,
        brightness: Brightness.dark,
      ).copyWith(
        appHandleBackgroundColor: Color(0xFF3A3A3A),
      ),
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.teal,
          brightness: Brightness.dark,
        ),
        home: _HomePage(),
      ),
    );
  }
}

class _HomePage extends StatefulWidget {
  _HomePage({Key? key}) : super(key: key);

  @override
  State<_HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<_HomePage> {
  @override
  void initState() {
    super.initState();

    // Simple method to automatically show the promoter score survey on app start
    Future.delayed(Duration(seconds: 5), () {
      if (!mounted) return;

      // Trigger this at significant point in your application to probably show
      // the Promoter Score survey.
      // Use [options] to adjust how often the survey is shown.
      Wiredash.of(context).showPromoterSurvey(
        options: PsOptions(
          // minimum time between two surveys
          frequency: Duration(days: 90),
          // delay before the first survey is available
          initialDelay: Duration(days: 7),
          // minimum number of app starts before the survey will be shown
          minimumAppStarts: 3,
        ),

        // for testing, add force the promoter score survey to appear
        force: true,
      );
    });
  }

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
          // force: true is only used for testing
          Wiredash.of(context).showPromoterSurvey(force: true);
          // Always prefer delegating the decision to show the promoter score
          // to Wiredash so you don't annoy your users.
          // Wiredash.of(context).showPromoterSurvey();
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
