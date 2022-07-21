import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:wiredash/wiredash.dart';

void main() {
  runApp(LocalizationExample());
}

class LocalizationExample extends StatefulWidget {
  LocalizationExample({
    Key? key,
  }) : super(key: key);

  @override
  State<LocalizationExample> createState() => _LocalizationExampleState();
}

class _LocalizationExampleState extends State<LocalizationExample> {
  Locale _selectedLocale = window.locale;

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "Project ID from console.wiredash.io",
      secret: "API Key from console.wiredash.io",
      options: WiredashOptionsData(
        locale: _selectedLocale,
      ),
      child: MaterialApp(
        locale: _selectedLocale,
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en'),
          Locale('de'),
          Locale('pl'),
        ],
        localizationsDelegates: [
          GlobalMaterialLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
        ],
        theme: ThemeData(
          primarySwatch: Colors.blue,
          brightness: Brightness.light,
        ),
        home: Builder(
          builder: _buildPage,
        ),
      ),
    );
  }

  Widget _buildPage(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Wiredash Localization Demo'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Wiredash.of(context).show();
        },
        child: Icon(Icons.chat),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 20),
              Text("System locale: ${window.locale}"),
              Text("Selected locale: $_selectedLocale"),
              Text("Applied locale: ${Localizations.localeOf(context)}"),
              SizedBox(height: 20),
              SizedBox(height: 20),
              Text("Switch locale:"),
              SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = Locale('de', 'DE');
                      });
                    },
                    child: Text('de_DE'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = Locale('en', 'US');
                      });
                    },
                    child: Text('en_US'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = window.locale;
                      });
                    },
                    child: Text('System'),
                  ),
                ],
              ),
              SizedBox(height: 12),
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
  String get feedbackStep1MessageTitle => 'Custom feedbackStep1MessageTitle';

  @override
  String get feedbackStep1MessageDescription =>
      'Custom feedbackStep1MessageDescription';

  @override
  String get feedbackStep1MessageHint => 'Custom feedbackStep1MessageHint';
}
