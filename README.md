<p align="center">  
<img src="https://raw.githubusercontent.com/wiredashio/wiredash-sdk/master/.github/logo.svg?sanitize=true" width="512px" alt="Wiredash Logo">
</p>

# Wiredash SDK for Flutter

[![Pub](https://img.shields.io/pub/v/wiredash.svg)](https://pub.dartlang.org/packages/wiredash)
[![Build](https://img.shields.io/github/workflow/status/wiredashio/wiredash-sdk/Static%20Analysis)](https://github.com/wiredashio/wiredash-sdk/actions)
[![Website](https://img.shields.io/badge/website-wiredash.io-blue.svg)](https://wiredash.io/)
[![likes](https://badges.bar/wiredash/likes)](https://pub.dev/packages/wiredash/score)
[![popularity](https://badges.bar/wiredash/popularity)](https://pub.dev/packages/wiredash/score)
[![pub points](https://badges.bar/wiredash/pub%20points)](https://pub.dev/packages/wiredash/score) 
  
Wiredash is probably the easiest, and most convenient way to capture in-app user feedback, wishes, ratings and much more. The SDK is completely written in Dart and runs on Android, iOS, Desktop and the Web. For more info, head over to [wiredash.io](https://wiredash.io). 
  
## Getting Started

Visit [docs.wiredash.io](https://docs.wiredash.io/guide/#integrating-wiredash-in-your-app) for the full documentation

## Quick start guide

### 1. Create a free account on [wiredash.io](https://console.wiredash.io)

Sign in with a valid Google or GitHub account.

### 2. Add wiredash to your pubspec.yaml.

```yaml
name: your_flutter_app
dependencies:
  flutter:
    sdk: flutter
  wiredash: ^0.4.0
```

### 3. Wrap your root widget with Wiredash

Fill in the `projectId` and `secret` from [Wiredash console](https://console.wiredash.io) > Project > Settings

```dart
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

class MyApp extends StatelessWidget {
  // It's important that Wiredash and your root Material- / Cupertino- / WidgetsApp
  // share the same Navigator key.
  final _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: 'YOUR-PROJECT-ID',
      secret: 'YOUR-SECRET',
      navigatorKey: _navigatorKey,
      child: MaterialApp(
        navigatorKey: _navigatorKey,
        title: 'Flutter Demo',
        home: YourSuperDuperAwesomeApp(),
      ),
    );
  }
}
```

### 4. Launch the feedback flow

From anywhere in your app

```dart
ElevatedButton(
  // launch wiredash where appropriate in your App 
  onPressed: () => Wiredash.of(context).show(),
  child: Text('Give Feedback'),
),
```

![bottom sheet](https://deploy-preview-4--wiredash-docs.netlify.app/assets/img/wiredash-sample-app-side-by-side-start.09e3b5f2.png)

For more documentation, head over to [docs.wiredash.io](https://docs.wiredash.io/guide/#integrating-wiredash-in-your-app)

## Customization

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

Wiredash supports several languages out of the box (see the list of supported translation files [here](https://github.com/wiredashio/wiredash-sdk/tree/master/lib/src/common/translation)). By default Wiredash will be shown in the device language provided it's supported by the package.

If you want to override the default locale just pass `locale` parameter as follows. If the locale is not supported then English will be used by default.

```dart
return Wiredash(
  ...
  options: WiredashOptionsData(
    /// You can set your own locale to override device default (`window.locale` by default)
    locale: const Locale.fromSubtags(languageCode: 'pl'),
    textDirection: TextDirection.ltr,
  ),
  ...
);
```

### Providing custom terms

You can also provide custom translations. You can choose if you want to provide all the possible terms or only selected (e.g. you want to get rid of the emojis in current locale). 

For instance you can provide locale for unsupported language and use this locale by providing proper value to `locale` property. You can also override default text direction - this is recommended step if your app is using right-to-left language (`TextDirection.rtl`).

```dart
return Wiredash(
  //...
  options: WiredashOptionsData(
    customTranslations: {
      const Locale.fromSubtags(languageCode: 'zh'):
          const DemoCustomTranslations()
    },
    locale: const Locale.fromSubtags(languageCode: 'zh'),
    textDirection: TextDirection.rtl,
  ),
  //...
);
```

If you want to add new locale the custom translation class should extend `WiredashTranslations`:

```dart
// WiredashTranslations is abstract
class DemoCustomTranslations extends WiredashTranslations {
  const DemoCustomTranslations() : super();

  @override
  String get feedbackStateIntroTitle => 'Good morning!';
  /// override all the terms
}
```

Or if you want to override only selected Polish terms you should extend built-in `WiredashLocalizedTranslations`:

```dart
import 'package:wiredash/src/common/translation/l10n/messages_pl.dart' as pl;

class DemoPolishTranslations extends pl.WiredashLocalizedTranslations {
  const DemoPolishTranslations() : super();

  @override
  String get feedbackStateIntroTitle => 'Dzień dobry!';
}
```

Then provide the instance of this class to `WiredashOptionsData` as in the snippet below:

```dart
return Wiredash(
  //...
  options: WiredashOptionsData(
    customTranslations: {
      const Locale.fromSubtags(languageCode: 'pl'):
          const DemoPolishTranslations(),
    },
    locale: const Locale('pl'),
  ),
  //...
);
```

### Contribute your translations 🎉

If you want to contribute your own translations you can join our [public POEditor project here](https://poeditor.com/join/project/yq6ereCbKZ).

#### Translation contributors

Thank you so much to following people who helped translate Wiredash! 🙌

- [orkwizard](https://github.com/orkwizard) 🇪🇸
- [stefandevo](https://github.com/stefandevo) 🇳🇱
- [huextrat](https://github.com/huextrat) 🇫🇷
- [mohanadshaban](https://github.com/mohanadshaban) [ar]
- [AtaTrkgl](https://github.com/AtaTrkgl), [salihgueler](https://github.com/salihgueler) 🇹🇷
- [Caio Pedroso](https://github.com/KyleKun) 🇵🇹

## License  
  
The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL). See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/master/LICENSE) for details.
