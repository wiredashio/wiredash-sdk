# Customising the Wiredash widget
Wiredash provides users with various options to customise the interface and branding to fit the needs of their application. 

At the centre of this is the `Wiredash` class. As shown in our previous guide, the `Wiredash` class requires three parameters:
- Project ID
- Client Secret 
- Navigator key

In addition to these options, the parameters `options`, `theme` and `customTranslations ` can be passed.

## Option : `WiredashOptionsData`
This can be used to control various configurations and behaviour of the Wiredash widget.

`showDebugFloatingEntryPoint` :  _Boolean_ -  Automatically set to true while in debug mode, this can be used to control whether the Wiredash feedback FAB is shown.

## Theme: `WiredashThemeData`
Wiredash ships with support for both light and dark themes. Users can create custom themes by supplying their own instance of `WiredashThemeData `.

The following properties are exposed for developers to customise:
```dart
WiredashThemeData({
    Brightness brightness = Brightness.light,
    Color primaryColor,
    Color secondaryColor,
    Color primaryTextColor,
    Color secondaryTextColor,
    Color tertiaryTextColor,
    Color primaryBackgroundColor,
    Color secondaryBackgroundColor,
    Color backgroundColor,
    Color dividerColor,
})
```

::: tip
The Wiredash logo can also be changed under the integrations section of the console. Here users can upload a custom app image to be displayed in the Wiredash widget.
:::

## Translation
Wiredash supports several languages out of the box. By default, Wiredash uses the `window.locale` property to set its current locale. The default/fallback locale for Wiredash is English `en`.

To override the default locale, users can provide a custom locale to `WiredashOptionsData`.  By default, English is used.

#### Supported Locales
- German: de
- English: en
- Spanish: es
- Dutch: nl
- Polish: pl

### Providing Custom Terms
Users can also provide custom translations. Wiredash gives users the ability to change all translations used by the widget or customise existing strings to better fit the needs of your app.

#### Adding custom terms
To add custom terms, users can subclass `WiredashTranslations` with the appropriate values for the locale.

```dart
// WiredashTranslations is abstract
class DemoCustomTranslations extends WiredashTranslations {
  const DemoCustomTranslations() : super();

  @override
  String get feedbackStateIntroTitle => 'Good morning!';
  /// override all the terms
}
```

For existing locales, users can subclass `WiredashLocalizedTranslations`.

```dart
import 'package:wiredash/src/common/translation/l10n/messages_pl.dart' as pl;

class DemoPolishTranslations extends pl.WiredashLocalizedTranslations {
  const DemoPolishTranslations() : super();

  @override
  String get feedbackStateIntroTitle => 'Dzień dobry!';
}
```

Once complete, we can pass our custom locale to the `Wiredash` widget via the `customTranslations` property within `WiredashOptionsData`.

```dart
return Wiredash(
  //...
  options: WiredashOptionsData(
    customTranslations: {
      const Locale.fromSubtags(languageCode: 'zh'):
          const DemoCustomTranslations()
    },
    locale: const Locale.fromSubtags(languageCode: 'zh'),
  ),
  //...
);
```

### Getting Involved 🌎
If you would like to contribute to the project, Wiredash has a [public public POEditor project ](https://poeditor.com/join/project/yq6ereCbKZ) where users can help translate the project and continue to make more accessible 💙
![](../assets/getting_started/new-logo.png)