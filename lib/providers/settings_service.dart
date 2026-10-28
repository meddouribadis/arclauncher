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

import 'dart:async';

import 'package:flauncher/providers/reddit_slideshow.dart';
import 'package:flauncher/providers/unsplash_slideshow.dart';
import 'package:flauncher/widgets/settings/back_button_actions.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

const _appHighlightAnimationEnabledKey = "app_highlight_animation_enabled";
const _appKeyClickEnabledKey = "app_key_click_enabled";
const _autoHideAppBar = "auto_hide_app_bar";
const _hideStatusBarInGrid = "hide_status_bar_in_grid";
const _gradientUuidKey = "gradient_uuid";
const _backButtonAction = "back_button_action";
const _dateFormat = "date_format";
const _showCategoryTitles = "show_category_titles";
const _showAppNamesBelowIcons = "show_app_names_below_icons";
const _showDateInStatusBar = "show_date_in_status_bar";
const _showTimeInStatusBar = "show_time_in_status_bar";
const _timeFormat = "time_format";
const _wifiUsagePeriod = "wifi_usage_period";
const _showWifiWidgetInStatusBar = "show_wifi_widget_in_status_bar";
const String _showNetworkIndicatorInStatusBar = "show_network_indicator_in_status_bar";
const String _accentColor = "accent_color";
const String _screensaverClockStyle = "screensaver_clock_style";
const String _dockBackdropFilterDisabled = "dock_backdrop_filter_disabled";
const String _backgroundBlurDisabled = "background_blur_disabled";
const String _showWatchNextSection = "show_watch_next_section";
const String _watchNextBigPictureMode = "watch_next_big_picture_mode";
const String _watchNextHideProgramsWithoutImages = "watch_next_hide_programs_without_images";
const String _watchNextMaxItems = "watch_next_max_items";
const String _watchNextExcludedPackages = "watch_next_excluded_packages";

const String defaultLocalSlideshowDirectory = "/sdcard/Pictures";

const List<int> WATCH_NEXT_MAX_ITEMS_OPTIONS = [0, 5, 10, 15, 20, 25, 30, 50];
const String _dockDarkBackground = "dock_dark_background";
const String _dockShadowEnabled = "dock_shadow_enabled";
const String _showFocusBorders = "show_focus_borders";
const String _focusBorderThickness = "focus_border_thickness";

// Focus border thickness options (in dp)
const double FOCUS_BORDER_THIN = 1.0;
const double FOCUS_BORDER_DEFAULT = 1.5;
const double FOCUS_BORDER_MEDIUM = 2.0;
const double FOCUS_BORDER_BOLD = 3.0;

const List<double> FOCUS_BORDER_THICKNESS_OPTIONS = [
  FOCUS_BORDER_THIN,
  FOCUS_BORDER_DEFAULT,
  FOCUS_BORDER_MEDIUM,
  FOCUS_BORDER_BOLD,
];

// WiFi usage period options
const String WIFI_USAGE_DAILY = "daily";
const String WIFI_USAGE_WEEKLY = "weekly";
const String WIFI_USAGE_MONTHLY = "monthly";

// Accent color presets (hex values)
const String ACCENT_COLOR_PURPLE = "7C4DFF";
const String ACCENT_COLOR_TEAL = "00BFA5";
const String ACCENT_COLOR_BLUE = "2979FF";
const String ACCENT_COLOR_ORANGE = "FF6D00";
const String ACCENT_COLOR_PINK = "F50057";
const String ACCENT_COLOR_GREEN = "00C853";
const String ACCENT_COLOR_WHITE = "FFFFFF";
const String ACCENT_COLOR_YELLOW = "FFD600";
const String ACCENT_COLOR_RED = "D50000";
const String ACCENT_COLOR_CYAN = "00E5FF";
const String ACCENT_COLOR_INDIGO = "536DFE";
const String ACCENT_COLOR_LIME = "AEEA00";
const String ACCENT_COLOR_AMBER = "FFAB00";
const String ACCENT_COLOR_ROSE = "FF4081";
const String ACCENT_COLOR_ICE_BLUE = "80D8FF";

class SettingsService extends ChangeNotifier {
  static final defaultDateFormat = "EEEE d";
  static final defaultTimeFormat = "H:mm";
  final SharedPreferences _sharedPreferences;

  bool get appHighlightAnimationEnabled =>
      showFocusBorders && (_sharedPreferences.getBool(_appHighlightAnimationEnabledKey) ?? false);

  bool get appKeyClickEnabled => _sharedPreferences.getBool(_appKeyClickEnabledKey) ?? true;

  bool get autoHideAppBarEnabled => _sharedPreferences.getBool(_autoHideAppBar) ?? false;

  bool get hideStatusBarInGrid => _sharedPreferences.getBool(_hideStatusBarInGrid) ?? false;

  bool get showCategoryTitles => _sharedPreferences.getBool(_showCategoryTitles) ?? false;

  bool get showAppNamesBelowIcons => _sharedPreferences.getBool(_showAppNamesBelowIcons) ?? false;

  bool get showDateInStatusBar => _sharedPreferences.getBool(_showDateInStatusBar) ?? false;

  bool get showTimeInStatusBar => _sharedPreferences.getBool(_showTimeInStatusBar) ?? true;

  String? get gradientUuid => _sharedPreferences.getString(_gradientUuidKey);

  String get backButtonAction => _sharedPreferences.getString(_backButtonAction) ?? BACK_BUTTON_ACTION_NOTHING;

  String get dateFormat => _sharedPreferences.getString(_dateFormat) ?? defaultDateFormat;

  String get timeFormat => _sharedPreferences.getString(_timeFormat) ?? defaultTimeFormat;

  String get wifiUsagePeriod => _sharedPreferences.getString(_wifiUsagePeriod) ?? WIFI_USAGE_DAILY;

  bool get showWifiWidgetInStatusBar => _sharedPreferences.getBool(_showWifiWidgetInStatusBar) ?? false;

  bool get showNetworkIndicatorInStatusBar => _sharedPreferences.getBool(_showNetworkIndicatorInStatusBar) ?? true;

  String get accentColorHex => _sharedPreferences.getString(_accentColor) ?? ACCENT_COLOR_WHITE;

  String get screensaverClockStyle => _sharedPreferences.getString(_screensaverClockStyle) ?? "minimal";

  bool get dockBackdropFilterDisabled => _sharedPreferences.getBool(_dockBackdropFilterDisabled) ?? false;

  bool get backgroundBlurDisabled => _sharedPreferences.getBool(_backgroundBlurDisabled) ?? false;

  bool get showWatchNextSection => _sharedPreferences.getBool(_showWatchNextSection) ?? false;

  bool get watchNextBigPictureMode => _sharedPreferences.getBool(_watchNextBigPictureMode) ?? false;

  bool get watchNextHideProgramsWithoutImages =>
      _sharedPreferences.getBool(_watchNextHideProgramsWithoutImages) ?? false;

  int get watchNextMaxItems => _sharedPreferences.getInt(_watchNextMaxItems) ?? 0;

  bool get dockDarkBackground => _sharedPreferences.getBool(_dockDarkBackground) ?? false;

  bool get dockShadowEnabled => _sharedPreferences.getBool(_dockShadowEnabled) ?? false;

  bool get showFocusBorders => _sharedPreferences.getBool(_showFocusBorders) ?? true;

  double get focusBorderThickness => _sharedPreferences.getDouble(_focusBorderThickness) ?? FOCUS_BORDER_DEFAULT;

  Future<void> setFocusBorderThickness(double value) async {
    await _sharedPreferences.setDouble(_focusBorderThickness, value);
    notifyListeners();
  }

  Color get accentColor {
    final hex = accentColorHex;
    return Color(int.parse("0xFF$hex"));
  }

  SettingsService(this._sharedPreferences);

  Future<void> set(String key, bool value) async {
    await _sharedPreferences.setBool(key, value);
    notifyListeners();
  }

  Future<void> setAppHighlightAnimationEnabled(bool value) async {
    if (value && !showFocusBorders) {
      return;
    }
    return set(_appHighlightAnimationEnabledKey, value);
  }

  Future<void> setAppKeyClickEnabled(bool value) async {
    return set(_appKeyClickEnabledKey, value);
  }

  Future<void> setAutoHideAppBarEnabled(bool value) async {
    return set(_autoHideAppBar, value);
  }

  Future<void> setHideStatusBarInGrid(bool value) async {
    return set(_hideStatusBarInGrid, value);
  }

  Future<void> setGradientUuid(String value) async {
    await _sharedPreferences.setString(_gradientUuidKey, value);
    notifyListeners();
  }

  Future<void> setBackButtonAction(String value) async {
    await _sharedPreferences.setString(_backButtonAction, value);
    notifyListeners();
  }

  Future<void> setDateTimeFormat(String dateFormatString, String timeFormatString) async {
    await Future.wait([
      _sharedPreferences.setString(_dateFormat, dateFormatString),
      _sharedPreferences.setString(_timeFormat, timeFormatString),
    ]);
    notifyListeners();
  }

  Future<void> setShowCategoryTitles(bool show) async {
    return set(_showCategoryTitles, show);
  }

  Future<void> setShowAppNamesBelowIcons(bool show) async {
    return set(_showAppNamesBelowIcons, show);
  }

  Future<void> setShowDateInStatusBar(bool show) async {
    return set(_showDateInStatusBar, show);
  }

  Future<void> setShowTimeInStatusBar(bool show) async {
    return set(_showTimeInStatusBar, show);
  }

  Future<void> setWifiUsagePeriod(String period) async {
    await _sharedPreferences.setString(_wifiUsagePeriod, period);
    notifyListeners();
  }

  Future<void> setShowWifiWidgetInStatusBar(bool show) async {
    return set(_showWifiWidgetInStatusBar, show);
  }

  Future<void> setShowNetworkIndicatorInStatusBar(bool show) async {
    return set(_showNetworkIndicatorInStatusBar, show);
  }

  Future<void> setAccentColor(String colorHex) async {
    await _sharedPreferences.setString(_accentColor, colorHex);
    notifyListeners();
  }

  Future<void> setScreensaverClockStyle(String style) async {
    await _sharedPreferences.setString(_screensaverClockStyle, style);
    notifyListeners();
  }

  Future<void> setDockBackdropFilterDisabled(bool value) async {
    return set(_dockBackdropFilterDisabled, value);
  }

  Future<void> setBackgroundBlurDisabled(bool value) async {
    return set(_backgroundBlurDisabled, value);
  }

  Future<void> setShowWatchNextSection(bool value) async {
    return set(_showWatchNextSection, value);
  }

  Future<void> setWatchNextBigPictureMode(bool value) async {
    return set(_watchNextBigPictureMode, value);
  }

  Future<void> setWatchNextHideProgramsWithoutImages(bool value) async {
    return set(_watchNextHideProgramsWithoutImages, value);
  }

  Future<void> setWatchNextMaxItems(int value) async {
    await _sharedPreferences.setInt(_watchNextMaxItems, value);
    notifyListeners();
  }

  List<String> get watchNextExcludedPackages =>
      _sharedPreferences.getStringList(_watchNextExcludedPackages) ?? const [];

  Future<void> setWatchNextExcludedPackages(List<String> packages) async {
    await _sharedPreferences.setStringList(_watchNextExcludedPackages, packages);
    notifyListeners();
  }

  Future<void> toggleWatchNextExcludedPackage(String packageName) async {
    final current = List<String>.from(watchNextExcludedPackages);
    if (current.contains(packageName)) {
      current.remove(packageName);
    } else {
      current.add(packageName);
    }
    await setWatchNextExcludedPackages(current);
  }

  bool isWatchNextPackageExcluded(String packageName) =>
      watchNextExcludedPackages.contains(packageName);

  Future<void> setDockDarkBackground(bool value) async {
    return set(_dockDarkBackground, value);
  }

  Future<void> setDockShadowEnabled(bool value) async {
    return set(_dockShadowEnabled, value);
  }

  Future<void> setShowFocusBorders(bool value) async {
    await set(_showFocusBorders, value);
    if (!value) {
      await setAppHighlightAnimationEnabled(false);
    }
  }

  bool get timeBasedWallpaperEnabled => _sharedPreferences.getBool("time_based_wallpaper_enabled") ?? false;

  Future<void> setTimeBasedWallpaperEnabled(bool enabled) async {
    await _sharedPreferences.setBool("time_based_wallpaper_enabled", enabled);
    notifyListeners();
  }

  /// Each user brings their own Unsplash API access key (Demo apps are limited to 50 requests/hour).
  String get unsplashAccessKey => _sharedPreferences.getString("unsplash_access_key") ?? "";

  Future<void> setUnsplashAccessKey(String key) async {
    await _sharedPreferences.setString("unsplash_access_key", key.trim());
    if (key.trim().isEmpty) {
      await _sharedPreferences.setBool("unsplash_slideshow_enabled", false);
    }
    notifyListeners();
  }

  /// The slideshow only runs with an access key.
  bool get unsplashSlideshowEnabled =>
      unsplashAccessKey.isNotEmpty && (_sharedPreferences.getBool("unsplash_slideshow_enabled") ?? false);

  static const List<int> unsplashIntervalChoices = [5, 10, 30, 60];

  int get unsplashIntervalMinutes => _sharedPreferences.getInt("unsplash_interval_minutes") ?? 10;

  Future<void> setUnsplashIntervalMinutes(int minutes) async {
    await _sharedPreferences.setInt("unsplash_interval_minutes", minutes);
    notifyListeners();
  }

  /// Slideshow sources: search keywords, "topics:ID,ID" or "collections:ID,ID".
  /// Slideshow category keys (see slideshowSources) used from 6h to 18h, and the rest of the time.
  List<String> get unsplashDaySources =>
      _sharedPreferences.getStringList("unsplash_day_sources") ?? defaultDaySlideshowSources;

  List<String> get unsplashNightSources =>
      _sharedPreferences.getStringList("unsplash_night_sources") ?? defaultNightSlideshowSources;

  Future<void> setUnsplashSources({required bool day, required List<String> keys}) async {
    await _sharedPreferences.setStringList(day ? "unsplash_day_sources" : "unsplash_night_sources", keys);
    notifyListeners();
  }

  Future<void> setUnsplashSlideshowEnabled(bool enabled) async {
    await _sharedPreferences.setBool("unsplash_slideshow_enabled", enabled);
    if (enabled) {
      await _sharedPreferences.setBool("reddit_wallpaper_enabled", false);
      await _sharedPreferences.setBool("local_slideshow_enabled", false);
    }
    notifyListeners();
  }

  // Local folder slideshow

  /// Off by default. Shares the interval with the Unsplash slideshow.
  bool get localSlideshowEnabled => _sharedPreferences.getBool("local_slideshow_enabled") ?? false;

  String get localSlideshowDirectory =>
      _sharedPreferences.getString("local_slideshow_directory") ?? defaultLocalSlideshowDirectory;

  Future<void> setLocalSlideshowEnabled(bool enabled) async {
    await _sharedPreferences.setBool("local_slideshow_enabled", enabled);
    if (enabled) {
      await _sharedPreferences.setBool("unsplash_slideshow_enabled", false);
      await _sharedPreferences.setBool("reddit_wallpaper_enabled", false);
    }
    notifyListeners();
  }

  Future<void> setLocalSlideshowDirectory(String directory) async {
    await _sharedPreferences.setString("local_slideshow_directory", directory.trim());
    notifyListeners();
  }

  /// Photographer of the slideshow image on screen, kept across restarts for attribution.
  String? get unsplashAuthor => _sharedPreferences.getString("unsplash_author");

  Future<void> setUnsplashAuthor(String author) => _sharedPreferences.setString("unsplash_author", author);

  // Reddit Wallpaper Settings

  bool get redditWallpaperEnabled => _sharedPreferences.getBool("reddit_wallpaper_enabled") ?? false;

  Future<void> setRedditWallpaperEnabled(bool enabled) async {
    await _sharedPreferences.setBool("reddit_wallpaper_enabled", enabled);
    if (enabled) {
      await _sharedPreferences.setBool("unsplash_slideshow_enabled", false);
      await _sharedPreferences.setBool("local_slideshow_enabled", false);
    }
    notifyListeners();
  }

  static const List<int> redditIntervalChoices = [5, 10, 30, 60, 360, 720, 1440];

  int get redditIntervalMinutes => _sharedPreferences.getInt("reddit_interval_minutes") ?? 10;

  Future<void> setRedditIntervalMinutes(int minutes) async {
    await _sharedPreferences.setInt("reddit_interval_minutes", minutes);
    notifyListeners();
  }

  List<String> get redditSubreddits => _sharedPreferences.getStringList("reddit_subreddits") ?? defaultRedditSubreddits;

  Future<void> setRedditSubreddits(List<String> subreddits) async {
    await _sharedPreferences.setStringList("reddit_subreddits", subreddits);
    notifyListeners();
  }

  String get redditSort => _sharedPreferences.getString("reddit_sort") ?? RedditSort.hot.key;

  Future<void> setRedditSort(String sort) async {
    await _sharedPreferences.setString("reddit_sort", sort);
    notifyListeners();
  }

  String get redditClientId => _sharedPreferences.getString("reddit_client_id") ?? "";

  Future<void> setRedditClientId(String clientId) async {
    await _sharedPreferences.setString("reddit_client_id", clientId.trim());
    notifyListeners();
  }

  String get redditClientSecret => _sharedPreferences.getString("reddit_client_secret") ?? "";

  Future<void> setRedditClientSecret(String secret) async {
    await _sharedPreferences.setString("reddit_client_secret", secret.trim());
    notifyListeners();
  }

  String? get redditCurrentTitle => _sharedPreferences.getString("reddit_current_title");
  String? get redditCurrentAuthor => _sharedPreferences.getString("reddit_current_author");
  String? get redditCurrentSubreddit => _sharedPreferences.getString("reddit_current_subreddit");

  Future<void> setRedditWallpaperInfo({
    required String title,
    required String author,
    required String subreddit,
  }) async {
    await _sharedPreferences.setString("reddit_current_title", title);
    await _sharedPreferences.setString("reddit_current_author", author);
    await _sharedPreferences.setString("reddit_current_subreddit", subreddit);
    notifyListeners();
  }
}
