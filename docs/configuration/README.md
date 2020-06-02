# Customising the Wiredash widget
Wiredash provides users with various options to customise the interface and branding to fit the needs of their application. 

At the centre of this is the `Wiredash` class. As shown in our previous guide, the `Wiredash` class requires three parameters:
- Project ID
- Client Secret 
- Navigator key

In addition to these options, the parameters `options`, `theme` and `translation` can be passed. 

## Option : `WiredashOptionsData`
This can be used to control various configurations and behavior of the Wiredash widget. 

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
 Note: The Wiredash logo can also be changed under the integrations section of the console. Here users can upload a custom app image to be displayed in the Wiredash widget. 
 :::

## Translation: `WiredashTranslationData`
String used in the Wiredash widget are stored under the `WiredashTranslationData` class. Here, users can override and provide custom strings for their application. 

To see the available keys, please see [https://github.com/wiredashio/wiredash-sdk/blob/master/lib/src/common/translation/wiredash\_translation\_data.dart](https://github.com/wiredashio/wiredash-sdk/blob/master/lib/src/common/translation/wiredash_translation_data.dart)

![](New%20Logo.png)