# Release checklist

- run `pana --no-warning` and check score is 130/130
- Bump version with `wiresdk bump-version --minor` (or `--major`, `--patch`) which does
  - Bump version in `pubspec.yaml`
  - Increment `wiredashSdkVersion` in `lib/src/version.dart` by `1` for patch releases, by `10` for minor releases
  - Update version in `README.md` 
- Write release notes in `CHANGELOG.md` (Check https://github.com/wiredashio/wiredash-sdk/compare/v1.0.0...stable to compare what changed)
- Commit changes
- Tag release `vX.Y.Z` and push it
- Double check that there are no local changes, then run `git stash && flutter pub publish`
- Update/Move the `stable`, `beta` and `dev` branches (Run `wiresdk sync-branches`)
- Copy-paste release notes into GitHub release https://github.com/wiredashio/wiredash-sdk/releases
- Update wiredash-demo project for website
- Update latest SDK version in `console`
- Announce release on Twitter 🎉
