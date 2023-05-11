# Release checklist

- run `pana --no-warning` and check score is 130/130
- Bump version in `pubspec.yaml`
- Increment `wiredashSdkVersion` in `lib/src/version.dart` by `1` for patch releases, by `10` for minor releases
- Make sure `prod` backend is used, not `dev` in `lib/src/core/network/wiredash_api.dart` (ending with `.io`, not `.dev`)
- Set `kDevMode` in `lib/src/_wiredash_internal.dart` to `false`
- Write release notes in `CHANGELOG.md` (Check https://github.com/wiredashio/wiredash-sdk/compare/v1.0.0...stable to compare what changed)
- Commit changes
- Tag release `vX.Y.Z` and push it
- Double check that there are no local changes, then run `git stash && flutter pub publish`
- Update/Move the `stable`, `beta` and `dev` branches (Run `./tool/update_branches.sh`)
- Copy paste release notes into github release
- Update wiredash-demo project for website
- Update latest SDK version in `console`
- Announce release on Twitter 🎉
