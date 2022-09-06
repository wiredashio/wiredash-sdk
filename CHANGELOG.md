# Changelog

## 1.5.0

- New: Promoter Score Surveys 🎉
  Ask your users how likely they are to recommend your app to their friends on a scale from 0-10. You can see your stats in the console in the new NPS tab.

  ```dart
  // Trigger this at significant point in your application to probably show
  // the Promoter Score survey.
  // Use [options] to adjust how often the survey is shown.
  Wiredash.of(context).showPromoterSurvey(
    options: PsOptions(
      // minimum time between two surveys
      frequency: Duration(days: 90),
      // delay before the first survey is available
      initialDelay: Duration(days: 7),
      // minimum number of app starts before the survey will be shown
      minimumAppStarts: 3,
    ),
  
    // for testing, add force the promoter score survey to appear
    force: true,
  );
  ```

## 1.2.0
  
- New locales polish `pl` 🇵🇱, spanish `es` 🇪🇸🇲🇽, portuguese `pt` 🇵🇹🇧🇷 and turkish `tr` 🇹🇷 by our awesome contributors @orestesgaolin, @jamesblasco, @KyleKun and @AtaTrkgl. Thanks!
  Want to contribute your language? Checkout the docs [Localization - Contribute to Wiredash](https://docs.wiredash.io/sdk/localization/#contribute-to-wiredash)
- Renamed `Wiredash.of(context).show(feedbackOptions: )` to `Wiredash.of(context).show(options: )`

## 1.1.0

- [#231](https://github.com/wiredashio/wiredash-sdk/pull/231) Improve opening animation performance
- [#232](https://github.com/wiredashio/wiredash-sdk/pull/232) Email step is now enabled by default (as stated in documentation)
- [#235](https://github.com/wiredashio/wiredash-sdk/pull/235) Fix l10n initialization crash on slow devices

## 1.0.0

When you're upgrading from 0.7.0:

A whole new SDK!
- Completely rewritten UI layer
- Custom metadata properties
- Custom labels
- Automatic theming

Upgrading from the 1.0.0-beta? Cool features await you!

- [#228](https://github.com/wiredashio/wiredash-sdk/pull/228) Labels can now be `hidden` and will be sent directly to the console
- [#228](https://github.com/wiredashio/wiredash-sdk/pull/228) `Wiredash.of(context).show()` now accepts `feedbackOptions`. That makes localizing easier. See the [docs](https://docs.wiredash.io/sdk/localization/#localize-labels) for more information
- [#229](https://github.com/wiredashio/wiredash-sdk/pull/229) `WiredashThemeData` now supports a `textTheme` parameter that allows setting `fontFamily` (`WiredashThemeData.fontFamily` is now deprecated)
- [#227](https://github.com/wiredashio/wiredash-sdk/pull/227) Locale `de_DE` does now match `de` localization
- [#224](https://github.com/wiredashio/wiredash-sdk/pull/224) Wiredash now extend and not override incoming `Localizations` via widget tree
- [#217](https://github.com/wiredashio/wiredash-sdk/pull/217) Pen colors are now adjustable via `WiredashTheme`
- [#218](https://github.com/wiredashio/wiredash-sdk/pull/218) Don't show "No pending feedbacks" in console

## 1.0.0-beta.5
- Capture feedback metadata even when no screenshot was made

## 1.0.0-beta.4

- [#211](https://github.com/wiredashio/wiredash-sdk/pull/211) Fix `SyncEngine` not triggering initial 'appStart' event
- [#212](https://github.com/wiredashio/wiredash-sdk/pull/212) Remove Wiredash branding from appHandle
- [#214](https://github.com/wiredashio/wiredash-sdk/pull/214) Repect user choice when removing their email address
- [#216](https://github.com/wiredashio/wiredash-sdk/pull/216) Undeprecate `Wiredash.of(context).setUserProperties()` and `Wiredash.of(context).setBuildProperties()` as alternative to `modifyMetaData`. The new `Wiredash.of(context).metaData` getter might also be handy for you
- [#217](https://github.com/wiredashio/wiredash-sdk/pull/217) You can now adjust the pen colors in `WiredashThemeData`

## 1.0.0-beta.3

- [#209](https://github.com/wiredashio/wiredash-sdk/pull/209) Sync state between sdk and console via `ping`

## 1.0.0-beta.2
- [#207](https://github.com/wiredashio/wiredash-sdk/pull/207) Multi language support. Currently, Wiredash support English 🇬🇧 and German 🇩🇪. We'd happily accept any other languages!
- [e8de7b5](https://github.com/wiredashio/wiredash-sdk/commit/e8de7b53c98edeb949a2d4117cf8c82cfdcb0c08) Fix `Confidential` widget hiding content when Wiredash was closed.
- Updated `README.md` for upcoming 1.0.0 release.

Is this release stable? Yes. And once the documentation is update we feel ready to call it `1.0.0`

## 1.0.0-beta.1

- [#205](https://github.com/wiredashio/wiredash-sdk/pull/205) Improve theming capabilities. Better automatic colors, more customizations. New `WiredashThemeData` properties: 
  - `primaryContainerColor`
  - `textOnPrimaryContainerColor`
  - `secondaryContainerColor`
  - `textOnSecondaryContainerColor`
  - `appBackgroundColor`
  - `appHandleBackgroundColor`
  - Removal of `primaryTextColor` and `secondaryTextColor`, those are not completely automatic

## 1.0.0-alpha.7

Android back button support & resizing

- [#195](https://github.com/wiredashio/wiredash-sdk/pull/195) Support for the Android back button
- [#194](https://github.com/wiredashio/wiredash-sdk/pull/194) Resize Wiredashs content area to match the size of the content
- [#201](https://github.com/wiredashio/wiredash-sdk/pull/201) Fix state restoration error when reopening Wiredash
- [#194](https://github.com/wiredashio/wiredash-sdk/pull/194) Add a "Back to app" app header on desktop
- [#198](https://github.com/wiredashio/wiredash-sdk/pull/198) Added a netflix and whatsapp clone example demonstrating Wiredashs automatic theming capabilities when using `Wiredash.of(context).show(inheritMaterialTheme: true)`
- [#199](https://github.com/wiredashio/wiredash-sdk/pull/199) Show error when taking a screenshot fails. This may happen for some widgets on web (canvaskit)
- [#202](https://github.com/wiredashio/wiredash-sdk/pull/202) Fix "Warning: Missing asset in fonts for Inter"
- [#194](https://github.com/wiredashio/wiredash-sdk/pull/194) Small color adjustments

## 1.0.0-alpha.6

- [#188](https://github.com/wiredashio/wiredash-sdk/pull/188) Fix upload of multiple screenshots for non-web platforms. May have caused double submission of feedback

## 1.0.0-alpha.5

Multiple screenshots

- [#183](https://github.com/wiredashio/wiredash-sdk/pull/183) Allow multiple screenshots to be attached to a feedback
- [#179](https://github.com/wiredashio/wiredash-sdk/pull/179) Improve performance of your app by limiting the number of widgets Wiredash injects. Noticable on low-end devices such as the iPhone SE
- [#179](https://github.com/wiredashio/wiredash-sdk/pull/179) Fix: Keep your app state when opening Wiredash. Won't happen again 🤞
- [#184](https://github.com/wiredashio/wiredash-sdk/pull/184) Documentation: Fix deprecation message of `setUserProperties` to reference `modifyMetaData`

## 1.0.0-alpha.4

Desktop in focus

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

## 1.0.0-alpha.3

No Overlay for you

- [#168](https://github.com/wiredashio/wiredash-sdk/pull/168) Fix responsive padding calculation on window resize
- [#169](https://github.com/wiredashio/wiredash-sdk/pull/169) Don't wrap user app in `Overlay`
- [#170](https://github.com/wiredashio/wiredash-sdk/pull/170) Fix dark theme on summary screen
- [#171](https://github.com/wiredashio/wiredash-sdk/pull/171) Fix screenshot layout for devices with a notch

## 1.0.0-alpha.2

Desktop improvements

- [#164](https://github.com/wiredashio/wiredash-sdk/pull/164) Support for transparent apps macOS apps
- Hide backdrop content in screenshot mode
- [#165](https://github.com/wiredashio/wiredash-sdk/pull/165) Validate email address
- [#166](https://github.com/wiredashio/wiredash-sdk/pull/166) Make email address optional. Set `WiredashFeedbackOptions(askForUserEmail: true)` to enable it
- [#167](https://github.com/wiredashio/wiredash-sdk/pull/167) New `inheritMaterialTheme` and `inheritCupertinoTheme` properties for `Wiredash.of(context).show()` to inherit the theme

## 1.0.0-alpha.1

A Whole New World

- Completely rewritten UI layer
- Custom metadata properties
- Custom labels
- Automatic theming

## 0.7.2

- Declare end of life support for `0.7.x` SDKs after **1st Jan 2023**

## 0.7.1

- Fix null-safety warning in Flutter 3.0

## 0.7.0+1

Version Bump

- Increment `sdkVersion`

## 0.7.0

Screenshot Web support for canvaskit

- [#140](https://github.com/wiredashio/wiredash-sdk/pull/135) Wiredash now supports screenshots in Flutter Web when the canvasakit renderer is used
- Flutter compatibility range: `1.26.0-17.5.pre` - `2.3.0-13.0.pre.166`

## 0.6.2

More nullsafety

- [#135](https://github.com/wiredashio/wiredash-sdk/pull/135) Don't show nullsafety warning on Flutter dev channel

## 0.6.1

Flutter 2.0

- [#133](https://github.com/wiredashio/wiredash-sdk/pull/133) Raise min Flutter SDK to `1.26.0-17.5.pre`. Older versions are incompatible with `package:path_provider`
- [#130](https://github.com/wiredashio/wiredash-sdk/pull/130) Fix Flutter web locale nnbd error on `stable` Flutter `2.0.0`

## 0.6.0

Nullsafety

- Migrate the sdk to nullsafety. No breaking changes except for raising the Dart SDK to 2.12.0-0.

## 0.5.0

SingletonFlutterWindow

- *Breaking- Replace references to `ui.Window` with the new `SingletonFlutterWindow` [`flutter/pull/69617`](https://github.com/flutter/flutter/pull/69617)
- Raise minimum Flutter version to `1.24.0-8.0.pre.341` where the breaking change was introduced

## 0.4.2

Prepare for nullsafety

- Remove mockito dependency
- Add nullability hints `/*?*/`

## 0.4.1

Longer feedback & more languages

- Feedback length has been increased from 512 to 2048 characters
- Support for new languages: [da] 🇩🇰, [hu] 🇭🇺, [ko] 🇰🇷, [ru] 🇷🇺 and [zh-cn] 🇨🇳. We are still missing some languages, please help us to translate Wiredash on [POEditor](https://poeditor.com/projects/view?id=347065)
- Wiredash supports Android, iOS, macOS, Windows and Linux. We hope with this release pub.dev detects it correctly

## 0.4.0

Web support 🕸 & Customizations 🎨

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

## 0.3.0

Hello offline support, bye-bye FloatingEntryPoint

- Support sending feedback and screenshots when offline.
- Added translations for Arabic, Portuguese, and Turkish.
- Removed `FloatingEntryPoint` as it was a bit confusing to first-time users, and most would disable it anyway.
- Added an `enabled` flag, docs, and hid `PaintItBlack` in the `Confidential` widget.
- Fixed translation overflow exceptions for some languages.

## 0.2.0

Internationalization Support 🇬🇧🇩🇪🇵🇱

We added initial internationalization support for several languages. Feel free to contribute your own translations
(check out the docs for more info on that)!

- Added `WiredashLocalizations`
- Added ability to provide custom `WiredashTranslations`
- Added buildNumber, buildVersion and buildCommit properties that can be passed through dart-define
- Constrained the SDK to 2.8.0 or newer and Flutter to 1.17.0 or newer
- Deprecated method `setIdentifiers` in favor of `setUserProperties` and `setBuildProperties`
- Minor bug fixes

## 0.1.0

Floating Entry 📲, Confidential 👀 & Provider 🏗

Wiredash now uses the Provider package for internal state management and supports version 3.0.0 and higher. If you are
also using Provider in your app, please make sure to at least use version 3.0.0.

- Added a Floating Entry which is shown by default in debug to show Wiredash from any screen
- Added WiredashOptions to further customize the Wiredash widget (e.g. the Floating Entry)
- Added a Confidential widget to automatically hide sensitive widgets during screen capture
- Added a Wiredash.of(context).visible ValueListener to check if Wiredash is in screen capture mode (e.g. for hiding certain widgets being screen captured)
- Improved error handling when there is no valid root navigator key
- Improved performance
- Minor bug fixes

## 0.0.1

Public Release

- Wiredash gets released to the public 🎉
