# Changelog

## 2.2.1

- Fix `isBeforeFlutter3_22()` check, fixing the lifecycle on `web` in Flutter 3.19 [#354](https://github.com/wiredashio/wiredash-sdk/pull/354)
- Detect `FakeTimer` without try-catch [#355](https://github.com/wiredashio/wiredash-sdk/pull/355)

## 2.2.0

- Track Custom Analytics events (requires paid plan) [#338](https://github.com/wiredashio/wiredash-sdk/pull/338)
 
  Record user interactions or other significant occurrences within your app and send them to the Wiredash service for analysis.

  Use [Wiredash.trackEvent] for easy access from everywhere in your app.
  
  ```dart
  await Wiredash.trackEvent('Click Button', data: {/**/});
  ```
  
  Use the [WiredashAnalytics] instance for easy mocking and testing
  
  ```dart
  final analytics = WiredashAnalytics();
  await analytics.trackEvent('Click Button', data: {/**/});
  
  // inject into other classes
  final bloc = MyBloc(analytics: analytics);
  ```

  Access the correct [Wiredash] project via context to send events to if you use multiple Wiredash widgets in your app. This way you don't have to specify the [projectId] every time you call [trackEvent].

  ```dart
  Wiredash.of(context).trackEvent('Click Button');
  ```

  **eventName** constraints

   - The event name must be between 3 to 64 characters long
   - Contain only letters (a-zA-Z), numbers (0-9), - and _ and spaces
   - Must start with a letter (a-zA-Z)
   - Must not contain double spaces
   - Must not contain double or trailing spaces
 
  **data** constraints

   - Parameters must not contain more than 10 key-value pairs
   - Keys must not exceed 128 characters
   - Keys must not be empty
   - Values can be String, int or bool. null is allowed, too.
   - Each individual value must not exceed 1024 characters (after running them through jsonEncode).
 
  **Event Sending Behavior:**
 
  * Events are batched and sent to the Wiredash server periodically at 30-second intervals.
  * The first batch of events is sent after a 5-second delay.
  * Events are also sent immediately when the app goes to the background (not applicable to web platforms).
  * If events cannot be sent due to network issues, they are stored locally and retried later.
  * Unsent events are discarded after 3 days.
 
  **Multiple Wiredash Widgets:**
 
  If you have multiple [Wiredash] widgets in your app with different projectIds, you can specify the desired [projectId] when creating [WiredashAnalytics].
  This ensures that the event is sent to the correct project.
 
  If no [projectId] is provided and multiple widgets are mounted, the event will be sent to the project associated with the first mounted widget. A warning message will also be logged to the console in this scenario.
 
  **Background Isolates:**
 
  When calling [trackEvent] from a background isolate, the event will be stored locally.
  The main isolate will pick up these events and send them along with the next batch or when the app goes to the background.

## 2.1.2

- Widen package_info_plus range (include 8.x)

## 2.1.1

- Widen ranges for device_info_plus and package_info_plus [#344](https://github.com/wiredashio/wiredash-sdk/pull/344)

## 2.1.0 
- Prevent `Wiredash` from scheduling tasks in your widget tests [#332](https://github.com/wiredashio/wiredash-sdk/pull/332)
- Update README with new header image, adjust pub tags
- Run tests successfully on Flutter 3.0.0 and 3.20.0 [#335](https://github.com/wiredashio/wiredash-sdk/pull/335)
- Improve testing setup [#334](https://github.com/wiredashio/wiredash-sdk/pull/334)

## 2.0.0

- New: Wiredash Analytics 🎉
  Get real-time analytics that is GDPR-compliant and hosted in the EU 🇪🇺

- New: Force an email address with `EmailPrompt.mandatory` in feedback flow [#327](https://github.com/wiredashio/wiredash-sdk/pull/327)
- Compatability with Flutter 3.19.0 (stable) and 3.20.0 (beta)

#### Removed deprecated APIs
- `WiredashThemeData()` parameter `fontFamily`, use `textTheme` instead
- `Wiredash.of(context).setBuildProperties()` will be captured automatically. Just remove the call
- `Wiredash.of(context).show()` parameter `feedbackOptions` is now `options`
- `Wiredash()` parameter `navigatorKey`, which is not required anymore
- `WiredashFeedbackOptions()` parameter `bool askForUserEmail` replaced with `EmailPrompt email`
- `WiredashFeedbackOptions()` parameter `bool screenshotStep` replaced with `ScreenshotPrompt screenshot`
- `CustomizableWiredashMetaData.populated()` got removed. Use the default `CustomizableWiredashMetaData()` instead
- `CustomizableWiredashMetaData` removed `buildVersion`, `buildNumber` and `buildCommit`. Those are now captured automatically

## 1.9.0
- Add support for Flutter 3.17.0 (removing [`physicalGeometry`](https://github.com/flutter/flutter/pull/138103)) [#324](https://github.com/wiredashio/wiredash-sdk/pull/324)
- Add more `WiredashTheme` color overrides [#325](https://github.com/wiredashio/wiredash-sdk/pull/325)

## 1.8.1

- Ignore empty strings when setting `buildNumber`, `buildVersion` or `buildCommit` via `--dart-define` [#323](https://github.com/wiredashio/wiredash-sdk/pull/323)
- Improve SDK usage reporting

## 1.8.0
- Wiredash now automatically collects the version information of your app. No need to set `buildVersion`, `buildNumber` anymore. If you want to override this information, you can still do so via dart-define at compile time https://docs.wiredash.io/sdk/custom-properties/#during-compile-time.
- New: `Wiredash(collectSessionMetaData: )` combines and replaces `collectSessionMetaData` of `WiredashFeedbackOptions` and `PsOptions`. No deduplicate code anymore 🎉
  ```dart
  // Before
  return Wiredash(
    projectId: "...",
    secret: "...",
    feedbackOptions: WiredashFeedbackOptions(
      collectMetaData: (metaData) {
        return metaData
          ..userEmail = 'dash@flutter.dev'
          ..userId = '007'
          ..custom['myKey'] = {'myValue': '007'}},
    ),
    psOptions: PsOptions(
      collectMetaData: (metaData) {
        return metaData
          ..userEmail = 'dash@flutter.dev'
          ..userId = '007'
          ..custom['myKey'] = {'myValue': '007'}},
    ), 
  ), 
  ```
  ```dart
  // After
  return Wiredash(
    projectId: "...",
    secret: "...",
    collectMetaData: (metaData) {
      return metaData
        ..userEmail = 'dash@flutter.dev'
        ..userId = '007'
        ..custom['myKey'] = {'myValue': '007'}},
  ), 
  ```
- The metadata properties `buildVersion`, `buildNumber` and `buildCommit` cannot be set via `Wiredash.of(context).modifyiMetaData()` anymore. This information has to be provided at compile time (dart-define) or is read automatically from the app bundle 
- `setBuildProperties()` is now deprecated and noop, also use dart-define instead
- New `Wiredash.of(context).resetMetaData()` to easily reset all metadata
- Add italian `it` locale 🇮🇹[#317](https://github.com/wiredashio/wiredash-sdk/pull/317)
- Add farsi `fa` locale 🇮🇷🇦🇫[#316](https://github.com/wiredashio/wiredash-sdk/pull/316)
- Updated norwegian `no` locale 🇳🇴[#303](https://github.com/wiredashio/wiredash-sdk/pull/303)
- Fix issues with the animated backdrop [#314](https://github.com/wiredashio/wiredash-sdk/pull/314) [#315](https://github.com/wiredashio/wiredash-sdk/pull/315)

## 1.7.5
- Add norwegian `no` locale 🇳🇴 

## 1.7.4

- Localize discard confirm button in Promoter Score survey `feedbackDiscardConfirmButton` #299
- Localize button screenshot text on mobile `feedbackStep3ScreenshotBottomBarTitle` (new) #299
- Remove hit testing warnings in tests #300

## 1.7.3
- Update to Flutter 3.13 [#292](https://github.com/wiredashio/wiredash-sdk/pull/292)
- Update cirruslabs Flutter containers to always test against the latest Flutter versions

## 1.7.2
- [#285](https://github.com/wiredashio/wiredash-sdk/pull/285) Add Support danish (`da`) and arabic (`ar`)

## 1.7.1

- Widen dependency constraints of `http` and `file`

## 1.7.0

- [#278](https://github.com/wiredashio/wiredash-sdk/pull/278) Add Support for Flutter 3.10
- [#274](https://github.com/wiredashio/wiredash-sdk/pull/274) Raise min Flutter SDK to Flutter 3.0.0 / Dart 2.17
- [#268](https://github.com/wiredashio/wiredash-sdk/pull/268) Add czech locale `cs` 🇨🇿 @lukas-h
- [#275](https://github.com/wiredashio/wiredash-sdk/pull/275) Add german promoter score localizations 🇩🇪 @Dev-dfm
- [#272](https://github.com/wiredashio/wiredash-sdk/pull/272) Fix: Prefill email field from `collectMetadata` if available, when screenshot step is skipped
- [#276](https://github.com/wiredashio/wiredash-sdk/pull/276) Fix top padding on Android phones with notch.

## 1.6.0

- [#266](https://github.com/wiredashio/wiredash-sdk/pull/266) Support for Flutter `3.7`. Required for `go_router` users
- [#255](https://github.com/wiredashio/wiredash-sdk/pull/255) Add french locale `fr` 🇫🇷
- [#251](https://github.com/wiredashio/wiredash-sdk/pull/251) Add hungarian locale `hu` 🇭🇺

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
