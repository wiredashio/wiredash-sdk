---
home: true
heroImage: /hero.png
heroText: Welcome to Wiredash!
tagline: Interactive user feedback tool for Flutter apps.
actionText: Get Started →
actionLink: /guide/
features:
- title: Simple Setup 🛠
  details: Getting started requires minimal effort. It's just another widget inside your app tree, nothing more!
- title: Written in Dart 🎯
  details: The SDK is written in Dart which keeps your app size small and works best with Flutter.
- title: Open Source 👀
  details: The code is completely open source on GitHub. Know what you ship with your app and feel free to contribute.
footer: Built with ♥️ by Flutter enthusiasts around the world!
---

**As easy as 1, 2, 3**

1. Create a free account on wiredash.io. Click [here](https://console.wiredash.io) to directly go to the console.

2. Add wiredash to your pubspec.yaml.

```yaml
wiredash: ^0.1.0
```

3. Wrap your root widget with Wiredash.

```dart
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

::: warning COMPATIBILITY NOTE
Wiredash requires Flutter >= 1.7.
:::
