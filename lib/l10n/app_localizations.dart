import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_tr.dart';
import 'app_localizations_vi.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es'),
    Locale('tr'),
    Locale('vi'),
  ];

  /// No description provided for @aboutFlauncher.
  ///
  /// In en, this message translates to:
  /// **'About Arc Launcher'**
  String get aboutFlauncher;

  /// No description provided for @addCategory.
  ///
  /// In en, this message translates to:
  /// **'Add category'**
  String get addCategory;

  /// No description provided for @addSection.
  ///
  /// In en, this message translates to:
  /// **'Add section'**
  String get addSection;

  /// No description provided for @alphabetical.
  ///
  /// In en, this message translates to:
  /// **'Alphabetical'**
  String get alphabetical;

  /// No description provided for @appCardHighlightAnimation.
  ///
  /// In en, this message translates to:
  /// **'App card highlight animation'**
  String get appCardHighlightAnimation;

  /// No description provided for @showFocusBorders.
  ///
  /// In en, this message translates to:
  /// **'Show focus borders'**
  String get showFocusBorders;

  /// No description provided for @focusBorderThickness.
  ///
  /// In en, this message translates to:
  /// **'Focus border thickness'**
  String get focusBorderThickness;

  /// No description provided for @focusBorderThin.
  ///
  /// In en, this message translates to:
  /// **'Subtle (1.0 dp)'**
  String get focusBorderThin;

  /// No description provided for @focusBorderDefault.
  ///
  /// In en, this message translates to:
  /// **'Default (1.5 dp)'**
  String get focusBorderDefault;

  /// No description provided for @focusBorderMedium.
  ///
  /// In en, this message translates to:
  /// **'Medium (2.0 dp)'**
  String get focusBorderMedium;

  /// No description provided for @focusBorderBold.
  ///
  /// In en, this message translates to:
  /// **'Bold (3.0 dp)'**
  String get focusBorderBold;

  /// No description provided for @appInfo.
  ///
  /// In en, this message translates to:
  /// **'Application info'**
  String get appInfo;

  /// No description provided for @appKeyClick.
  ///
  /// In en, this message translates to:
  /// **'Click sound on key press'**
  String get appKeyClick;

  /// No description provided for @appearanceSettings.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearanceSettings;

  /// No description provided for @backgroundBlur.
  ///
  /// In en, this message translates to:
  /// **'Background blur'**
  String get backgroundBlur;

  /// No description provided for @dockBlur.
  ///
  /// In en, this message translates to:
  /// **'Dock blur'**
  String get dockBlur;

  /// No description provided for @dockDarkBackground.
  ///
  /// In en, this message translates to:
  /// **'Dark dock background'**
  String get dockDarkBackground;

  /// No description provided for @dockShadow.
  ///
  /// In en, this message translates to:
  /// **'Dock shadow'**
  String get dockShadow;

  /// No description provided for @applications.
  ///
  /// In en, this message translates to:
  /// **'Applications'**
  String get applications;

  /// No description provided for @autoHideAppBar.
  ///
  /// In en, this message translates to:
  /// **'Automatically hide status bar'**
  String get autoHideAppBar;

  /// No description provided for @hideStatusBarInGrid.
  ///
  /// In en, this message translates to:
  /// **'Hide status bar in grid'**
  String get hideStatusBarInGrid;

  /// No description provided for @backButtonAction.
  ///
  /// In en, this message translates to:
  /// **'Back button action'**
  String get backButtonAction;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @columnCount.
  ///
  /// In en, this message translates to:
  /// **'Column count'**
  String get columnCount;

  /// No description provided for @date.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get date;

  /// No description provided for @dateAndTimeFormat.
  ///
  /// In en, this message translates to:
  /// **'Date and time format'**
  String get dateAndTimeFormat;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @dialogOptionBackButtonActionDoNothing.
  ///
  /// In en, this message translates to:
  /// **'Do nothing'**
  String get dialogOptionBackButtonActionDoNothing;

  /// No description provided for @dialogOptionBackButtonActionShowScreensaver.
  ///
  /// In en, this message translates to:
  /// **'Show screensaver'**
  String get dialogOptionBackButtonActionShowScreensaver;

  /// No description provided for @dialogOptionBackButtonActionShowClock.
  ///
  /// In en, this message translates to:
  /// **'Show clock'**
  String get dialogOptionBackButtonActionShowClock;

  /// No description provided for @dialogTextNoFileExplorer.
  ///
  /// In en, this message translates to:
  /// **'Please install a file explorer in order to pick a picture.'**
  String get dialogTextNoFileExplorer;

  /// No description provided for @dialogTitleBackButtonAction.
  ///
  /// In en, this message translates to:
  /// **'Choose the back button action'**
  String get dialogTitleBackButtonAction;

  /// No description provided for @disambiguateCategoryTitle.
  ///
  /// In en, this message translates to:
  /// **'{title} (Category)'**
  String disambiguateCategoryTitle(String title);

  /// No description provided for @formattedDate.
  ///
  /// In en, this message translates to:
  /// **'Formatted date: {dateString}'**
  String formattedDate(String dateString);

  /// No description provided for @formattedTime.
  ///
  /// In en, this message translates to:
  /// **'Formatted time: {timeString}'**
  String formattedTime(String timeString);

  /// No description provided for @gradient.
  ///
  /// In en, this message translates to:
  /// **'Gradient'**
  String get gradient;

  /// No description provided for @favoriteApps.
  ///
  /// In en, this message translates to:
  /// **'Favorite Apps'**
  String get favoriteApps;

  /// No description provided for @grid.
  ///
  /// In en, this message translates to:
  /// **'Grid'**
  String get grid;

  /// No description provided for @height.
  ///
  /// In en, this message translates to:
  /// **'Height'**
  String get height;

  /// No description provided for @hide.
  ///
  /// In en, this message translates to:
  /// **'Hide'**
  String get hide;

  /// No description provided for @hiddenApplications.
  ///
  /// In en, this message translates to:
  /// **'Hidden Apps'**
  String get hiddenApplications;

  /// No description provided for @launcherSections.
  ///
  /// In en, this message translates to:
  /// **'Sections'**
  String get launcherSections;

  /// No description provided for @layout.
  ///
  /// In en, this message translates to:
  /// **'Layout'**
  String get layout;

  /// No description provided for @loading.
  ///
  /// In en, this message translates to:
  /// **'Loading'**
  String get loading;

  /// No description provided for @manual.
  ///
  /// In en, this message translates to:
  /// **'Manual'**
  String get manual;

  /// No description provided for @modifySection.
  ///
  /// In en, this message translates to:
  /// **'Modify section'**
  String get modifySection;

  /// No description provided for @mustNotBeEmpty.
  ///
  /// In en, this message translates to:
  /// **'Must not be empty'**
  String get mustNotBeEmpty;

  /// No description provided for @name.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get name;

  /// No description provided for @newSection.
  ///
  /// In en, this message translates to:
  /// **'New section'**
  String get newSection;

  /// No description provided for @noDateFormatSpecified.
  ///
  /// In en, this message translates to:
  /// **'No date format specified'**
  String get noDateFormatSpecified;

  /// No description provided for @noTimeFormatSpecified.
  ///
  /// In en, this message translates to:
  /// **'No time format specified'**
  String get noTimeFormatSpecified;

  /// No description provided for @allApplications.
  ///
  /// In en, this message translates to:
  /// **'All Apps'**
  String get allApplications;

  /// No description provided for @nonTvApplications.
  ///
  /// In en, this message translates to:
  /// **'Non-TV Apps'**
  String get nonTvApplications;

  /// No description provided for @open.
  ///
  /// In en, this message translates to:
  /// **'Open'**
  String get open;

  /// No description provided for @orSelectFormatSpecifiers.
  ///
  /// In en, this message translates to:
  /// **'Or select format specifiers'**
  String get orSelectFormatSpecifiers;

  /// No description provided for @picture.
  ///
  /// In en, this message translates to:
  /// **'Picture'**
  String get picture;

  /// No description provided for @removeFrom.
  ///
  /// In en, this message translates to:
  /// **'Remove from {name}'**
  String removeFrom(String name);

  /// No description provided for @renameCategory.
  ///
  /// In en, this message translates to:
  /// **'Rename category'**
  String get renameCategory;

  /// No description provided for @reorder.
  ///
  /// In en, this message translates to:
  /// **'Reorder'**
  String get reorder;

  /// No description provided for @row.
  ///
  /// In en, this message translates to:
  /// **'Row'**
  String get row;

  /// No description provided for @rowHeight.
  ///
  /// In en, this message translates to:
  /// **'Row height'**
  String get rowHeight;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @spacer.
  ///
  /// In en, this message translates to:
  /// **'Spacer'**
  String get spacer;

  /// No description provided for @spacerMaxHeightRequirement.
  ///
  /// In en, this message translates to:
  /// **'Must be greater than 0 and less than or equal to 500'**
  String get spacerMaxHeightRequirement;

  /// No description provided for @statusBar.
  ///
  /// In en, this message translates to:
  /// **'Status bar'**
  String get statusBar;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @show.
  ///
  /// In en, this message translates to:
  /// **'Show'**
  String get show;

  /// No description provided for @showCategoryTitles.
  ///
  /// In en, this message translates to:
  /// **'Show category titles'**
  String get showCategoryTitles;

  /// No description provided for @sort.
  ///
  /// In en, this message translates to:
  /// **'Sort'**
  String get sort;

  /// No description provided for @systemSettings.
  ///
  /// In en, this message translates to:
  /// **'System settings'**
  String get systemSettings;

  /// No description provided for @updateCheck.
  ///
  /// In en, this message translates to:
  /// **'Check for updates'**
  String get updateCheck;

  /// No description provided for @updateNoUpdateTitle.
  ///
  /// In en, this message translates to:
  /// **'No updates available'**
  String get updateNoUpdateTitle;

  /// No description provided for @updateNoUpdateBody.
  ///
  /// In en, this message translates to:
  /// **'You are already on the latest version ({currentVersion}).'**
  String updateNoUpdateBody(String currentVersion);

  /// No description provided for @updateAvailableTitle.
  ///
  /// In en, this message translates to:
  /// **'Update available'**
  String get updateAvailableTitle;

  /// No description provided for @updateAvailableBody.
  ///
  /// In en, this message translates to:
  /// **'Version {latestVersion} is available (current: {currentVersion}).'**
  String updateAvailableBody(String latestVersion, String currentVersion);

  /// No description provided for @updateChangelog.
  ///
  /// In en, this message translates to:
  /// **'What\'s new'**
  String get updateChangelog;

  /// No description provided for @updateDownloadButton.
  ///
  /// In en, this message translates to:
  /// **'Download'**
  String get updateDownloadButton;

  /// No description provided for @updateReadyToInstallTitle.
  ///
  /// In en, this message translates to:
  /// **'Ready to install'**
  String get updateReadyToInstallTitle;

  /// No description provided for @updateReadyToInstallBody.
  ///
  /// In en, this message translates to:
  /// **'The APK for version {latestVersion} is downloaded. Start installation now?'**
  String updateReadyToInstallBody(String latestVersion);

  /// No description provided for @updateInstallButton.
  ///
  /// In en, this message translates to:
  /// **'Install'**
  String get updateInstallButton;

  /// No description provided for @updateInstallPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Installer permission required'**
  String get updateInstallPermissionTitle;

  /// No description provided for @updateInstallPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow Arc Launcher to install unknown apps, then retry the update.'**
  String get updateInstallPermissionBody;

  /// No description provided for @updateOpenPermissionSettingsButton.
  ///
  /// In en, this message translates to:
  /// **'Open permission settings'**
  String get updateOpenPermissionSettingsButton;

  /// No description provided for @updateErrorGeneric.
  ///
  /// In en, this message translates to:
  /// **'Update check failed. Please try again.'**
  String get updateErrorGeneric;

  /// No description provided for @textAboutDialog.
  ///
  /// In en, this message translates to:
  /// **'Arc Launcher is a customized open-source launcher for Android TV, based on FLauncher.\n\nDeveloped by Meddouri Badis.\nSource code available at {repoUrl}.'**
  String textAboutDialog(String repoUrl);

  /// No description provided for @textEmptyCategory.
  ///
  /// In en, this message translates to:
  /// **'This category is empty.'**
  String get textEmptyCategory;

  /// No description provided for @time.
  ///
  /// In en, this message translates to:
  /// **'Time'**
  String get time;

  /// No description provided for @titleStatusBarSettingsPage.
  ///
  /// In en, this message translates to:
  /// **'Choose what to display in the status bar'**
  String get titleStatusBarSettingsPage;

  /// No description provided for @tvApplications.
  ///
  /// In en, this message translates to:
  /// **'TV Apps'**
  String get tvApplications;

  /// No description provided for @type.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get type;

  /// No description provided for @typeInTheDateFormat.
  ///
  /// In en, this message translates to:
  /// **'Type in the date format'**
  String get typeInTheDateFormat;

  /// No description provided for @typeInTheHourFormat.
  ///
  /// In en, this message translates to:
  /// **'Type in the hour format'**
  String get typeInTheHourFormat;

  /// No description provided for @uninstall.
  ///
  /// In en, this message translates to:
  /// **'Uninstall'**
  String get uninstall;

  /// No description provided for @wallpaper.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper'**
  String get wallpaper;

  /// No description provided for @withEllipsisAddTo.
  ///
  /// In en, this message translates to:
  /// **'Add to...'**
  String get withEllipsisAddTo;

  /// No description provided for @timeBasedWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Time based wallpaper'**
  String get timeBasedWallpaper;

  /// No description provided for @unsplashSlideshow.
  ///
  /// In en, this message translates to:
  /// **'Unsplash slideshow'**
  String get unsplashSlideshow;

  /// No description provided for @unsplashEnable.
  ///
  /// In en, this message translates to:
  /// **'Show Unsplash photos'**
  String get unsplashEnable;

  /// No description provided for @unsplashAccessKey.
  ///
  /// In en, this message translates to:
  /// **'Unsplash access key'**
  String get unsplashAccessKey;

  /// No description provided for @unsplashAccessKeyHelp.
  ///
  /// In en, this message translates to:
  /// **'Create a free app at unsplash.com/developers and paste its Access Key.'**
  String get unsplashAccessKeyHelp;

  /// No description provided for @unsplashNotSet.
  ///
  /// In en, this message translates to:
  /// **'Not set'**
  String get unsplashNotSet;

  /// No description provided for @unsplashInterval.
  ///
  /// In en, this message translates to:
  /// **'Change every'**
  String get unsplashInterval;

  /// No description provided for @unsplashIntervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String unsplashIntervalMinutes(int minutes);

  /// No description provided for @slideshowCategories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get slideshowCategories;

  /// No description provided for @slideshowDay.
  ///
  /// In en, this message translates to:
  /// **'Day (6:00 - 18:00)'**
  String get slideshowDay;

  /// No description provided for @slideshowNight.
  ///
  /// In en, this message translates to:
  /// **'Night (18:00 - 6:00)'**
  String get slideshowNight;

  /// No description provided for @unsplashPhotoCredit.
  ///
  /// In en, this message translates to:
  /// **'Photo: {author} / Unsplash'**
  String unsplashPhotoCredit(String author);

  /// No description provided for @pickDayWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Pick day wallpaper'**
  String get pickDayWallpaper;

  /// No description provided for @pickNightWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Pick night wallpaper'**
  String get pickNightWallpaper;

  /// No description provided for @video.
  ///
  /// In en, this message translates to:
  /// **'Video'**
  String get video;

  /// No description provided for @pickDayVideoWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Pick day video'**
  String get pickDayVideoWallpaper;

  /// No description provided for @pickNightVideoWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Pick night video'**
  String get pickNightVideoWallpaper;

  /// No description provided for @watchNextSectionTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch Next'**
  String get watchNextSectionTitle;

  /// No description provided for @showWatchNextSection.
  ///
  /// In en, this message translates to:
  /// **'Show Watch Next Section'**
  String get showWatchNextSection;

  /// No description provided for @watchNextPermissionTitle.
  ///
  /// In en, this message translates to:
  /// **'Watch Next permission required'**
  String get watchNextPermissionTitle;

  /// No description provided for @watchNextPermissionBody.
  ///
  /// In en, this message translates to:
  /// **'Allow access to TV listings to show your continue watching items.'**
  String get watchNextPermissionBody;

  /// No description provided for @watchNextGrantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant permission'**
  String get watchNextGrantPermission;

  /// No description provided for @watchNextCheckPermission.
  ///
  /// In en, this message translates to:
  /// **'Check again'**
  String get watchNextCheckPermission;

  /// No description provided for @interface.
  ///
  /// In en, this message translates to:
  /// **'Interface'**
  String get interface;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @accentColor.
  ///
  /// In en, this message translates to:
  /// **'Accent Color'**
  String get accentColor;

  /// No description provided for @miscellaneous.
  ///
  /// In en, this message translates to:
  /// **'Miscellaneous'**
  String get miscellaneous;

  /// No description provided for @brightnessScheduler.
  ///
  /// In en, this message translates to:
  /// **'Brightness Scheduler'**
  String get brightnessScheduler;

  /// No description provided for @screensaverSettings.
  ///
  /// In en, this message translates to:
  /// **'Screensaver Settings'**
  String get screensaverSettings;

  /// No description provided for @screensaverClockStyle.
  ///
  /// In en, this message translates to:
  /// **'Screensaver Clock Style'**
  String get screensaverClockStyle;

  /// No description provided for @wifiUsagePeriod.
  ///
  /// In en, this message translates to:
  /// **'WiFi Usage Period'**
  String get wifiUsagePeriod;

  /// No description provided for @showAppNamesBelowIcons.
  ///
  /// In en, this message translates to:
  /// **'Show App Names Below Icons'**
  String get showAppNamesBelowIcons;

  /// No description provided for @wifiUsage.
  ///
  /// In en, this message translates to:
  /// **'WiFi Usage'**
  String get wifiUsage;

  /// No description provided for @networkIndicator.
  ///
  /// In en, this message translates to:
  /// **'Network Indicator'**
  String get networkIndicator;

  /// No description provided for @customName.
  ///
  /// In en, this message translates to:
  /// **'Custom Name'**
  String get customName;

  /// No description provided for @lastUsed.
  ///
  /// In en, this message translates to:
  /// **'Last Used'**
  String get lastUsed;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @monthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get monthly;

  /// No description provided for @grantPermission.
  ///
  /// In en, this message translates to:
  /// **'Grant Permission'**
  String get grantPermission;

  /// No description provided for @checkStatus.
  ///
  /// In en, this message translates to:
  /// **'Check Status'**
  String get checkStatus;

  /// No description provided for @watchNextBigPictureMode.
  ///
  /// In en, this message translates to:
  /// **'Immersive mode'**
  String get watchNextBigPictureMode;

  /// No description provided for @watchNextBigPictureModeDescription.
  ///
  /// In en, this message translates to:
  /// **'Show full-width hero backdrop with an action watch button'**
  String get watchNextBigPictureModeDescription;

  /// No description provided for @watchNextWatch.
  ///
  /// In en, this message translates to:
  /// **'Watch'**
  String get watchNextWatch;

  /// No description provided for @watchNextResume.
  ///
  /// In en, this message translates to:
  /// **'Resume'**
  String get watchNextResume;

  /// No description provided for @watchNextRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh content'**
  String get watchNextRefresh;

  /// No description provided for @watchNextRefreshDescription.
  ///
  /// In en, this message translates to:
  /// **'Reload recommendations from media providers'**
  String get watchNextRefreshDescription;

  /// No description provided for @watchNextRefreshed.
  ///
  /// In en, this message translates to:
  /// **'Watch Next content refreshed'**
  String get watchNextRefreshed;

  /// No description provided for @watchNextFilterApps.
  ///
  /// In en, this message translates to:
  /// **'Filter apps'**
  String get watchNextFilterApps;

  /// No description provided for @watchNextFilterAppsDescription.
  ///
  /// In en, this message translates to:
  /// **'Select which apps can display content in Watch Next'**
  String get watchNextFilterAppsDescription;

  /// No description provided for @watchNextNoApps.
  ///
  /// In en, this message translates to:
  /// **'No media apps currently providing Watch Next content'**
  String get watchNextNoApps;

  /// No description provided for @watchNextShowAllApps.
  ///
  /// In en, this message translates to:
  /// **'Show all installed apps'**
  String get watchNextShowAllApps;

  /// No description provided for @watchNextHideWithoutImages.
  ///
  /// In en, this message translates to:
  /// **'Hide programs without image'**
  String get watchNextHideWithoutImages;

  /// No description provided for @watchNextHideWithoutImagesDescription.
  ///
  /// In en, this message translates to:
  /// **'Only show programs that provide poster or backdrop artwork'**
  String get watchNextHideWithoutImagesDescription;

  /// No description provided for @watchNextMaxItems.
  ///
  /// In en, this message translates to:
  /// **'Maximum programs'**
  String get watchNextMaxItems;

  /// No description provided for @watchNextMaxItemsDescription.
  ///
  /// In en, this message translates to:
  /// **'Limit the number of programs displayed in Watch Next'**
  String get watchNextMaxItemsDescription;

  /// No description provided for @watchNextMaxItemsUnlimited.
  ///
  /// In en, this message translates to:
  /// **'Unlimited'**
  String get watchNextMaxItemsUnlimited;

  /// No description provided for @redditWallpaper.
  ///
  /// In en, this message translates to:
  /// **'Reddit wallpaper'**
  String get redditWallpaper;

  /// No description provided for @redditWallpaperEnable.
  ///
  /// In en, this message translates to:
  /// **'Show Reddit wallpapers'**
  String get redditWallpaperEnable;

  /// No description provided for @redditSubreddits.
  ///
  /// In en, this message translates to:
  /// **'Subreddits'**
  String get redditSubreddits;

  /// No description provided for @redditSort.
  ///
  /// In en, this message translates to:
  /// **'Sort by'**
  String get redditSort;

  /// No description provided for @redditSortHot.
  ///
  /// In en, this message translates to:
  /// **'Hot'**
  String get redditSortHot;

  /// No description provided for @redditSortTopDay.
  ///
  /// In en, this message translates to:
  /// **'Top (Today)'**
  String get redditSortTopDay;

  /// No description provided for @redditSortTopWeek.
  ///
  /// In en, this message translates to:
  /// **'Top (This week)'**
  String get redditSortTopWeek;

  /// No description provided for @redditSortTopMonth.
  ///
  /// In en, this message translates to:
  /// **'Top (This month)'**
  String get redditSortTopMonth;

  /// No description provided for @redditSortTopAll.
  ///
  /// In en, this message translates to:
  /// **'Top (All time)'**
  String get redditSortTopAll;

  /// No description provided for @redditSortNew.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get redditSortNew;

  /// No description provided for @redditInterval.
  ///
  /// In en, this message translates to:
  /// **'Change every'**
  String get redditInterval;

  /// No description provided for @redditIntervalMinutes.
  ///
  /// In en, this message translates to:
  /// **'{minutes} min'**
  String redditIntervalMinutes(int minutes);

  /// No description provided for @redditInterval1Hour.
  ///
  /// In en, this message translates to:
  /// **'1 hour'**
  String get redditInterval1Hour;

  /// No description provided for @redditIntervalHours.
  ///
  /// In en, this message translates to:
  /// **'{hours} hours'**
  String redditIntervalHours(int hours);

  /// No description provided for @redditInterval1Day.
  ///
  /// In en, this message translates to:
  /// **'1 day'**
  String get redditInterval1Day;

  /// No description provided for @redditIntervalDays.
  ///
  /// In en, this message translates to:
  /// **'{days} days'**
  String redditIntervalDays(int days);

  /// No description provided for @redditClientId.
  ///
  /// In en, this message translates to:
  /// **'Reddit Client ID (Optional)'**
  String get redditClientId;

  /// No description provided for @redditClientIdHelp.
  ///
  /// In en, this message translates to:
  /// **'Optional. Create an installed app at reddit.com/prefs/apps and paste its ID if your network requires it.'**
  String get redditClientIdHelp;

  /// No description provided for @redditChangeNow.
  ///
  /// In en, this message translates to:
  /// **'Change wallpaper now'**
  String get redditChangeNow;

  /// No description provided for @redditAddSubreddit.
  ///
  /// In en, this message translates to:
  /// **'Add custom subreddit'**
  String get redditAddSubreddit;

  /// No description provided for @redditSubredditName.
  ///
  /// In en, this message translates to:
  /// **'Subreddit name (without r/)'**
  String get redditSubredditName;

  /// No description provided for @redditSubredditAdded.
  ///
  /// In en, this message translates to:
  /// **'Subreddit added'**
  String get redditSubredditAdded;

  /// No description provided for @redditSubredditInvalid.
  ///
  /// In en, this message translates to:
  /// **'Please enter a valid subreddit name'**
  String get redditSubredditInvalid;

  /// No description provided for @redditWallpaperUpdated.
  ///
  /// In en, this message translates to:
  /// **'Wallpaper updated successfully'**
  String get redditWallpaperUpdated;

  /// No description provided for @redditWallpaperFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to fetch wallpaper. If this persists, configure a Reddit Client ID in settings.'**
  String get redditWallpaperFailed;

  /// No description provided for @addToFavorites.
  ///
  /// In en, this message translates to:
  /// **'Add to Fav'**
  String get addToFavorites;

  /// No description provided for @removeFromFavorites.
  ///
  /// In en, this message translates to:
  /// **'Remove from Fav'**
  String get removeFromFavorites;

  /// No description provided for @addToCategory.
  ///
  /// In en, this message translates to:
  /// **'Add to Category'**
  String get addToCategory;

  /// No description provided for @setCustomBanner.
  ///
  /// In en, this message translates to:
  /// **'Set Custom Banner'**
  String get setCustomBanner;

  /// No description provided for @clearCustomBanner.
  ///
  /// In en, this message translates to:
  /// **'Clear Custom Banner'**
  String get clearCustomBanner;

  /// No description provided for @customBannerSetFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to set banner: {error}'**
  String customBannerSetFailed(String error);

  /// No description provided for @customBannerClearFailed.
  ///
  /// In en, this message translates to:
  /// **'Failed to clear banner: {error}'**
  String customBannerClearFailed(String error);

  /// No description provided for @selectImage.
  ///
  /// In en, this message translates to:
  /// **'Select Image'**
  String get selectImage;

  /// No description provided for @selectVideo.
  ///
  /// In en, this message translates to:
  /// **'Select Video'**
  String get selectVideo;

  /// No description provided for @mediaItemCount.
  ///
  /// In en, this message translates to:
  /// **'{count} items'**
  String mediaItemCount(int count);

  /// No description provided for @noImagesFound.
  ///
  /// In en, this message translates to:
  /// **'No images found on device'**
  String get noImagesFound;

  /// No description provided for @noVideosFound.
  ///
  /// In en, this message translates to:
  /// **'No videos found on device'**
  String get noVideosFound;

  /// No description provided for @mediaNavigationHint.
  ///
  /// In en, this message translates to:
  /// **'D-pad: navigate  •  Back: cancel'**
  String get mediaNavigationHint;

  /// No description provided for @mediaSelectionHint.
  ///
  /// In en, this message translates to:
  /// **'D-pad: navigate  •  Select: set wallpaper  •  Back: cancel'**
  String get mediaSelectionHint;

  /// No description provided for @mediaPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Media access permission is required'**
  String get mediaPermissionRequired;

  /// No description provided for @mediaPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'Grant permission to browse photos and videos'**
  String get mediaPermissionHelp;

  /// No description provided for @preview.
  ///
  /// In en, this message translates to:
  /// **'Preview'**
  String get preview;

  /// No description provided for @colorPurple.
  ///
  /// In en, this message translates to:
  /// **'Purple'**
  String get colorPurple;

  /// No description provided for @colorTeal.
  ///
  /// In en, this message translates to:
  /// **'Teal'**
  String get colorTeal;

  /// No description provided for @colorBlue.
  ///
  /// In en, this message translates to:
  /// **'Blue'**
  String get colorBlue;

  /// No description provided for @colorOrange.
  ///
  /// In en, this message translates to:
  /// **'Orange'**
  String get colorOrange;

  /// No description provided for @colorPink.
  ///
  /// In en, this message translates to:
  /// **'Pink'**
  String get colorPink;

  /// No description provided for @colorGreen.
  ///
  /// In en, this message translates to:
  /// **'Green'**
  String get colorGreen;

  /// No description provided for @colorWhite.
  ///
  /// In en, this message translates to:
  /// **'White'**
  String get colorWhite;

  /// No description provided for @colorYellow.
  ///
  /// In en, this message translates to:
  /// **'Yellow'**
  String get colorYellow;

  /// No description provided for @colorRed.
  ///
  /// In en, this message translates to:
  /// **'Red'**
  String get colorRed;

  /// No description provided for @colorCyan.
  ///
  /// In en, this message translates to:
  /// **'Cyan'**
  String get colorCyan;

  /// No description provided for @colorIndigo.
  ///
  /// In en, this message translates to:
  /// **'Indigo'**
  String get colorIndigo;

  /// No description provided for @colorLime.
  ///
  /// In en, this message translates to:
  /// **'Lime'**
  String get colorLime;

  /// No description provided for @colorAmber.
  ///
  /// In en, this message translates to:
  /// **'Amber'**
  String get colorAmber;

  /// No description provided for @colorRose.
  ///
  /// In en, this message translates to:
  /// **'Rose'**
  String get colorRose;

  /// No description provided for @colorIceBlue.
  ///
  /// In en, this message translates to:
  /// **'Ice Blue'**
  String get colorIceBlue;

  /// No description provided for @clockStyleMinimal.
  ///
  /// In en, this message translates to:
  /// **'Minimal'**
  String get clockStyleMinimal;

  /// No description provided for @clockStyleMinimalDescription.
  ///
  /// In en, this message translates to:
  /// **'Thin, elegant font (Default)'**
  String get clockStyleMinimalDescription;

  /// No description provided for @clockStyleBold.
  ///
  /// In en, this message translates to:
  /// **'Bold'**
  String get clockStyleBold;

  /// No description provided for @clockStyleBoldDescription.
  ///
  /// In en, this message translates to:
  /// **'Thick, highly visible font'**
  String get clockStyleBoldDescription;

  /// No description provided for @clockStyleRetro.
  ///
  /// In en, this message translates to:
  /// **'Retro'**
  String get clockStyleRetro;

  /// No description provided for @clockStyleRetroDescription.
  ///
  /// In en, this message translates to:
  /// **'Monospaced, retro terminal style'**
  String get clockStyleRetroDescription;

  /// No description provided for @clockStyleElegant.
  ///
  /// In en, this message translates to:
  /// **'Elegant'**
  String get clockStyleElegant;

  /// No description provided for @clockStyleElegantDescription.
  ///
  /// In en, this message translates to:
  /// **'Classic serif typeface'**
  String get clockStyleElegantDescription;

  /// No description provided for @clockStyleNeon.
  ///
  /// In en, this message translates to:
  /// **'Neon'**
  String get clockStyleNeon;

  /// No description provided for @clockStyleNeonDescription.
  ///
  /// In en, this message translates to:
  /// **'Ultra-thin, glowing style'**
  String get clockStyleNeonDescription;

  /// No description provided for @clockStylePixel.
  ///
  /// In en, this message translates to:
  /// **'Pixel'**
  String get clockStylePixel;

  /// No description provided for @clockStylePixelDescription.
  ///
  /// In en, this message translates to:
  /// **'Bold monospaced, arcade feel'**
  String get clockStylePixelDescription;

  /// No description provided for @clockStyleDigital.
  ///
  /// In en, this message translates to:
  /// **'Digital'**
  String get clockStyleDigital;

  /// No description provided for @clockStyleDigitalDescription.
  ///
  /// In en, this message translates to:
  /// **'Clean monospaced display'**
  String get clockStyleDigitalDescription;

  /// No description provided for @brightnessPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Permission Required'**
  String get brightnessPermissionRequired;

  /// No description provided for @brightnessPermissionHelp.
  ///
  /// In en, this message translates to:
  /// **'To control brightness on this device, you must grant permission via ADB:'**
  String get brightnessPermissionHelp;

  /// No description provided for @brightnessExperimentalNotice.
  ///
  /// In en, this message translates to:
  /// **'EXPERIMENTAL: This feature is untested and may be removed in future versions based on user feedback.'**
  String get brightnessExperimentalNotice;

  /// No description provided for @brightnessDeviceSupportNote.
  ///
  /// In en, this message translates to:
  /// **'Note: Some Android TV devices may not support app-level brightness control.'**
  String get brightnessDeviceSupportNote;

  /// No description provided for @enableBrightnessScheduler.
  ///
  /// In en, this message translates to:
  /// **'Enable Scheduler'**
  String get enableBrightnessScheduler;

  /// No description provided for @currentBrightnessSlot.
  ///
  /// In en, this message translates to:
  /// **'Current: {slot}'**
  String currentBrightnessSlot(String slot);

  /// No description provided for @brightnessSlotMorning.
  ///
  /// In en, this message translates to:
  /// **'6 AM - 9 AM'**
  String get brightnessSlotMorning;

  /// No description provided for @brightnessSlotDay.
  ///
  /// In en, this message translates to:
  /// **'9 AM - 3 PM'**
  String get brightnessSlotDay;

  /// No description provided for @brightnessSlotAfternoon.
  ///
  /// In en, this message translates to:
  /// **'3 PM - 6 PM'**
  String get brightnessSlotAfternoon;

  /// No description provided for @brightnessSlotEvening.
  ///
  /// In en, this message translates to:
  /// **'6 PM - 10 PM'**
  String get brightnessSlotEvening;

  /// No description provided for @brightnessSlotNight.
  ///
  /// In en, this message translates to:
  /// **'10 PM - 6 AM'**
  String get brightnessSlotNight;

  /// No description provided for @showWeather.
  ///
  /// In en, this message translates to:
  /// **'Show weather'**
  String get showWeather;

  /// No description provided for @weatherLocation.
  ///
  /// In en, this message translates to:
  /// **'Weather location'**
  String get weatherLocation;

  /// No description provided for @weatherCityName.
  ///
  /// In en, this message translates to:
  /// **'City name'**
  String get weatherCityName;

  /// No description provided for @weatherSearch.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get weatherSearch;

  /// No description provided for @weatherNoResults.
  ///
  /// In en, this message translates to:
  /// **'No cities found'**
  String get weatherNoResults;

  /// No description provided for @weatherSearchFailed.
  ///
  /// In en, this message translates to:
  /// **'Search failed. Check the network connection.'**
  String get weatherSearchFailed;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es', 'tr', 'vi'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'tr':
      return AppLocalizationsTr();
    case 'vi':
      return AppLocalizationsVi();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
