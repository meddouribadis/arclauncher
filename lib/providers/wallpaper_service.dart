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

import 'package:flauncher/flauncher_channel.dart';
import 'package:flauncher/gradients.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class WallpaperService extends ChangeNotifier {
  final FLauncherChannel _fLauncherChannel;
  final SettingsService _settingsService;

  late File _wallpaperFile;
  late File _wallpaperDayFile;
  late File _wallpaperNightFile;
  late File _wallpaperVideoFile;
  late File _wallpaperDayVideoFile;
  late File _wallpaperNightVideoFile;
  Timer? _timer;

  ImageProvider? _wallpaper;

  ImageProvider? get wallpaper => _wallpaper;

  /// Bumps when wallpaper media is replaced so video layers rebuild.
  int _wallpaperGeneration = 0;
  int get wallpaperGeneration => _wallpaperGeneration;

  String? _lastVideoPath;

  File? get wallpaperVideoFile {
    final f = _resolveActiveVideoFile();
    return f != null && f.existsSync() ? f : null;
  }

  FLauncherGradient get gradient => FLauncherGradients.all.firstWhere(
        (gradient) => gradient.uuid == _settingsService.gradientUuid,
        orElse: () => FLauncherGradients.saintPetersburg,
      );

  WallpaperService(this._fLauncherChannel, this._settingsService) :
    _wallpaper = null
  {
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

    _lastTimeBasedEnabled = _settingsService.timeBasedWallpaperEnabled;
    _updateWallpaper();
    _updateTimerState();
  }

  void _updateTimerState() {
    final enabled = _settingsService.timeBasedWallpaperEnabled;
    if (enabled && (_timer == null || !_timer!.isActive)) {
      _timer = Timer.periodic(const Duration(minutes: 1), (_) => _updateWallpaper());
    } else if (!enabled && _timer != null) {
      _timer?.cancel();
      _timer = null;
    }
  }

  File? _resolveActiveVideoFile() {
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

  void _updateWallpaper({bool force = false}) {
    final now = DateTime.now();
    final isDay = now.hour >= 6 && now.hour < 18;
    final enabled = _settingsService.timeBasedWallpaperEnabled;

    final videoFile = _resolveActiveVideoFile();
    final newVideoPath = videoFile?.path;

    ImageProvider? newWallpaper;

    if (videoFile != null) {
      newWallpaper = null;
    } else if (enabled) {
      if (isDay && _wallpaperDayFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperDayFile);
      } else if (!isDay && _wallpaperNightFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperNightFile);
      } else if (_wallpaperFile.existsSync()) {
        newWallpaper = FileImage(_wallpaperFile);
      }
    } else if (_wallpaperFile.existsSync()) {
      newWallpaper = FileImage(_wallpaperFile);
    }

    if (_wallpaper != newWallpaper || _lastVideoPath != newVideoPath || force) {
      _wallpaper = newWallpaper;
      _lastVideoPath = newVideoPath;
      notifyListeners();
    }
  }

  Future<void> pickWallpaper() async {
    await _pickAndSaveImage(_wallpaperFile);
  }

  Future<void> pickWallpaperDay() async {
    await _pickAndSaveImage(_wallpaperDayFile);
  }

  Future<void> pickWallpaperNight() async {
    await _pickAndSaveImage(_wallpaperNightFile);
  }

  Future<void> pickVideoWallpaper() async {
    await _pickAndSaveVideo(_wallpaperVideoFile);
  }

  Future<void> pickVideoWallpaperDay() async {
    await _pickAndSaveVideo(_wallpaperDayVideoFile);
  }

  Future<void> pickVideoWallpaperNight() async {
    await _pickAndSaveVideo(_wallpaperNightVideoFile);
  }

  Future<void> _pickAndSaveImage(File targetFile) async {
    if (!await _fLauncherChannel.checkForGetContentAvailability()) {
      throw NoFileExplorerException();
    }

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      final pairedVideo = _pairedVideoForImage(targetFile);
      if (pairedVideo != null && await pairedVideo.exists()) {
        await pairedVideo.delete();
      }

      final readStream = pickedFile.openRead();
      final writeStream = targetFile.openWrite();
      await readStream.cast<List<int>>().pipe(writeStream);

      await FileImage(targetFile).evict();

      _wallpaperGeneration++;
      _updateWallpaper(force: true);
    }
  }

  Future<void> _pickAndSaveVideo(File targetVideoFile) async {
    if (!await _fLauncherChannel.checkForGetContentAvailability()) {
      throw NoFileExplorerException();
    }

    final imagePicker = ImagePicker();
    final pickedFile = await imagePicker.pickVideo(source: ImageSource.gallery);
    if (pickedFile != null) {
      final pairedImage = _pairedImageForVideo(targetVideoFile);
      if (pairedImage != null && await pairedImage.exists()) {
        await pairedImage.delete();
      }

      final readStream = pickedFile.openRead();
      final writeStream = targetVideoFile.openWrite();
      await readStream.cast<List<int>>().pipe(writeStream);

      _wallpaperGeneration++;
      _updateWallpaper(force: true);
    }
  }

  File? _pairedVideoForImage(File imageFile) {
    if (imageFile.path == _wallpaperFile.path) return _wallpaperVideoFile;
    if (imageFile.path == _wallpaperDayFile.path) return _wallpaperDayVideoFile;
    if (imageFile.path == _wallpaperNightFile.path) return _wallpaperNightVideoFile;
    return null;
  }

  File? _pairedImageForVideo(File videoFile) {
    if (videoFile.path == _wallpaperVideoFile.path) return _wallpaperFile;
    if (videoFile.path == _wallpaperDayVideoFile.path) return _wallpaperDayFile;
    if (videoFile.path == _wallpaperNightVideoFile.path) return _wallpaperNightFile;
    return null;
  }

  Future<void> setGradient(FLauncherGradient fLauncherGradient) async {
    for (final f in [
      _wallpaperFile,
      _wallpaperDayFile,
      _wallpaperNightFile,
      _wallpaperVideoFile,
      _wallpaperDayVideoFile,
      _wallpaperNightVideoFile,
    ]) {
      if (await f.exists()) {
        await f.delete();
      }
    }
    _wallpaperGeneration++;
    await _settingsService.setGradientUuid(fLauncherGradient.uuid);
    _wallpaper = null;
    _lastVideoPath = null;
    _updateWallpaper(force: true);
  }
}

class NoFileExplorerException implements Exception {}
