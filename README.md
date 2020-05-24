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

After successfully creating a new project in the Wiredash admin console it's time to add Wiredash to your app. Simply open your `pubspec.yaml` file and add the current version of Wiredash as a dependency, e.g. `wiredash: 0.0.2`. Make sure to get the newest version.

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

### Android / iOS specific setup

Wiredash is by design written in Dart and relies on very few dependencies by the official Flutter team. However, when running on Android it needs the internet permission (for sending user feedback back to you). If you already use Flutter in production, chances are quite high that you already added the internet permission to the manifest - if not, add the following line to the `AndroidManifest.xml` in your Android project folder:

```xml
<manifest ...>
 <uses-permission android:name="android.permission.INTERNET" />
 <application ...
</manifest>
```

That's it!
  
## License  
  
The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL). See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/master/LICENSE) for details.
