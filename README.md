<p align="center">  
<img src="https://raw.githubusercontent.com/wiredashio/wiredash-sdk/stable/.github/wiredash-text-logo.svg?sanitize=true" width="512px" alt="Wiredash Logo">
</p>

# Wiredash SDK for Flutter

[![Pub](https://img.shields.io/pub/v/wiredash.svg)](https://pub.dartlang.org/packages/wiredash)
[![Build](https://img.shields.io/github/actions/workflow/status/wiredashio/wiredash-sdk/nightly.yaml?branch=stable)](https://github.com/wiredashio/wiredash-sdk/actions)
[![Pub Likes](https://img.shields.io/pub/likes/wiredash)](https://pub.dev/packages/wiredash/score)
[![Popularity](https://img.shields.io/pub/popularity/wiredash)](https://pub.dev/packages/wiredash/score)
[![Pub points](https://img.shields.io/pub/points/wiredash)](https://pub.dev/packages/wiredash/score)
[![Website](https://img.shields.io/badge/website-wiredash.io-blue.svg)](https://wiredash.io/)

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
$ flutter pub add wiredash
```

```yaml
dependencies:
  flutter:
    sdk: flutter
  ...
  wiredash: ^(latest_version_here e.g 1.7.3)
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

### 4. Use any of Wiredash's amazing features

#### Launch the feedback flow

From anywhere in your app, call the `Wiredash.show()` method to launch Wiredash:

```dart
onTap: () {
  Wiredash.of(context).show(inheritMaterialTheme: true);
}
```

Checkout [examples/theming](https://github.com/wiredashio/wiredash-sdk/blob/stable/examples/theming/lib/main.dart) for the full example.

![wiredash-wonders-demo](https://user-images.githubusercontent.com/1096485/188439010-8da591df-e5cb-446a-be7f-971d0fda68d1.gif)


#### Launch the Promoter Score Survey

```dart
onTap: () {
  Wiredash.of(context).showPromoterSurvey(force: true);
}
```

Checkout [examples/promoter_score](https://github.com/wiredashio/wiredash-sdk/blob/stable/examples/promoter_score/lib/main.dart) for the full example

![Promoter Score demo](https://user-images.githubusercontent.com/1096485/187313854-343bfe52-9444-407b-9e7e-64738187f8af.png)

That's already it. Yes, it's *really that easy*. Also works on all platforms.


## Customization & More

The Wiredash SDK is completely customizable and offers many configuration options (e.g. custom feedback categories a.k.a
labels, custom metadata, custom theming, custom translations and much, much more!) 🤯

For all the details, make sure to check out the full documentation
at [docs.wiredash.io](https://docs.wiredash.io/).

Also checkout the [examples/theming](https://github.com/wiredashio/wiredash-sdk/blob/stable/examples/theming/lib/main.dart) code example

## License

The Wiredash SDK is released under the [Attribution Assurance License](https://opensource.org/licenses/AAL) which is redundant with [BSD](https://opensource.org/licenses/BSD-3-Clause).
See [LICENSE](https://github.com/wiredashio/wiredash-sdk/blob/stable/LICENSE) for details.
