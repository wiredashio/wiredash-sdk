<p align="center">  
<img src="https://raw.githubusercontent.com/wiredashio/wiredash-sdk/master/.github/logo.svg?sanitize=true" width="512px" alt="Wiredash Logo">
</p>

# Wiredash SDK for Flutter

[![Pub](https://img.shields.io/pub/v/wiredash.svg)](https://pub.dartlang.org/packages/wiredash)
[![Build](https://img.shields.io/github/workflow/status/wiredashio/wiredash-sdk/Static%20Analysis)](https://github.com/wiredashio/wiredash-sdk/actions)
[![Website](https://img.shields.io/badge/website-wiredash.io-blue.svg)](https://wiredash.io/)
  
Wiredash is probably the easiest and most convenient way to capture in-app user feedback, wishes, ratings and much more. The SDK is completely written in Dart and runs on Android, iOS, Desktop and the Web. For more info, head over to [wiredash.io](https://wiredash.io). 
  
## Getting Started  
  
In order to get started, you need to create an account at [wiredash.io](https://wiredash.io) - you do this by simply signing in with a valid Google or GitHub account.

### Setting up your Flutter project

After successfully creating a new project in the Wiredash admin console it's time to add Wiredash to your app. Simply open your `pubspec.yaml` file and add the current version of Wiredash as a dependency, e.g. `wiredash: 0.1.0`. Make sure to get the newest version.

Now get all pub packages by clicking on `Packages get` in your IDE or executing `flutter packages get` inside your Flutter project.

Head over to the main entry point of your app which most likely resides inside `main.dart`. In here wrap your root widget inside a `Wiredash` widget and provide your API credentials and your app's navigator key as parameters. That was already the hard part 🙌

```dart
void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: "YOUR-PROJECT-ID",
      secret: "YOUR-SECRET",
      navigatorKey: _navigatorKey,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        home: ...
      ),
    );
  }  
}
```

Now you can call `Wiredash.of(context).show()` from anywhere inside your app to start the feedback process!

### Setting user properties

You can set user properties to be sent together with the feedback by calling:

```dart
Wiredash.of(context).setUserProperties(
  userEmail: 'mail@example.com',
  userId: 'custom-id',
);
```

### Passing build information to Wiredash

**In runtime**

You can receive information about build number and build version together with the user feedback. Set build properties before sending the feedback by calling:

```dart
Wiredash.of(context).setBuildProperties(
  buildNumber: '42',
  buildVersion: '1.42',
);
```

You can also define them during compile-time instead.

**Setting build properties during compile time**

> Available only when using Flutter 1.17 or newer

If you want to receive information about build number, build version or specific commit related to the feedback you can pass additional parameters to your `flutter build` or `flutter run` command.

To receive the build information along with your feedback you mast pass `--dart-define` flags to your `flutter build` command as follows:

```sh
flutter build --dart-define=BUILD_NUMBER=$BUILD_NUMBER --dart-define=BUILD_VERSION=$BUILD_VERSION --dart-define=BUILD_COMMIT=$FCI_COMMIT
```

Supported keys are:
* BUILD_NUMBER
* BUILD_VERSION
* BUILD_COMMIT

In the example above `$BUILD_NUMBER` is an environment variable defined in CI. Of course you can also use any other value or variable like `--dart-define=BUILD_NUMBER="1.0.42"`.

Most of the CI platforms define some common environment variables containing current build number and SHA of commit used to build the app. For instance, on Codemagic these are `BUILD_NUMBER` and `FCI_COMMIT` respectively.

Be aware that this feature was added in [Flutter 1.17](https://flutter.dev/docs/development/tools/sdk/release-notes/changelogs/changelog-1.17.0) and won't work in previous versions.

### Android / iOS / MacOS specific setup

Wiredash is by design written in Dart and relies on very few dependencies by the official Flutter team. However, when running on Android it needs the internet permission (for sending user feedback back to you). If you already use Flutter in production, chances are quite high that you already added the internet permission to the manifest - if not, add the following line to the `AndroidManifest.xml` in your Android project folder:

```xml
<manifest ...>
 <uses-permission android:name="android.permission.INTERNET" />
 <application ...
</manifest>
```
That's it!

On MacOS, you also need the internet permission, so don't forget to open `Runner.xcodeproj` located in the `macos` folder in the root directory of your app, then go in the "Signing & Capabilities" tab of your XCode project.
There, be sure to check the box "Outgoing Connections (Client)".

Voilà !

## Localization/internationalization support 🇬🇧🇵🇱🇩🇪

Wiredash supports several languages by default (see the list of supported translation files in the repository). However, in order to use them a basic setup is needed in your MaterialApp similar to the official guide in the [Flutter docs](https://flutter.dev/docs/development/accessibility-and-localization/internationalization).

1. Add `flutter_localizations` dependency in your `pubspec.yaml` as described [here](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#setting-up)
2. Add `WiredashLocalizations.delegate` and all the other default localization delegates in your `MaterialApp` (see snippet below)
3. Add `WiredashLocalizations.delegate.supportedLocales` to list of supported locales
4. On iOS you need to enable desired locales in `Runner.xcworkspace` as described [here](https://flutter.dev/docs/development/accessibility-and-localization/internationalization#appendix-updating-the-ios-app-bundle)


```dart
import 'package:flutter_localizations/flutter_localizations.dart';

  MaterialApp(
    navigatorKey: _navigatorKey,
    localizationsDelegates: [
      // Add Wiredash localizations delegate
      WiredashLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalMaterialLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    supportedLocales: [
      // Wiredash supports only selected locales, 
      // so in case of unsupported
      // it will fallback to English
      ...WiredashLocalizations.delegate.supportedLocales,
    ],
  ),
  ...
```

### Providing custom terms

You can also provide custom translations for all or only selected terms. Bear in mind that **this overrides all the other localizations supported by default** (you will always see custom translations instead of ones provided by `WiredashLocalizations`).

**Important** This is experimental feature and its usage may change in the future - hopefully to something more convenient and robust.

1. Create class implementing `WiredashTranslations` to override all the possible translation terms:

```dart
// WiredashTranslations is abstract
class DemoCustomTranslations extends WiredashTranslations { 
  const DemoCustomTranslations() : super();

  @override
  String get captureSkip => 'Not this time';
  /// etc.
}
```

Or if you want to override only selected terms extend `WiredashEnglishTranslation`

```dart
class DemoCustomTranslations extends WiredashEnglishTranslation {
  const DemoCustomTranslations() : super();

  @override
  String get captureSkip => 'Not this time'';
}
```

2. Provide instance of this class to `WiredashOptionsData` as in the snippet below:

```dart
Wiredash(
  projectId: "PROJECT-ID",
  secret: "SECRET",
  navigatorKey: _navigatorKey,
  options: WiredashOptionsData(
    showDebugFloatingEntryPoint: true,
    // Provide custom translation overrides
    customTranslations: const DemoCustomTranslations(),
  ),
```

> In the future we plan to add ability to replace selected terms in all supported languages.

### Contribute your translations

If you want to contribute your own translations there are several ways to do it:

- Make a PR with your own ARB files (e.g. `intl_ru.arb`). We will happily review it and merge if it provides sufficient level of translations. To regenerate translation files follow these steps:

  - To generate `.arb` files call: 
  
  ```
  flutter pub run intl_translation:extract_to_arb --output-dir=lib/src/common/translation/l10n/ lib/src/common/translation/l10n.dart
  ```

  - To generate `.dart` files associated with `.arb` files 
  
  ```
  flutter pub run intl_translation:generate_from_arb --output-dir=lib/src/common/translation/l10n --no-use-deferred-loading lib/src/common/translation/l10n.dart lib/src/common/translation/l10n/intl_*.arb
  ```

  - Remark: It may be necessary to add `Map<String,Function>` as a return type to method `_notInlinedMessages(_)` in `messages_**.dart` file until `intl_translation` supports it by default

- Ask community to provide translations in given language. There are many Flutter developers and contributors that may answer to your request.
  
## License  
  
The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL). See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/master/LICENSE) for details.
