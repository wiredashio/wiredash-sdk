### Wrap your root widget with Wiredash

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

### Launch the feedback flow

From anywhere in your app, call the `Wiredash.show()` method to launch Wiredash:

```dart
Wiredash.of(context).show(inheritMaterialTheme: true);
```

That's already it. Yes, it's *really that easy*. Also works on all platforms.