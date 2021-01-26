## 0.4.1 - Longer feedback & more languages
* Feedback length has been increased from 512 to 2048 characters
* Support for new languages: [da] 🇩🇰, [hu] 🇭🇺, [ko] 🇰🇷, [ru] 🇷🇺 and [zh-cn] 🇨🇳. We are still missing some languages, please help us to translate Wiredash on [POEditor](https://poeditor.com/projects/view?id=347065)
* Wiredash supports Android, iOS, macOS, Windows and Linux. We hope with this release pub.dev detects it correctly

## 0.4.0 - Web support 🕸 & Customizations 🎨
* Wiredash is now available for Flutter Web. No screenshots yet but sending feedback generally works [#98](https://github.com/wiredashio/wiredash-sdk/pull/98) [#106](https://github.com/wiredashio/wiredash-sdk/pull/106)
* You can now customize the BottomSheet to match your apps style. Custom fonts & colors [#100](https://github.com/wiredashio/wiredash-sdk/pull/100) as well as disabled individually buttons [#90](https://github.com/wiredashio/wiredash-sdk/pull/90)
```dart
Wiredash(
  options: WiredashOptionsData(
    bugReportButton: false,
    featureRequestButton: false,
    praiseButton: false,
  ),
  theme: WiredashThemeData(
    fontFamily: 'Monospace',
    sheetBorderRadius: BorderRadius.zero,
    brightness: Brightness.light,
    primaryColor: Colors.red,
    secondaryColor: Colors.blue,
    firstPenColor: Colors.orange,
    secondPenColor: Colors.green,
    thirdPenColor: Colors.yellow,
    fourthPenColor: Colors.deepPurpleAccent,
  );
);
```
* Accessibility labels for all UI components [#91](https://github.com/wiredashio/wiredash-sdk/pull/91)
* Relax email validation [#85](https://github.com/wiredashio/wiredash-sdk/pull/85)
* Don't allow empty messages [#83](https://github.com/wiredashio/wiredash-sdk/pull/83)
* Don't allow opening Wiredash when navigating the app during capture [#81](https://github.com/wiredashio/wiredash-sdk/pull/81) [#103](https://github.com/wiredashio/wiredash-sdk/pull/103)
* Widen dependency ranges where possible
* Simplified sample [#102](https://github.com/wiredashio/wiredash-sdk/pull/102)
* Improve error handling of offline submissions [#104](https://github.com/wiredashio/wiredash-sdk/pull/104) [#105](https://github.com/wiredashio/wiredash-sdk/pull/105)


## 0.3.0 - Hello offline support, bye-bye FloatingEntryPoint!
* Support sending feedback and screenshots when offline.
* Added translations for Arabic, Portuguese, and Turkish.
* Removed `FloatingEntryPoint` as it was a bit confusing to first-time users, and most would disable it anyway.
* Added an `enabled` flag, docs, and hid `PaintItBlack` in the `Confidential` widget.
* Fixed translation overflow exceptions for some languages.

## 0.2.0 - Internationalization Support 🇬🇧🇩🇪🇵🇱
We added initial internationalization support for several languages. Feel free to contribute your own translations 
(check out the docs for more info on that)!

* Added `WiredashLocalizations`
* Added ability to provide custom `WiredashTranslations`
* Added buildNumber, buildVersion and buildCommit properties that can be passed through dart-define
* Constrained the SDK to 2.8.0 or newer and Flutter to 1.17.0 or newer
* Deprecated method `setIdentifiers` in favor of `setUserProperties` and `setBuildProperties`
* Minor bug fixes

## 0.1.0 - Floating Entry 📲, Confidential 👀 & Provider 🏗
Wiredash now uses the Provider package for internal state management and supports version 3.0.0 and higher. If you are
also using Provider in your app, please make sure to at least use version 3.0.0.

* Added a Floating Entry which is shown by default in debug to show Wiredash from any screen
* Added WiredashOptions to further customize the Wiredash widget (e.g. the Floating Entry)
* Added a Confidential widget to automatically hide sensitive widgets during screen capture
* Added a Wiredash.of(context).visible ValueListener to check if Wiredash is in screen capture mode (e.g. for hiding certain widgets being screen captured)
* Improved error handling when there is no valid root navigator key
* Improved performance
* Minor bug fixes

## 0.0.1 - Public Release

* Wiredash gets released to the public 🎉
