import 'package:arclauncher/providers/update_service.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group("isAbiSplitApk", () {
    test("detects ABI-split release assets", () {
      expect(isAbiSplitApk("arclauncher-1.0.5-arm64-v8a.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-armeabi-v7a.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-x86_64.apk"), isTrue);
      expect(isAbiSplitApk("arclauncher-1.0.5-x86.apk"), isTrue);
    });

    test("treats universal assets as non-split", () {
      expect(isAbiSplitApk("arclauncher-1.0.5.apk"), isFalse);
      expect(isAbiSplitApk("arclauncher.apk"), isFalse);
      expect(isAbiSplitApk("arc-launcher-universal-release.apk"), isFalse);
    });
  });

  group("pickReleaseApk", () {
    const assets = [
      {
        "name": "arclauncher-1.0.5-arm64-v8a.apk",
        "browser_download_url": "https://example.com/arm64.apk",
      },
      {
        "name": "arclauncher-1.0.5-armeabi-v7a.apk",
        "browser_download_url": "https://example.com/armeabi.apk",
      },
      {
        "name": "arclauncher-1.0.5.apk",
        "browser_download_url": "https://example.com/universal.apk",
      },
      {
        "name": "arclauncher.apk",
        "browser_download_url": "https://example.com/alias.apk",
      },
    ];

    test("prefers the device ABI split when known", () {
      final picked = pickReleaseApk(assets, deviceAbi: "armeabi-v7a");

      expect(picked?.name, "arclauncher-1.0.5-armeabi-v7a.apk");
      expect(picked?.url, "https://example.com/armeabi.apk");
    });

    test("falls back to universal when the device ABI is missing", () {
      final picked = pickReleaseApk(assets, deviceAbi: "mips");

      expect(picked?.name, "arclauncher-1.0.5.apk");
      expect(picked?.url, "https://example.com/universal.apk");
    });

    // Without a device ABI (e.g. unit tests, missing channel), keep preferring
    // the version-stamped universal over splits and the stable alias.
    test("prefers the version-stamped universal when ABI is unknown", () {
      final picked = pickReleaseApk(assets);

      expect(picked?.name, "arclauncher-1.0.5.apk");
      expect(picked?.url, "https://example.com/universal.apk");
    });

    test("still resolves a valid universal if the alias sorts first", () {
      final picked = pickReleaseApk([
        {
          "name": "arclauncher.apk",
          "browser_download_url": "https://example.com/alias.apk",
        },
        {
          "name": "arclauncher-1.0.10-arm64-v8a.apk",
          "browser_download_url": "https://example.com/arm64.apk",
        },
        {
          "name": "arclauncher-1.0.10.apk",
          "browser_download_url": "https://example.com/versioned.apk",
        },
      ]);

      expect(picked?.name, "arclauncher.apk");
      expect(isAbiSplitApk(picked!.name), isFalse);
    });

    test("falls back to first APK when no universal exists", () {
      final picked = pickReleaseApk([
        {
          "name": "arclauncher-1.0.5-arm64-v8a.apk",
          "browser_download_url": "https://example.com/arm64.apk",
        },
        {
          "name": "arclauncher-1.0.5-armeabi-v7a.apk",
          "browser_download_url": "https://example.com/armeabi.apk",
        },
      ]);

      expect(picked?.name, "arclauncher-1.0.5-arm64-v8a.apk");
    });
  });

  group("cleanReleaseNotes", () {
    test("returns null for null or whitespace", () {
      expect(cleanReleaseNotes(null), isNull);
      expect(cleanReleaseNotes("   \n\n  "), isNull);
    });

    test("strips VirusTotal report section and comments", () {
      const raw = """
## What's Changed
* Feature A
* Feature B

<!-- virustotal-report -->
## VirusTotal Analysis
| Variant | Status |
| arm64 | Clean |
""";
      final cleaned = cleanReleaseNotes(raw);
      expect(cleaned, contains("* Feature A"));
      expect(cleaned, contains("* Feature B"));
      expect(cleaned, isNot(contains("virustotal")));
      expect(cleaned, isNot(contains("VirusTotal")));
      expect(cleaned, isNot(contains("Clean")));
    });

    test("strips Full Changelog links and simplifies PR/issue URLs", () {
      const raw = """
Arc Launcher v1.0.10

## What's Changed
* Fix crashing on startup by @dev in https://github.com/meddouribadis/arclauncher/pull/43
* Fix icon rendering — https://github.com/meddouribadis/arclauncher/issues/42

**Full Changelog**: https://github.com/meddouribadis/arclauncher/compare/1.0.9...1.0.10
""";
      final cleaned = cleanReleaseNotes(raw);
      expect(cleaned, contains("by @dev (#43)"));
      expect(cleaned, contains("Fix icon rendering — #42"));
      expect(cleaned, isNot(contains("Full Changelog")));
      expect(cleaned, isNot(contains("https://github.com")));
    });
  });
}
