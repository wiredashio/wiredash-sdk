import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';
import 'package:wiredash_localization/l10n/app_localizations.dart';

void main() {
  runApp(LocalizationExample());
}

class LocalizationExample extends StatefulWidget {
  LocalizationExample({
    super.key,
  });

  @override
  State<LocalizationExample> createState() => _LocalizationExampleState();
}

class _LocalizationExampleState extends State<LocalizationExample> {
  /// The locale that was selected by the user, defaults to the system locale
  Locale _selectedLocale = window.locale;

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "Project ID from console.wiredash.io",
      secret: "API Key from console.wiredash.io",
      options: WiredashOptionsData(
        locale: _selectedLocale,
        // You can override all existing text with a delegate
        // The same way you can add additional languages
        localizationDelegate: const CustomWiredashTranslationsDelegate(),
      ),
      child: MaterialApp(
        locale: _selectedLocale,
        debugShowCheckedModeBanner: false,
        supportedLocales: [
          Locale('en'),
          Locale('de'),
          Locale('pl'),
          Locale('ko'),
          Locale('es'),
          Locale('pt'),
        ],
        localizationsDelegates: [
          ...AppLocalizations.localizationsDelegates,
        ],
        theme: ThemeData(
          primarySwatch: Colors.green,
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
          Wiredash.of(context).show(
            inheritMaterialTheme: true,
            options: WiredashFeedbackOptions(
              email: EmailPrompt.optional,
              screenshot: ScreenshotPrompt.optional,
              labels: [
                Label(
                  id: 'label-a',
                  title: AppLocalizations.of(context)?.labelA ??
                      "Fallback for Label A",
                ),
                Label(
                  id: 'label-b',
                  title: AppLocalizations.of(context)?.labelB ??
                      "Fallback for Label B",
                ),
              ],
            ),
          );
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

              // When user selects a locale that's not in listed in
              // supportedLocales then MaterialApp uses a fallback
              Text("Selected locale: $_selectedLocale"),

              // The Locale MaterialApp has chosed from the supportedLocales
              // see https://api.flutter.dev/flutter/widgets/basicLocaleListResolution.html
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
                        _selectedLocale = Locale('pl', 'PL');
                      });
                    },
                    child: Text('pl_PL'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = Locale('ko', 'KR');
                      });
                    },
                    child: Text('ko_KR'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = Locale('es', 'ES');
                      });
                    },
                    child: Text('es_ES'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      setState(() {
                        _selectedLocale = Locale('pt', 'BR');
                      });
                    },
                    child: Text('pt_BR'),
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

/// Overrides existing and adds new Wiredash locales
class CustomWiredashTranslationsDelegate
    extends LocalizationsDelegate<WiredashLocalizations> {
  const CustomWiredashTranslationsDelegate();

  @override
  bool isSupported(Locale locale) {
    return ['en', 'de', 'pl'].contains(locale.languageCode);
  }

  @override
  Future<WiredashLocalizations> load(Locale locale) {
    switch (locale.languageCode) {
      case 'en':
        // Replace some text to better address your users
        return SynchronousFuture(_EnOverrides());
      case 'de':
        // Reuse existing copy text from AppLocalizations
        return Future(() async {
          final result = await AppLocalizations.delegate.load(locale);
          return _DeOverrides(result);
        });
      case 'pl':
        // pl is not officially supported by Wiredash, but you can add support
        // for it on your own
        return SynchronousFuture(_WiredashLocalizationsPl());
      default:
        throw "Unsupported locale $locale";
    }
  }

  @override
  bool shouldReload(CustomWiredashTranslationsDelegate old) => false;
}

/// This is an override of the Wiredash en translations.
///
/// Use it when you want to change some in Wiredash to better address your users.
///
/// Use `extends` instead of `implements` to make it robost to changes when new
/// terms are added.
class _EnOverrides extends WiredashLocalizationsEn {
  @override
  String get feedbackStep1MessageTitle => 'Do you have a problem?';

  @override
  String get feedbackStep1MessageDescription =>
      "Don't hesitate to send us your honest feedback. Crashes, bugs, and other issues are welcome.";

  @override
  String get feedbackStep1MessageHint => '...';
}

/// Injects copy text from [AppLocalizations] into Wiredash
///
/// Run `flutter gen-l10n --no-synthetic-package --nullable-getter` to generate [AppLocalizations]
class _DeOverrides extends WiredashLocalizationsDe {
  final AppLocalizations localizations;

  _DeOverrides(this.localizations);

  @override
  String get feedbackStep1MessageTitle =>
      localizations.wiredashFeedbackStep1MessageTitle;

  @override
  String get feedbackStep1MessageDescription =>
      localizations.wiredashFeedbackStep1MessageDescription;
}

/// In case Wiredash doesn't support your locale, you can add it on your own.
///
/// Consider contributing back to wiredash!
class _WiredashLocalizationsPl extends WiredashLocalizationsEn {
  _WiredashLocalizationsPl() : super('pl');

  @override
  String get feedbackStep1MessageTitle => 'Czołem';

  @override
  String get feedbackStep1MessageDescription =>
      "Czytamy uważnie wszystkie opinie. Podaj jak najwięcej szczegółów.";

  @override
  String get feedbackStep1MessageHint => 'Twój feedback';
}
