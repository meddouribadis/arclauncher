# Analysis of Issue #13

The issue reported in [#13](https://github.com/LeanBitLab/LtvLauncher/issues/13) states that Reproducible Build (RB) fails for the 3.2.2 release.

## Root Cause
The `v3.2.2` tag in the repository currently points to commit `58362cb`, where `pubspec.yaml` defines the version as `3.2.1+2100`. However, the APK distributed as version 3.2.2 was actually compiled from a later, different commit where the version was properly updated to `versionCode=6101` and `versionName=3.2.2`.

Because automated repositories like IzzyOnDroid and F-Droid fetch the source code using the release tags (e.g., `v3.2.2`) to perform their builds, they end up building from the older commit which produces an APK with version 3.2.1 instead of 3.2.2. This mismatch in `versionCode` and `versionName` causes the Reproducible Build checks to fail.

## Proposed Fix
Update the `version` attribute in `pubspec.yaml` to `3.2.2+6101` so that the version correctly aligns with the released APK, and then commit the changes so that the correct version information is present in the latest source code.

## Future Releases and Fastlane
For future releases, it is absolutely essential to follow the first basic rule of reproducible builds: **Always build release APKs from a clean tree at the commit the release tag points to. The two MUST match!**

Furthermore, when the `versionCode` in `pubspec.yaml` is incremented (e.g. from `4101` to `6101`), the changelog files in Fastlane must also be updated to match the new version code. This means renaming the corresponding changelog file (e.g. `fastlane/metadata/android/en-US/changelogs/4101.txt` to `6101.txt`) so that automation processes mapping changelogs to versions will successfully retrieve the correct release notes.
