## [0.2.0] - Internationalization support

We added initial internationalization support for several languages

* Added `WiredashLocalizations`
* Added ability to provide custom `WiredashTranslations`

## [0.1.1] - Build information ⚙️ in the feedback
You can pass additional build information (number and commit) that will be visible when user submits the feedback.

* Added buildNumber, buildVersion and buildCommit properties that can be passed through dart-define
* Constrained the SDK to 2.8.0 or newer and Flutter to 1.17.0 or newer
* Deprecated method `setIdentifiers` in favor of `setUserProperties` and `setBuildProperties`

## [0.1.0] - Floating Entry 📲, Confidential 👀 & Provider 🏗
Wiredash now uses the Provider package for internal state management and supports version 3.0.0 and higher. If you are
also using Provider in your app, please make sure to at least use version 3.0.0.

* Added a Floating Entry which is shown by default in debug to show Wiredash from any screen
* Added WiredashOptions to further customize the Wiredash widget (e.g. the Floating Entry)
* Added a Confidential widget to automatically hide sensitive widgets during screen capture
* Added a Wiredash.of(context).visible ValueListener to check if Wiredash is in screen capture mode (e.g. for hiding certain widgets being screen captured)
* Improved error handling when there is no valid root navigator key
* Improved performance
* Minor bug fixes

## [0.0.1] - Public Release

* Wiredash gets released to the public 🎉
