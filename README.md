<p align="center">  
<img src="https://raw.githubusercontent.com/wiredashio/wiredash-sdk/stable/.github/wiredash-text-logo.svg?sanitize=true" width="512px" alt="Wiredash Logo">
</p>

# Wiredash SDK for Flutter

[![Pub](https://img.shields.io/pub/v/wiredash.svg)](https://pub.dartlang.org/packages/wiredash)
[![Build](https://img.shields.io/github/workflow/status/wiredashio/wiredash-sdk/Static%20Analysis)](https://github.com/wiredashio/wiredash-sdk/actions)
[![Website](https://img.shields.io/badge/website-wiredash.io-blue.svg)](https://wiredash.io/)
[![Likes](https://badges.bar/wiredash/likes)](https://pub.dev/packages/wiredash/score)
[![Popularity](https://badges.bar/wiredash/popularity)](https://pub.dev/packages/wiredash/score)
[![Pub points](https://badges.bar/wiredash/pub%20points)](https://pub.dev/packages/wiredash/score)

Wiredash is probably the easiest, and most convenient way to capture in-app user feedback, wishes, ratings and much
more. The SDK is completely written in Dart and runs on Android, iOS, Desktop and the Web. For more info, head over
to [wiredash.io](https://wiredash.io).

## 3-Minute Quick Start

> It takes less than 180 seconds to integrate Wiredash in your existing app 🚀 <br />
> Visit [docs.wiredash.io](https://docs.wiredash.io/guide/#integrating-wiredash-in-your-app) for the in-depth
> guide and additional info.

### 1. Create an account

Go to the [Wiredash Console](https://console.wiredash.io) and sign in with a valid Google or GitHub account. _It's
free!_<br />Click on `Create new project` and enter your app's name.

### 2. Add wiredash to your pubspec.yaml

```bash
$ flutter pub add wiredash:^1.0.0
```

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  wiredash: ^1.0.0
```

### 3. Wrap your root widget with Wiredash

Wrap the root widget of your existing app with Wiredash and make sure to fill in the `projectId` and SDK `secret`
from the [Wiredash Console](https://console.wiredash.io) > Your project >
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

### 4. Launch the feedback flow

From anywhere in your app, call the `Wiredash.show()` method to launch Wiredash:

```dart
Wiredash.of(context).show(inheritMaterialTheme: true);
```

That's already it. Yes, it's *really that easy*. Also works on all platforms.

![Wiredash demo](https://raw.githubusercontent.com/wiredashio/wiredash-sdk/stable/.github/wiredash-demo.gif)

## Customization & More

The Wiredash SDK is completely customizable and offers many configuration options (e.g. custom feedback categories a.k.a
labels, custom metadata, custom theming, custom translations and much, much more!) 🤯

For all the details, make sure to check out the full documentation
at [docs.wiredash.io](https://docs.wiredash.io/configuration/).

Also checkout the [example](https://github.com/wiredashio/wiredash-sdk/blob/stable/example/lib/main.dart) code

## License

The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL).
See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/stable/LICENSE) for details.
