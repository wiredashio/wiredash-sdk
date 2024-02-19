<p align="center">
  <img width="1280" alt="Wiredash Logo" src="https://github.com/wiredashio/wiredash-sdk/assets/1096485/027485ef-e1d4-4a39-943a-41f4e956ddcc">
</p>

# Wiredash SDK for Flutter

[![Pub](https://img.shields.io/pub/v/wiredash.svg)](https://pub.dartlang.org/packages/wiredash)
[![Build](https://img.shields.io/github/actions/workflow/status/wiredashio/wiredash-sdk/nightly.yaml?branch=stable)](https://github.com/wiredashio/wiredash-sdk/actions)
[![Pub Likes](https://img.shields.io/pub/likes/wiredash)](https://pub.dev/packages/wiredash/score)
[![Popularity](https://img.shields.io/pub/popularity/wiredash)](https://pub.dev/packages/wiredash/score)
[![Pub points](https://img.shields.io/pub/points/wiredash)](https://pub.dev/packages/wiredash/score)
[![Website](https://img.shields.io/badge/website-wiredash.com-blue.svg)](https://wiredash.com/)

- **Real-time analytics**: Get real-time analytics that are GDPR-compliant and hosted in the EU 🇪🇺
- **Capture in-app user feedback**: Get direct user feedback from within your app with screenshots and tags
- **Schedule promoter score surveys**: Schedule and automate promoter score surveys.
- **Console**: The Wiredash [console](https://wiredash.com/console) provides a dashboard to access your feedback and analytics
- **Universal compatibility**: Written in Dart, Wiredash is compatible with Android, iOS, Web, macOS, Windows, Linux, and IoT
- **Free**: Wiredash is free for up to 100.000 monthly active devices

From members the Flutter Community 💙 for the Flutter Community 💙

For more info, head over to our website [wiredash.com](https://wiredash.com) or directly into the [documentation](https://docs.wiredash.com).

## 3-Minute Quick Start

> It takes less than 180 seconds to integrate Wiredash in your existing app 🚀 <br />
> Visit [docs.wiredash.com](https://docs.wiredash.com/guide/start) for the in-depth
> guide and additional info.

### 1. Create an account

Go to the [Wiredash Console](https://wiredash.com/console) and sign in with a valid Google or GitHub account. _It's
free!_<br />Click on `Create new project` and enter your app's name.

### 2. Add wiredash to your pubspec.yaml

```bash
$ flutter pub add wiredash:^1.9.0
```

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  wiredash: ^1.9.0
```

### 3. Wrap your root widget with Wiredash

Wrap the root widget of your existing app with Wiredash and make sure to fill in the `projectId` and SDK `secret`
from the [Wiredash Console](https://console.wiredash.com) > Your project >
Settings > General Settings.

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
        // Your Flutter app is basically Wiredash's direct child.
        // This can be a MaterialApp, WidgetsApp or whatever widget you like.
      ),
    );
  }
}
```

### 4. Use any of Wiredash's amazing features

#### Launch the feedback flow

From anywhere in your app, call the `Wiredash.show()` method to launch Wiredash.
Place a button in your app can call `show()`. 

```dart
FloatingActionButton(
  onPressed: () {
    Wiredash.of(context).show(inheritMaterialTheme: true);
  },
  child: Icon(Icons.feedback_outlined),
),
```

Checkout [examples/theming](https://github.com/wiredashio/wiredash-sdk/blob/stable/examples/theming/lib/main.dart) for the full example or head to the [documentation](https://docs.wiredash.com/reference/feedback) for more info.

#### Launch the Promoter Score Survey

```dart
FloatingActionButton(
  onPressed: () {
  Wiredash.of(context).showPromoterSurvey(force: true);
  },
  child: Icon(Icons.feedback_outlined),
),
```

Checkout [examples/promoter_score](https://github.com/wiredashio/wiredash-sdk/blob/stable/examples/promoter_score/lib/main.dart) for the full example or head to the [documentation](https://docs.wiredash.com/reference/promoter-score) for more info.

That's already it. Yes, it's *really that easy*. Also works on all platforms.

## License

The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL) which is redundant with [BSD](https://opensource.org/licenses/BSD-3-Clause).
See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/stable/LICENSE) for details.
