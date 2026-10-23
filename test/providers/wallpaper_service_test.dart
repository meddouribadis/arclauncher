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
