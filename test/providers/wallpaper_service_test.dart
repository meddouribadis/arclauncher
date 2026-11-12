/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:io';
import 'dart:typed_data';

import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:path_provider_platform_interface/path_provider_platform_interface.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import '../mocks.mocks.dart';

MockSettingsService _createSettingsService({
  bool timeBasedWallpaperEnabled = false,
  bool unsplashSlideshowEnabled = false,
  int unsplashIntervalMinutes = 10,
  bool redditWallpaperEnabled = false,
  bool localSlideshowEnabled = false,
  String localSlideshowDirectory = '',
  int redditIntervalMinutes = 10,
  List<String> redditSubreddits = const ['wallpapers'],
  String redditSort = 'hot',
  String redditClientId = '',
  String redditClientSecret = '',
  String? redditCurrentTitle,
  String? redditCurrentAuthor,
  String? redditCurrentSubreddit,
}) {
  final s = MockSettingsService();
  when(s.timeBasedWallpaperEnabled).thenReturn(timeBasedWallpaperEnabled);
  when(s.unsplashSlideshowEnabled).thenReturn(unsplashSlideshowEnabled);
  when(s.unsplashIntervalMinutes).thenReturn(unsplashIntervalMinutes);
  when(s.redditWallpaperEnabled).thenReturn(redditWallpaperEnabled);
  when(s.localSlideshowEnabled).thenReturn(localSlideshowEnabled);
  when(s.localSlideshowDirectory).thenReturn(localSlideshowDirectory);
  when(s.redditIntervalMinutes).thenReturn(redditIntervalMinutes);
  when(s.redditSubreddits).thenReturn(redditSubreddits);
  when(s.redditSort).thenReturn(redditSort);
  when(s.redditClientId).thenReturn(redditClientId);
  when(s.redditClientSecret).thenReturn(redditClientSecret);
  when(s.redditCurrentTitle).thenReturn(redditCurrentTitle);
  when(s.redditCurrentAuthor).thenReturn(redditCurrentAuthor);
  when(s.redditCurrentSubreddit).thenReturn(redditCurrentSubreddit);
  return s;
}

void main() {
  late final _MockPathProviderPlatform pathProviderPlatform;
  setUpAll(() {
    pathProviderPlatform = _MockPathProviderPlatform();
    when(pathProviderPlatform.getApplicationDocumentsPath()).thenAnswer((_) => Future.value("."));
    PathProviderPlatform.instance = pathProviderPlatform;
  });

  test("pickWallpaper saves source file", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    final settingsService = _createSettingsService();
    final wallpaperService = WallpaperService(settingsService);
    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

    final source = File("test_wallpaper_src");
    await source.writeAsBytes([0x01, 0x02]);
    addTearDown(() async {
      if (await source.exists()) await source.delete();
      final dest = File("./wallpaper");
      if (await dest.exists()) await dest.delete();
    });

    await wallpaperService.pickWallpaper(source);

    expect(await File("./wallpaper").exists(), isTrue);
    expect(await File("./wallpaper").readAsBytes(), [0x01, 0x02]);
  });

  test("pickWallpaperFromUri saves the selected image bytes", () async {
    TestWidgetsFlutterBinding.ensureInitialized();
    const channel = MethodChannel('me.efesser.flauncher/method');
    final messenger = TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;
    messenger.setMockMethodCallHandler(channel, (call) async {
      if (call.method == 'loadContentUriImage') {
        return Uint8List.fromList([0x03, 0x04]);
      }
      return null;
    });
    addTearDown(() => messenger.setMockMethodCallHandler(channel, null));

    final settingsService = _createSettingsService();
    final wallpaperService = WallpaperService(settingsService);
    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
    addTearDown(() async {
      final dest = File('./wallpaper');
      if (await dest.exists()) await dest.delete();
    });

    await wallpaperService.pickWallpaperFromUri('content://media/external/images/media/1');

    expect(await File('./wallpaper').readAsBytes(), [0x03, 0x04]);
  });

  test("setGradient", () async {
    final settingsService = _createSettingsService();
    final wallpaperService = WallpaperService(settingsService);

    await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
    await wallpaperService.setGradient(FLauncherGradients.greatWhale);

    verify(settingsService.setGradientUuid(FLauncherGradients.greatWhale.uuid));
    expect(wallpaperService.wallpaper, null);
  });

  group("local folder slideshow", () {
    late Directory folder;
    setUp(() {
      folder = Directory.systemTemp.createTempSync("local_slideshow_test");
    });
    tearDown(() {
      if (folder.existsSync()) folder.deleteSync(recursive: true);
    });

    Future<WallpaperService> create({required bool enabled, String? path}) async {
      final service = WallpaperService(
        _createSettingsService(localSlideshowEnabled: enabled, localSlideshowDirectory: path ?? folder.path),
      );
      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
      await Future<void>.delayed(const Duration(milliseconds: 200));
      return service;
    }

    test("disabled: the folder is not read", () async {
      File("${folder.path}/a.jpg").writeAsBytesSync([1]);
      final service = await create(enabled: false, path: "${folder.path}/missing");
      await service.advanceLocalSlideshow();

      expect(service.localSlideshowStatus, LocalSlideshowStatus.ok);
      expect(service.wallpaper, isNull);
    });

    test("empty folder keeps the current wallpaper and reports it", () async {
      final current = File("./wallpaper")..writeAsBytesSync([1]);
      addTearDown(() => current.deleteSync());
      File("${folder.path}/notes.txt").writeAsStringSync("not an image");

      final service = await create(enabled: true);
      final before = service.wallpaper;

      expect(before, FileImage(current));
      expect(service.localSlideshowStatus, LocalSlideshowStatus.folderEmpty);
      expect(service.wallpaper, before);
    });

    test("unreadable folder keeps the current wallpaper and reports it", () async {
      final current = File("./wallpaper")..writeAsBytesSync([1]);
      addTearDown(() => current.deleteSync());

      final service = await create(enabled: true, path: "${folder.path}/missing");

      expect(service.localSlideshowStatus, LocalSlideshowStatus.folderUnreadable);
      expect(service.wallpaper, FileImage(current));
    });

    test("enabled: cycles through the images of the folder in name order", () async {
      final a = File("${folder.path}/a.jpg")..writeAsBytesSync([1]);
      final b = File("${folder.path}/b.PNG")..writeAsBytesSync([2]);
      File("${folder.path}/c.txt").writeAsStringSync("skip");

      final service = await create(enabled: true);
      expect(service.localSlideshowStatus, LocalSlideshowStatus.ok);
      expect(service.wallpaper, FileImage(a));

      await service.advanceLocalSlideshow();
      expect(service.wallpaper, FileImage(b));

      await service.advanceLocalSlideshow();
      expect(service.wallpaper, FileImage(a));
    });
  });

  group("getGradient", () {
    test("without uuid from settings", () async {
      final settingsService = _createSettingsService();
      final wallpaperService = WallpaperService(settingsService);
      when(settingsService.gradientUuid).thenReturn(null);

      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());
      final gradient = wallpaperService.gradient;

      expect(gradient, FLauncherGradients.saintPetersburg);
    });

    test("with uuid from settings", () async {
      final settingsService = _createSettingsService();
      final wallpaperService = WallpaperService(settingsService);
      when(settingsService.gradientUuid).thenReturn(FLauncherGradients.grassShampoo.uuid);
      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

      final gradient = wallpaperService.gradient;

      expect(gradient, FLauncherGradients.grassShampoo);
    });
  });

  group("reddit wallpaper", () {
    test("credit is null when disabled or file is missing", () async {
      final settingsService = _createSettingsService(
        redditWallpaperEnabled: false,
        redditCurrentSubreddit: 'wallpapers',
        redditCurrentAuthor: 'testuser',
      );
      final wallpaperService = WallpaperService(settingsService);
      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

      expect(wallpaperService.redditWallpaperCredit, isNull);
    });

    test("pickVideoWallpaper disables reddit wallpaper if enabled", () async {
      final settingsService = _createSettingsService(redditWallpaperEnabled: true);
      final wallpaperService = WallpaperService(settingsService);
      await untilCalled(pathProviderPlatform.getApplicationDocumentsPath());

      final video = File("test_video.mp4");
      await video.writeAsBytes([0x01]);
      addTearDown(() async {
        if (await video.exists()) await video.delete();
        final dest = File("./wallpaper_video");
        if (await dest.exists()) await dest.delete();
      });

      await wallpaperService.pickVideoWallpaper(video);

      verify(settingsService.setRedditWallpaperEnabled(false)).called(1);
    });
  });
}

class _MockPathProviderPlatform extends Mock with MockPlatformInterfaceMixin implements PathProviderPlatform {
  @override
  Future<String?> getApplicationDocumentsPath() =>
      super.noSuchMethod(Invocation.method(#getApplicationDocumentsPath, []), returnValue: Future<String?>.value());
}
