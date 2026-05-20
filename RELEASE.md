# Release checklist

- run `pana --no-warning` and check the pub score is at maximum
- Bump version with `wiresdk bump-version --minor` (or `--major`, `--patch`) which does
  - Bump version in `pubspec.yaml`
  - Increment `wiredashSdkVersion` in `lib/src/version.dart` by `1` for patch releases, by `10` for minor releases
  - Update version in `README.md`
- Write release notes in `CHANGELOG.md` (Check <https://github.com/wiredashio/wiredash-sdk/compare/v1.0.0...stable> to compare what changed)
- Commit changes
- Tag release `vX.Y.Z` and push it
- Double check that there are no local changes, then run `git stash && flutter pub publish`
- Update/Move the `stable`, `beta` and `dev` branches (Run `wiresdk sync-branches`)
- Copy-paste release notes into GitHub release <https://github.com/wiredashio/wiredash-sdk/releases>
- Update wiredash-demo project for website
- Update latest SDK version in `console`
- Announce release on Twitter 🎉

## Handling deprecations of the Flutter SDK and dependencies

The Wiredash SDK strives to be compatible with all `stable` [Flutter releases](https://docs.flutter.dev/release/archive) within the last year as well as the current `master` channel.
To achieve this, we go the extra mile and work around breaking API changes or contribute fixes directly to the Flutter SDK to ensure compatibility.

The goal is to always have a single commit, being compatible with all versions.
This way we can make sure to deliver the latest features and bug fixes to all of our users.

These are the current deprecated APIs the Wiredash SDK is currently using as long as the deprecated APIs are not removed (usually after 12 months).

### Flutter 3.29 / Dart 3.7.0 (12.02.2025)

- `dart:html`, `dart:js_util` and `dart:js` are now deprecated <https://github.com/dart-lang/sdk/issues/59716>
- New `WidgetInspector` constructor <https://github.com/flutter/flutter/pull/158219>

### Flutter 3.27 / Dart 3.6.0 (11.12.2024)

Multiple `Color` API changes:

- <https://docs.flutter.dev/release/breaking-changes/wide-gamut-framework>
- <https://github.com/flutter/engine/pull/54737>

- `Color.alpha` -> `Color.a`
- `Color.red` -> `Color.r`
- `Color.green` -> `Color.g`
- `Color.blue` -> `Color.b`
- `Color.withOpacity()` -> `Color.withValues()`
- `Color.value` -> ?

### Flutter 3.10 / Dart 3.0.0 (10.05.2023)

- `Iterable<T?>.whereNotNull()` -> `Iterable<T>.nonNulls` (Caused by pinned [`collection: 1.19.0`](https://pub.dev/packages/collection/changelog#1190) package)
- `MediaQuery.fromWindow` -> `MediaQuery.fromView` (deprecated in Flutter v3.7.0-32.0.pre) <https://github.com/flutter/flutter/pull/119647>
