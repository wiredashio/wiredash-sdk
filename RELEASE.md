# Release checklist

- run `pana` and check score is 120/120 (Actually 110/120 because "Support up-to-date dependencies" fails locally)
- Bump version in `pubspec.yaml`
- Increment `wiredashSdkVersion` in `lib/src/version.dart` by `1` for patch releases, by `10` for minor releases
- Make sure `prod` backend is used, not `dev` in `lib/src/core/network/wiredash_api.dart` (ending with `.io`, not `.dev`)
- Set `kDevMode` in `lib/src/_wiredash_internal.dart` to `false`
- Write release notes in `CHANGELOG.md`
- Commit changes
- Tag release `vX.Y.Z` and push it
- Double check that there are no local changes, then run `git stash && flutter pub publish`
- Update/Move the `stable`, `beta` and `dev` branches (Run `./tool/update_branches.sh`)
- Copy paste release notes into github release
- Update latest SDK version in `console`
- Announce release on Twitter 🎉
