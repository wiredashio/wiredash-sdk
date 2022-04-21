# Changelog

## 1.0.0-alpha.6

- [#188](https://github.com/wiredashio/wiredash-sdk/pull/188) Fix upload of multiple screenshots for non-web platforms. May have caused double submission of feedback

## 1.0.0-alpha.5 - Multiple screenshots

- [#183](https://github.com/wiredashio/wiredash-sdk/pull/183) Allow multiple screenshots to be attached to a feedback
- [#179](https://github.com/wiredashio/wiredash-sdk/pull/179) Improve performance of your app by limiting the number of widgets Wiredash injects. Noticable on low-end devices such as the iPhone SE
- [#179](https://github.com/wiredashio/wiredash-sdk/pull/179) Fix: Keep your app state when opening Wiredash. Won't happen again 🤞
- [#184](https://github.com/wiredashio/wiredash-sdk/pull/184) Documentation: Fix deprecation message of `setUserProperties` to reference `modifyMetaData`

## 1.0.0-alpha.4 - Desktop in focus

- [#177](https://github.com/wiredashio/wiredash-sdk/pull/177) Improved Desktop UI
- [#176](https://github.com/wiredashio/wiredash-sdk/pull/176) Draw `appBackgroundColor` behind app on screenshot
- Discard feedback button
- Color selection and drawing undo
- Allow retake of screenshot
- [#172](https://github.com/wiredashio/wiredash-sdk/pull/172) Scale drawing to match the screenshot size (based on screen ppi)
- Scaling the window after capturing a screenshot doesn't change the drawing position anymore
- Hide feedback details on Summary page behind button
- Make status bar text readable on iOS
- [#175](https://github.com/wiredashio/wiredash-sdk/pull/175) Raise min Flutter SDK to 2.8, (2.9 is required for macOS)

## 1.0.0-alpha.3 - No Overlay for you

- [#168](https://github.com/wiredashio/wiredash-sdk/pull/168) Fix responsive padding calculation on window resize
- [#169](https://github.com/wiredashio/wiredash-sdk/pull/169) Don't wrap user app in `Overlay`
- [#170](https://github.com/wiredashio/wiredash-sdk/pull/170) Fix dark theme on summary screen
- [#171](https://github.com/wiredashio/wiredash-sdk/pull/171) Fix screenshot layout for devices with a notch

## 1.0.0-alpha.2 - Desktop improvements

- [#164](https://github.com/wiredashio/wiredash-sdk/pull/164) Support for transparent apps macOS apps
- Hide backdrop content in screenshot mode
- [#165](https://github.com/wiredashio/wiredash-sdk/pull/165) Validate email address
- [#166](https://github.com/wiredashio/wiredash-sdk/pull/166) Make email address optional. Set `WiredashFeedbackOptions(askForUserEmail: true)` to enable it
- [#167](https://github.com/wiredashio/wiredash-sdk/pull/167) New `inheritMaterialTheme` and `inheritCupertinoTheme` properties for `Wiredash.of(context).show()` to inherit the theme

## 1.0.0-alpha.1 - A Whole New World

- Completely rewritten UI layer
- Custom metadata properties
- Custom labels
- Automatic theming

## 0.7.0+1 - Version Bump

- Increment `sdkVersion`

## 0.7.0 - Screenshot Web support for canvaskit

- [#140](https://github.com/wiredashio/wiredash-sdk/pull/135) Wiredash now supports screenshots in Flutter Web when the canvasakit renderer is used
- Flutter compatibility range: `1.26.0-17.5.pre` - `2.3.0-13.0.pre.166`

## 0.6.2 - More nullsafety

- [#135](https://github.com/wiredashio/wiredash-sdk/pull/135) Don't show nullsafety warning on Flutter dev channel

## 0.6.1 - Flutter 2.0

- [#133](https://github.com/wiredashio/wiredash-sdk/pull/133) Raise min Flutter SDK to `1.26.0-17.5.pre`. Older versions are incompatible with `package:path_provider`
- [#130](https://github.com/wiredashio/wiredash-sdk/pull/130) Fix Flutter web locale nnbd error on `stable` Flutter `2.0.0`

## 0.6.0 - Nullsafety

- Migrate the sdk to nullsafety. No breaking changes except for raising the Dart SDK to 2.12.0-0.

## 0.5.0 - SingletonFlutterWindow

- *Breaking- Replace references to `ui.Window` with the new `SingletonFlutterWindow` [`flutter/pull/69617`](https://github.com/flutter/flutter/pull/69617)
- Raise minimum Flutter version to `1.24.0-8.0.pre.341` where the breaking change was introduced

## 0.4.2 - Prepare for nullsafety

- Remove mockito dependency
- Add nullability hints `/*?*/`

## 0.4.1 - Longer feedback & more languages

- Feedback length has been increased from 512 to 2048 characters
- Support for new languages: [da] 🇩🇰, [hu] 🇭🇺, [ko] 🇰🇷, [ru] 🇷🇺 and [zh-cn] 🇨🇳. We are still missing some languages, please help us to translate Wiredash on [POEditor](https://poeditor.com/projects/view?id=347065)
- Wiredash supports Android, iOS, macOS, Windows and Linux. We hope with this release pub.dev detects it correctly

## 0.4.0 - Web support 🕸 & Customizations 🎨

- Wiredash is now available for Flutter Web. No screenshots yet but sending feedback generally works [#98](https://github.com/wiredashio/wiredash-sdk/pull/98) [#106](https://github.com/wiredashio/wiredash-sdk/pull/106)
- You can now customize the BottomSheet to match your apps style. Custom fonts & colors [#100](https://github.com/wiredashio/wiredash-sdk/pull/100) as well as disabled individually buttons [#90](https://github.com/wiredashio/wiredash-sdk/pull/90)

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

- Accessibility labels for all UI components [#91](https://github.com/wiredashio/wiredash-sdk/pull/91)
- Relax email validation [#85](https://github.com/wiredashio/wiredash-sdk/pull/85)
- Don't allow empty messages [#83](https://github.com/wiredashio/wiredash-sdk/pull/83)
- Don't allow opening Wiredash when navigating the app during capture [#81](https://github.com/wiredashio/wiredash-sdk/pull/81) [#103](https://github.com/wiredashio/wiredash-sdk/pull/103)
- Widen dependency ranges where possible
- Simplified sample [#102](https://github.com/wiredashio/wiredash-sdk/pull/102)
- Improve error handling of offline submissions [#104](https://github.com/wiredashio/wiredash-sdk/pull/104) [#105](https://github.com/wiredashio/wiredash-sdk/pull/105)

## 0.3.0 - Hello offline support, bye-bye FloatingEntryPoint

- Support sending feedback and screenshots when offline.
- Added translations for Arabic, Portuguese, and Turkish.
- Removed `FloatingEntryPoint` as it was a bit confusing to first-time users, and most would disable it anyway.
- Added an `enabled` flag, docs, and hid `PaintItBlack` in the `Confidential` widget.
- Fixed translation overflow exceptions for some languages.

## 0.2.0 - Internationalization Support 🇬🇧🇩🇪🇵🇱

We added initial internationalization support for several languages. Feel free to contribute your own translations
(check out the docs for more info on that)!

- Added `WiredashLocalizations`
- Added ability to provide custom `WiredashTranslations`
- Added buildNumber, buildVersion and buildCommit properties that can be passed through dart-define
- Constrained the SDK to 2.8.0 or newer and Flutter to 1.17.0 or newer
- Deprecated method `setIdentifiers` in favor of `setUserProperties` and `setBuildProperties`
- Minor bug fixes

## 0.1.0 - Floating Entry 📲, Confidential 👀 & Provider 🏗

Wiredash now uses the Provider package for internal state management and supports version 3.0.0 and higher. If you are
also using Provider in your app, please make sure to at least use version 3.0.0.

- Added a Floating Entry which is shown by default in debug to show Wiredash from any screen
- Added WiredashOptions to further customize the Wiredash widget (e.g. the Floating Entry)
- Added a Confidential widget to automatically hide sensitive widgets during screen capture
- Added a Wiredash.of(context).visible ValueListener to check if Wiredash is in screen capture mode (e.g. for hiding certain widgets being screen captured)
- Improved error handling when there is no valid root navigator key
- Improved performance
- Minor bug fixes

## 0.0.1 - Public Release

- Wiredash gets released to the public 🎉
