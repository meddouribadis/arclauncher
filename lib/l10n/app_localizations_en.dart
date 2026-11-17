// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get aboutFlauncher => 'About Arc Launcher';

  @override
  String get addCategory => 'Add category';

  @override
  String get addSection => 'Add section';

  @override
  String get alphabetical => 'Alphabetical';

  @override
  String get appCardHighlightAnimation => 'App card highlight animation';

  @override
  String get showFocusBorders => 'Show focus borders';

  @override
  String get focusBorderThickness => 'Focus border thickness';

  @override
  String get focusBorderThin => 'Subtle (1.0 dp)';

  @override
  String get focusBorderDefault => 'Default (1.5 dp)';

  @override
  String get focusBorderMedium => 'Medium (2.0 dp)';

  @override
  String get focusBorderBold => 'Bold (3.0 dp)';

  @override
  String get appInfo => 'Application info';

  @override
  String get appKeyClick => 'Click sound on key press';

  @override
  String get appearanceSettings => 'Appearance';

  @override
  String get backgroundBlur => 'Background blur';

  @override
  String get dockBlur => 'Dock blur';

  @override
  String get dockDarkBackground => 'Dark dock background';

  @override
  String get dockShadow => 'Dock shadow';

  @override
  String get applications => 'Applications';

  @override
  String get autoHideAppBar => 'Automatically hide status bar';

  @override
  String get hideStatusBarInGrid => 'Hide status bar in grid';

  @override
  String get backButtonAction => 'Back button action';

  @override
  String get category => 'Category';

  @override
  String get categories => 'Categories';

  @override
  String get columnCount => 'Column count';

  @override
  String get date => 'Date';

  @override
  String get dateAndTimeFormat => 'Date and time format';

  @override
  String get delete => 'Delete';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Do nothing';

  @override
  String get dialogOptionBackButtonActionShowScreensaver => 'Show screensaver';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Show clock';

  @override
  String get dialogTextNoFileExplorer =>
      'Please install a file explorer in order to pick a picture.';

  @override
  String get dialogTitleBackButtonAction => 'Choose the back button action';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Category)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Formatted date: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Formatted time: $timeString';
  }

  @override
  String get gradient => 'Gradient';

  @override
  String get favoriteApps => 'Favorite Apps';

  @override
  String get grid => 'Grid';

  @override
  String get height => 'Height';

  @override
  String get hide => 'Hide';

  @override
  String get hiddenApplications => 'Hidden Apps';

  @override
  String get launcherSections => 'Sections';

  @override
  String get layout => 'Layout';

  @override
  String get loading => 'Loading';

  @override
  String get manual => 'Manual';

  @override
  String get modifySection => 'Modify section';

  @override
  String get mustNotBeEmpty => 'Must not be empty';

  @override
  String get name => 'Name';

  @override
  String get newSection => 'New section';

  @override
  String get noDateFormatSpecified => 'No date format specified';

  @override
  String get noTimeFormatSpecified => 'No time format specified';

  @override
  String get allApplications => 'All Apps';

  @override
  String get nonTvApplications => 'Non-TV Apps';

  @override
  String get open => 'Open';

  @override
  String get orSelectFormatSpecifiers => 'Or select format specifiers';

  @override
  String get picture => 'Picture';

  @override
  String removeFrom(String name) {
    return 'Remove from $name';
  }

  @override
  String get renameCategory => 'Rename category';

  @override
  String get reorder => 'Reorder';

  @override
  String get row => 'Row';

  @override
  String get rowHeight => 'Row height';

  @override
  String get save => 'Save';

  @override
  String get spacer => 'Spacer';

  @override
  String get spacerMaxHeightRequirement =>
      'Must be greater than 0 and less than or equal to 500';

  @override
  String get statusBar => 'Status bar';

  @override
  String get settings => 'Settings';

  @override
  String get show => 'Show';

  @override
  String get showCategoryTitles => 'Show category titles';

  @override
  String get sort => 'Sort';

  @override
  String get systemSettings => 'System settings';

  @override
  String get updateCheck => 'Check for updates';

  @override
  String get updateNoUpdateTitle => 'No updates available';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'You are already on the latest version ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Update available';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'Version $latestVersion is available (current: $currentVersion).';
  }

  @override
  String get updateChangelog => 'What\'s new';

  @override
  String get updateDownloadButton => 'Download';

  @override
  String get updateReadyToInstallTitle => 'Ready to install';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'The APK for version $latestVersion is downloaded. Start installation now?';
  }

  @override
  String get updateInstallButton => 'Install';

  @override
  String get updateInstallPermissionTitle => 'Installer permission required';

  @override
  String get updateInstallPermissionBody =>
      'Allow Arc Launcher to install unknown apps, then retry the update.';

  @override
  String get updateOpenPermissionSettingsButton => 'Open permission settings';

  @override
  String get updateErrorGeneric => 'Update check failed. Please try again.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'Arc Launcher is a customized open-source launcher for Android TV, based on FLauncher.\n\nDeveloped by Meddouri Badis.\nSource code available at $repoUrl.';
  }

  @override
  String get textEmptyCategory => 'This category is empty.';

  @override
  String get time => 'Time';

  @override
  String get titleStatusBarSettingsPage =>
      'Choose what to display in the status bar';

  @override
  String get tvApplications => 'TV Apps';

  @override
  String get type => 'Type';

  @override
  String get typeInTheDateFormat => 'Type in the date format';

  @override
  String get typeInTheHourFormat => 'Type in the hour format';

  @override
  String get uninstall => 'Uninstall';

  @override
  String get wallpaper => 'Wallpaper';

  @override
  String get withEllipsisAddTo => 'Add to...';

  @override
  String get timeBasedWallpaper => 'Time based wallpaper';

  @override
  String get unsplashSlideshow => 'Unsplash slideshow';

  @override
  String get unsplashEnable => 'Show Unsplash photos';

  @override
  String get unsplashAccessKey => 'Unsplash access key';

  @override
  String get unsplashAccessKeyHelp =>
      'Create a free app at unsplash.com/developers and paste its Access Key.';

  @override
  String get unsplashNotSet => 'Not set';

  @override
  String get unsplashInterval => 'Change every';

  @override
  String unsplashIntervalMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get slideshowCategories => 'Categories';

  @override
  String get slideshowDay => 'Day (6:00 - 18:00)';

  @override
  String get slideshowNight => 'Night (18:00 - 6:00)';

  @override
  String unsplashPhotoCredit(String author) {
    return 'Photo: $author / Unsplash';
  }

  @override
  String get pickDayWallpaper => 'Pick day wallpaper';

  @override
  String get pickNightWallpaper => 'Pick night wallpaper';

  @override
  String get video => 'Video';

  @override
  String get pickDayVideoWallpaper => 'Pick day video';

  @override
  String get pickNightVideoWallpaper => 'Pick night video';

  @override
  String get watchNextSectionTitle => 'Watch Next';

  @override
  String get showWatchNextSection => 'Show Watch Next Section';

  @override
  String get watchNextPermissionTitle => 'Watch Next permission required';

  @override
  String get watchNextPermissionBody =>
      'Allow access to TV listings to show your continue watching items.';

  @override
  String get watchNextGrantPermission => 'Grant permission';

  @override
  String get watchNextCheckPermission => 'Check again';

  @override
  String get interface => 'Interface';

  @override
  String get system => 'System';

  @override
  String get accentColor => 'Accent Color';

  @override
  String get miscellaneous => 'Miscellaneous';

  @override
  String get brightnessScheduler => 'Brightness Scheduler';

  @override
  String get screensaverSettings => 'Screensaver Settings';

  @override
  String get screensaverClockStyle => 'Screensaver Clock Style';

  @override
  String get wifiUsagePeriod => 'WiFi Usage Period';

  @override
  String get showAppNamesBelowIcons => 'Show App Names Below Icons';

  @override
  String get wifiUsage => 'WiFi Usage';

  @override
  String get networkIndicator => 'Network Indicator';

  @override
  String get showCpuLoad => 'Show CPU load';

  @override
  String get customName => 'Custom Name';

  @override
  String get lastUsed => 'Last Used';

  @override
  String get daily => 'Daily';

  @override
  String get weekly => 'Weekly';

  @override
  String get monthly => 'Monthly';

  @override
  String get grantPermission => 'Grant Permission';

  @override
  String get checkStatus => 'Check Status';

  @override
  String get watchNextBigPictureMode => 'Immersive mode';

  @override
  String get watchNextBigPictureModeDescription =>
      'Show full-width hero backdrop with an action watch button';

  @override
  String get watchNextWatch => 'Watch';

  @override
  String get watchNextResume => 'Resume';

  @override
  String get watchNextRefresh => 'Refresh content';

  @override
  String get watchNextRefreshDescription =>
      'Reload recommendations from media providers';

  @override
  String get watchNextRefreshed => 'Watch Next content refreshed';

  @override
  String get watchNextFilterApps => 'Filter apps';

  @override
  String get watchNextFilterAppsDescription =>
      'Select which apps can display content in Watch Next';

  @override
  String get watchNextNoApps =>
      'No media apps currently providing Watch Next content';

  @override
  String get watchNextShowAllApps => 'Show all installed apps';

  @override
  String get watchNextHideWithoutImages => 'Hide programs without image';

  @override
  String get watchNextHideWithoutImagesDescription =>
      'Only show programs that provide poster or backdrop artwork';

  @override
  String get watchNextMaxItems => 'Maximum programs';

  @override
  String get watchNextMaxItemsDescription =>
      'Limit the number of programs displayed in Watch Next';

  @override
  String get watchNextMaxItemsUnlimited => 'Unlimited';

  @override
  String get redditWallpaper => 'Reddit wallpaper';

  @override
  String get redditWallpaperEnable => 'Show Reddit wallpapers';

  @override
  String get redditSubreddits => 'Subreddits';

  @override
  String get redditSort => 'Sort by';

  @override
  String get redditSortHot => 'Hot';

  @override
  String get redditSortTopDay => 'Top (Today)';

  @override
  String get redditSortTopWeek => 'Top (This week)';

  @override
  String get redditSortTopMonth => 'Top (This month)';

  @override
  String get redditSortTopAll => 'Top (All time)';

  @override
  String get redditSortNew => 'New';

  @override
  String get redditInterval => 'Change every';

  @override
  String redditIntervalMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get redditInterval1Hour => '1 hour';

  @override
  String redditIntervalHours(int hours) {
    return '$hours hours';
  }

  @override
  String get redditInterval1Day => '1 day';

  @override
  String redditIntervalDays(int days) {
    return '$days days';
  }

  @override
  String get redditClientId => 'Reddit Client ID (Optional)';

  @override
  String get redditClientIdHelp =>
      'Optional. Create an installed app at reddit.com/prefs/apps and paste its ID if your network requires it.';

  @override
  String get redditChangeNow => 'Change wallpaper now';

  @override
  String get redditAddSubreddit => 'Add custom subreddit';

  @override
  String get redditSubredditName => 'Subreddit name (without r/)';

  @override
  String get redditSubredditAdded => 'Subreddit added';

  @override
  String get redditSubredditInvalid => 'Please enter a valid subreddit name';

  @override
  String get redditWallpaperUpdated => 'Wallpaper updated successfully';

  @override
  String get redditWallpaperFailed =>
      'Failed to fetch wallpaper. If this persists, configure a Reddit Client ID in settings.';

  @override
  String get addToFavorites => 'Add to Fav';

  @override
  String get removeFromFavorites => 'Remove from Fav';

  @override
  String get addToCategory => 'Add to Category';

  @override
  String get setCustomBanner => 'Set Custom Banner';

  @override
  String get clearCustomBanner => 'Clear Custom Banner';

  @override
  String customBannerSetFailed(String error) {
    return 'Failed to set banner: $error';
  }

  @override
  String customBannerClearFailed(String error) {
    return 'Failed to clear banner: $error';
  }

  @override
  String get selectImage => 'Select Image';

  @override
  String get selectVideo => 'Select Video';

  @override
  String mediaItemCount(int count) {
    return '$count items';
  }

  @override
  String get noImagesFound => 'No images found on device';

  @override
  String get noVideosFound => 'No videos found on device';

  @override
  String get mediaNavigationHint => 'D-pad: navigate  •  Back: cancel';

  @override
  String get mediaSelectionHint =>
      'D-pad: navigate  •  Select: set wallpaper  •  Back: cancel';

  @override
  String get mediaPermissionRequired => 'Media access permission is required';

  @override
  String get mediaPermissionHelp =>
      'Grant permission to browse photos and videos';

  @override
  String get preview => 'Preview';

  @override
  String get colorPurple => 'Purple';

  @override
  String get colorTeal => 'Teal';

  @override
  String get colorBlue => 'Blue';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Pink';

  @override
  String get colorGreen => 'Green';

  @override
  String get colorWhite => 'White';

  @override
  String get colorYellow => 'Yellow';

  @override
  String get colorRed => 'Red';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorLime => 'Lime';

  @override
  String get colorAmber => 'Amber';

  @override
  String get colorRose => 'Rose';

  @override
  String get colorIceBlue => 'Ice Blue';

  @override
  String get clockStyleMinimal => 'Minimal';

  @override
  String get clockStyleMinimalDescription => 'Thin, elegant font (Default)';

  @override
  String get clockStyleBold => 'Bold';

  @override
  String get clockStyleBoldDescription => 'Thick, highly visible font';

  @override
  String get clockStyleRetro => 'Retro';

  @override
  String get clockStyleRetroDescription => 'Monospaced, retro terminal style';

  @override
  String get clockStyleElegant => 'Elegant';

  @override
  String get clockStyleElegantDescription => 'Classic serif typeface';

  @override
  String get clockStyleNeon => 'Neon';

  @override
  String get clockStyleNeonDescription => 'Ultra-thin, glowing style';

  @override
  String get clockStylePixel => 'Pixel';

  @override
  String get clockStylePixelDescription => 'Bold monospaced, arcade feel';

  @override
  String get clockStyleDigital => 'Digital';

  @override
  String get clockStyleDigitalDescription => 'Clean monospaced display';

  @override
  String get brightnessPermissionRequired => 'Permission Required';

  @override
  String get brightnessPermissionHelp =>
      'To control brightness on this device, you must grant permission via ADB:';

  @override
  String get brightnessExperimentalNotice =>
      'EXPERIMENTAL: This feature is untested and may be removed in future versions based on user feedback.';

  @override
  String get brightnessDeviceSupportNote =>
      'Note: Some Android TV devices may not support app-level brightness control.';

  @override
  String get enableBrightnessScheduler => 'Enable Scheduler';

  @override
  String currentBrightnessSlot(String slot) {
    return 'Current: $slot';
  }

  @override
  String get brightnessSlotMorning => '6 AM - 9 AM';

  @override
  String get brightnessSlotDay => '9 AM - 3 PM';

  @override
  String get brightnessSlotAfternoon => '3 PM - 6 PM';

  @override
  String get brightnessSlotEvening => '6 PM - 10 PM';

  @override
  String get brightnessSlotNight => '10 PM - 6 AM';
}
