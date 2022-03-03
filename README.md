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
  
## 🚀 Getting Started

> **TIP**  Visit [docs.wiredash.io](https://docs.wiredash.io/guide/#integrating-wiredash-in-your-app) for the in-depth guide and additional info.

### 1. Create a free account on [wiredash.io](https://console.wiredash.io)

Sign in with a valid Google or GitHub account.

### 2. Add wiredash to your pubspec.yaml.

```yaml
name: your_flutter_app
dependencies:
  flutter:
    sdk: flutter
  wiredash: ^1.0.0-alpha.6
```

### 3. Wrap your root widget with Wiredash

Fill in the `projectId` and `secret` from [Wiredash console](https://console.wiredash.io) > Project > Settings

```dart
import 'package:flutter/material.dart';
import 'package:wiredash/wiredash.dart';

class MyApp extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Wiredash(
      projectId: 'YOUR-PROJECT-ID',
      secret: 'YOUR-SECRET',
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

## 🎨 Customization

The Wiredash SDK is completely customizable and offers many configuration options!

For all the details, check out the full documentation at [docs.wiredash.io/configuration](https://docs.wiredash.io/configuration/).

## 📃 License  
  
The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL). See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/master/LICENSE) for details.
