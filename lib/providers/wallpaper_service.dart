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
import 'dart:async';
import 'dart:typed_data';

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperService extends ChangeNotifier {
  final SettingsService _settingsService;
  final FLauncherChannel _channel = FLauncherChannel();

  late File _wallpaperFile;
  late File _wallpaperDayFile;
  late File _wallpaperNightFile;
  late File _wallpaperVideoFile;
  late File _wallpaperDayVideoFile;
  late File _wallpaperNightVideoFile;
  bool _initialized = false;
  Timer? _timer;
  int _wallpaperRevision = 0;

  ImageProvider? _wallpaper;
  int get wallpaperRevision => _wallpaperRevision;

  ImageProvider? get wallpaper => _wallpaper;

  File? get wallpaperVideoFile {
    final f = _resolveActiveVideoFile();
    return f != null && f.existsSync() ? f : null;
  }

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
    (gradient) => gradient.uuid == _settingsService.gradientUuid,
    orElse: () => FLauncherGradients.saintPetersburg,
  );

  WallpaperService(this._settingsService) : _wallpaper = null {
    _settingsService.addListener(_onSettingsChanged);
    _init();
  }

  bool _lastTimeBasedEnabled = false;

  void _onSettingsChanged() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled != _lastTimeBasedEnabled) {
      _lastTimeBasedEnabled = enabled;
      _updateTimerState();
      _updateWallpaper();
    }
  }

  @override
  void dispose() {
    _settingsService.removeListener(_onSettingsChanged);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _init() async {
    final directory = await getApplicationDocumentsDirectory();
    _wallpaperFile = File("${directory.path}/wallpaper");
    _wallpaperDayFile = File("${directory.path}/wallpaper_day");
    _wallpaperNightFile = File("${directory.path}/wallpaper_night");
    _wallpaperVideoFile = File("${directory.path}/wallpaper_video");
    _wallpaperDayVideoFile = File("${directory.path}/wallpaper_day_video");
    _wallpaperNightVideoFile = File("${directory.path}/wallpaper_night_video");
    _initialized = true;

    _lastTimeBasedEnabled = _settingsService.timeBasedWallpaperEnabled;
    _updateWallpaper();
    _updateTimerState();
  }

  void _updateTimerState() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(
        const Duration(minutes: 1),
        (_) => _updateWallpaper(),
      );
    } else if (!enabled && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  File? _resolveActiveVideoFile() {
    if (!isInitialized) return null;

    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    if (enabled) {
      if (isDay && _wallpaperDayVideoFile.existsSync()) {
        return _wallpaperDayVideoFile;
      }
      if (!isDay && _wallpaperNightVideoFile.existsSync()) {
        return _wallpaperNightVideoFile;
      }
      if (_wallpaperVideoFile.existsSync()) {
        return _wallpaperVideoFile;
      }
    } else if (_wallpaperVideoFile.existsSync()) {
      return _wallpaperVideoFile;
    }
    return null;
  }

  bool get isInitialized => _initialized;

  void _updateWallpaper({bool force = false}) {
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    final videoFile = _resolveActiveVideoFile();

    ImageProvider? newWallpaper;

    if (videoFile != null) {
      newWallpaper = null;
    } else if (enabled) {
      if (isDay && _wallpaperDayFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperDayFile);
      } else if (!isDay && _wallpaperNightFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperNightFile);
      } else if (_wallpaperFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperFile); // Fallback
      }
    } else if (_wallpaperFile.existsSync()) {
      newWallpaper = FileImage(_wallpaperFile);
    }

    if (_wallpaper != newWallpaper || videoFile != null || force) {
      _wallpaper = newWallpaper;
      _wallpaperRevision++;
      notifyListeners();
    }
  }

  Future<void> pickWallpaper(File sourceFile) async {
    await _saveImage(sourceFile, _wallpaperFile);
  }

  Future<void> pickWallpaperFromUri(String sourceUri) async {
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperFile,
    );
  }

  Future<void> pickWallpaperDay(File sourceFile) async {
    await _saveImage(sourceFile, _wallpaperDayFile);
  }

  Future<void> pickWallpaperDayFromUri(String sourceUri) async {
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperDayFile,
    );
  }

  Future<void> pickWallpaperNight(File sourceFile) async {
    await _saveImage(sourceFile, _wallpaperNightFile);
  }

  Future<void> pickWallpaperNightFromUri(String sourceUri) async {
    await _saveImageBytes(
      await _channel.loadContentUriImage(sourceUri),
      _wallpaperNightFile,
    );
  }

  Future<void> pickVideoWallpaper(File sourceFile) async {
    await _saveVideo(sourceFile, _wallpaperVideoFile);
  }

  Future<void> pickVideoWallpaperDay(File sourceFile) async {
    await _saveVideo(sourceFile, _wallpaperDayVideoFile);
  }

  Future<void> pickVideoWallpaperNight(File sourceFile) async {
    await _saveVideo(sourceFile, _wallpaperNightVideoFile);
  }

  Future<void> _saveImage(File sourceFile, File targetFile) async {
    await _replacePairedVideo(targetFile);

    final readStream = sourceFile.openRead();
    final writeStream = targetFile.openWrite();
    await readStream.cast<List<int>>().pipe(writeStream);

    await _refreshImageWallpaper(targetFile);
  }

  Future<void> _saveImageBytes(Uint8List imageBytes, File targetFile) async {
    if (imageBytes.isEmpty) {
      throw StateError('Unable to read the selected image');
    }

    await _replacePairedVideo(targetFile);
    await targetFile.writeAsBytes(imageBytes, flush: true);

    await _refreshImageWallpaper(targetFile);
  }

  Future<void> _replacePairedVideo(File targetFile) async {
    // Setting an image means the user no longer wants a video wallpaper, so
    // remove all video wallpaper files (including unrelated ones like the
    // general wallpaper_video when setting wallpaper_day) to prevent stale
    // video playback after switching.
    await cleanVideoWallpaperFiles();
  }

  Future<void> _refreshImageWallpaper(File targetFile) async {
    await FileImage(targetFile).evict();
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();

    _updateWallpaper(force: true);
  }

  Future<void> _saveVideo(File sourceFile, File targetVideoFile) async {
    final pairedImage = _pairedImageForVideo(targetVideoFile);
    if (pairedImage != null && await pairedImage.exists()) {
      await pairedImage.delete();
    }

    final readStream = sourceFile.openRead();
    final writeStream = targetVideoFile.openWrite();
    await readStream.cast<List<int>>().pipe(writeStream);

    _updateWallpaper(force: true);
  }

  File? _pairedImageForVideo(File videoFile) {
    if (videoFile.path == _wallpaperVideoFile.path) return _wallpaperFile;
    if (videoFile.path == _wallpaperDayVideoFile.path) return _wallpaperDayFile;
    if (videoFile.path == _wallpaperNightVideoFile.path)
      return _wallpaperNightFile;
    return null;
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    await cleanImageWallpaperFiles();
    await cleanVideoWallpaperFiles();

    await _settingsService.setGradientUuid(fLauncherGradient.uuid);
    // Drop the in-memory wallpaper provider so the gradient is shown instead of
    // the (now deleted) image/video file. _updateWallpaper notifies listeners.
    _updateWallpaper(force: true);
  }

  // Cleaning methods

  Future<void> cleanVideoWallpaperFiles() async {
    if (await _wallpaperVideoFile.exists()) {
      await _wallpaperVideoFile.delete();
    }

    if (await _wallpaperDayVideoFile.exists()) {
      await _wallpaperDayVideoFile.delete();
    }

    if (await _wallpaperNightVideoFile.exists()) {
      await _wallpaperNightVideoFile.delete();
    }
  }

  Future<void> cleanImageWallpaperFiles() async {
    if (await _wallpaperFile.exists()) {
      await _wallpaperFile.delete();
    }

    if (await _wallpaperDayFile.exists()) {
      await _wallpaperDayFile.delete();
    }

    if (await _wallpaperNightFile.exists()) {
      await _wallpaperNightFile.delete();
    }
  }
}
