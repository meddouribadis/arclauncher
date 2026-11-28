/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
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

import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:screen_brightness/screen_brightness.dart';
import 'package:shared_preferences/shared_preferences.dart';

// Time slot keys for storage
const _brightnessEnabled = "brightness_scheduler_enabled";
const _brightnessMorning = "brightness_morning";     // 6am - 9am
const _brightnessDay = "brightness_day";             // 9am - 3pm
const _brightnessAfternoon = "brightness_afternoon"; // 3pm - 6pm
const _brightnessEvening = "brightness_evening";     // 6pm - 10pm
const _brightnessNight = "brightness_night";         // 10pm - 6am

/// Time slot definitions
enum TimeSlot {
  morning,     // 6am - 9am
  day,         // 9am - 3pm
  afternoon,   // 3pm - 6pm
  evening,     // 6pm - 10pm
  night,       // 10pm - 6am
}

extension TimeSlotExtension on TimeSlot {
  String get label {
    switch (this) {
      case TimeSlot.morning:
        return '6 AM - 9 AM';
      case TimeSlot.day:
        return '9 AM - 3 PM';
      case TimeSlot.afternoon:
        return '3 PM - 6 PM';
      case TimeSlot.evening:
        return '6 PM - 10 PM';
      case TimeSlot.night:
        return '10 PM - 6 AM';
    }
  }

  int get defaultBrightness {
    switch (this) {
      case TimeSlot.morning:
        return 60;
      case TimeSlot.day:
        return 100;
      case TimeSlot.afternoon:
        return 80;
      case TimeSlot.evening:
        return 50;
      case TimeSlot.night:
        return 20;
    }
  }
}

class BrightnessService extends ChangeNotifier {
  static const _platform = MethodChannel('me.efesser.flauncher/method');
  final SharedPreferences _sharedPreferences;
  Timer? _timer;

  bool _hasPermission = true;
  bool get hasPermission => _hasPermission;

  BrightnessService(this._sharedPreferences) {
    checkPermission();
    // Start the scheduler if enabled
    if (isEnabled) {
      _startScheduler();
    }
  }

  Future<void> checkPermission() async {
    try {
      final bool result = await _platform.invokeMethod('checkWriteSettingsPermission');
      _hasPermission = result;
    } catch (e) {
      debugPrint('Error checking brightness permission: $e');
      _hasPermission = true; // Fallback
    }
    notifyListeners();
  }

  Future<void> requestPermission() async {
    try {
      await _platform.invokeMethod('requestWriteSettingsPermission');
    } catch (e) {
      debugPrint('Error requesting brightness permission: $e');
    }
  }

  bool get isEnabled => _sharedPreferences.getBool(_brightnessEnabled) ?? false;

  int getBrightnessForSlot(TimeSlot slot) {
    switch (slot) {
      case TimeSlot.morning:
        return _sharedPreferences.getInt(_brightnessMorning) ?? slot.defaultBrightness;
      case TimeSlot.day:
        return _sharedPreferences.getInt(_brightnessDay) ?? slot.defaultBrightness;
      case TimeSlot.afternoon:
        return _sharedPreferences.getInt(_brightnessAfternoon) ?? slot.defaultBrightness;
      case TimeSlot.evening:
        return _sharedPreferences.getInt(_brightnessEvening) ?? slot.defaultBrightness;
      case TimeSlot.night:
        return _sharedPreferences.getInt(_brightnessNight) ?? slot.defaultBrightness;
    }
  }

  Future<void> setBrightnessForSlot(TimeSlot slot, int brightness) async {
    String key;
    switch (slot) {
      case TimeSlot.morning:
        key = _brightnessMorning;
        break;
      case TimeSlot.day:
        key = _brightnessDay;
        break;
      case TimeSlot.afternoon:
        key = _brightnessAfternoon;
        break;
      case TimeSlot.evening:
        key = _brightnessEvening;
        break;
      case TimeSlot.night:
        key = _brightnessNight;
        break;
    }
    await _sharedPreferences.setInt(key, brightness);
    notifyListeners();
    
    // Apply immediately if this is the current slot and scheduler is enabled
    if (isEnabled && getCurrentTimeSlot() == slot) {
      await _applyBrightness(brightness);
    }
  }

  Future<void> setEnabled(bool enabled) async {
    await _sharedPreferences.setBool(_brightnessEnabled, enabled);
    
    if (enabled) {
      _startScheduler();
      // Apply brightness for current time slot immediately
      await applyCurrentSlotBrightness();
    } else {
      _stopScheduler();
      // Reset to system brightness
      try {
        await ScreenBrightness().resetApplicationScreenBrightness();
      } catch (e) {
        debugPrint('Error resetting brightness: $e');
      }
    }
    
    notifyListeners();
  }

  TimeSlot getCurrentTimeSlot() {
    final now = DateTime.now();
    final hour = now.hour;

    if (hour >= 6 && hour < 9) {
      return TimeSlot.morning;
    } else if (hour >= 9 && hour < 15) {
      return TimeSlot.day;
    } else if (hour >= 15 && hour < 18) {
      return TimeSlot.afternoon;
    } else if (hour >= 18 && hour < 22) {
      return TimeSlot.evening;
    } else {
      return TimeSlot.night;
    }
  }

  Future<void> applyCurrentSlotBrightness() async {
    if (!isEnabled) return;
    
    final currentSlot = getCurrentTimeSlot();
    final brightness = getBrightnessForSlot(currentSlot);
    await _applyBrightness(brightness);
  }

  Future<void> _applyBrightness(int brightnessPct) async {
    try {
      // 1. Try system-wide brightness first (needs WRITE_SETTINGS)
      final int brightnessValue255 = ((brightnessPct / 100.0) * 255).round();
      final bool success = await _platform.invokeMethod('setSystemBrightness', {'brightness': brightnessValue255});
      
      if (!success) {
        // 2. Fallback to app-level brightness
        final brightnessValue = brightnessPct / 100.0;
        await ScreenBrightness().setApplicationScreenBrightness(brightnessValue);
      }
    } catch (e) {
      debugPrint('Error setting brightness ($brightnessPct%): $e');
    }
  }

  void _startScheduler() {
    _stopScheduler();
    // Check every minute
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      applyCurrentSlotBrightness();
    });
  }

  void _stopScheduler() {
    _timer?.cancel();
    _timer = null;
  }

  Future<double> getCurrentBrightness() async {
    try {
      return await ScreenBrightness().application;
    } catch (e) {
      return 1.0;
    }
  }

  @override
  void dispose() {
    _stopScheduler();
    super.dispose();
  }
}
