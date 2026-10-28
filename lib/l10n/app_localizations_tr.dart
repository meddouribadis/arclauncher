// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get aboutFlauncher => 'Arc Launcher Hakkında';

  @override
  String get addCategory => 'Kategori ekle';

  @override
  String get addSection => 'Bölüm ekle';

  @override
  String get alphabetical => 'Alfabetik';

  @override
  String get appCardHighlightAnimation => 'Uygulama kartı vurgulama animasyonu';

  @override
  String get showFocusBorders => 'Odak kenarlıklarını göster';

  @override
  String get focusBorderThickness => 'Odak kenarlık kalınlığı';

  @override
  String get focusBorderThin => 'İnce (1.0 dp)';

  @override
  String get focusBorderDefault => 'Varsayılan (1.5 dp)';

  @override
  String get focusBorderMedium => 'Orta (2.0 dp)';

  @override
  String get focusBorderBold => 'Kalın (3.0 dp)';

  @override
  String get appInfo => 'Uygulama bilgisi';

  @override
  String get appKeyClick => 'Tuşa basıldığında tıklama sesi';

  @override
  String get appearanceSettings => 'Görünüm';

  @override
  String get backgroundBlur => 'Arka plan bulanıklığı';

  @override
  String get dockBlur => 'Dock bulanıklığı';

  @override
  String get dockDarkBackground => 'Koyu dock arka planı';

  @override
  String get dockShadow => 'Dock gölgesi';

  @override
  String get applications => 'Uygulamalar';

  @override
  String get autoHideAppBar => 'Durum çubuğunu otomatik gizle';

  @override
  String get hideStatusBarInGrid => 'Durum çubuğunu ızgarada gizle';

  @override
  String get backButtonAction => 'Geri tuşu eylemi';

  @override
  String get category => 'Kategori';

  @override
  String get categories => 'Kategoriler';

  @override
  String get columnCount => 'Sütun sayısı';

  @override
  String get date => 'Tarih';

  @override
  String get dateAndTimeFormat => 'Tarih ve saat biçimi';

  @override
  String get delete => 'Sil';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Hiçbir şey yapma';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Ekran koruyucuyu göster';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Saati göster';

  @override
  String get dialogTextNoFileExplorer =>
      'Resim seçebilmek için lütfen bir dosya yöneticisi yükleyin.';

  @override
  String get dialogTitleBackButtonAction => 'Geri tuşu eylemini seçin';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Kategori)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Biçimlendirilmiş tarih: $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Biçimlendirilmiş saat: $timeString';
  }

  @override
  String get gradient => 'Gradyan';

  @override
  String get favoriteApps => 'Favori Uygulamalar';

  @override
  String get grid => 'Izgara';

  @override
  String get height => 'Yükseklik';

  @override
  String get hide => 'Gizle';

  @override
  String get hiddenApplications => 'Gizli Uygulamalar';

  @override
  String get launcherSections => 'Bölümler';

  @override
  String get layout => 'Düzen';

  @override
  String get loading => 'Yükleniyor';

  @override
  String get manual => 'Manuel';

  @override
  String get modifySection => 'Bölümü düzenle';

  @override
  String get mustNotBeEmpty => 'Boş olmamalıdır';

  @override
  String get name => 'Ad';

  @override
  String get newSection => 'Yeni bölüm';

  @override
  String get noDateFormatSpecified => 'Tarih biçimi belirtilmedi';

  @override
  String get noTimeFormatSpecified => 'Saat biçimi belirtilmedi';

  @override
  String get allApplications => 'Tüm Uygulamalar';

  @override
  String get nonTvApplications => 'TV Olmayan Uygulamalar';

  @override
  String get open => 'Aç';

  @override
  String get orSelectFormatSpecifiers => 'Veya biçim belirteçlerini seçin';

  @override
  String get picture => 'Resim';

  @override
  String removeFrom(String name) {
    return '$name içinden kaldır';
  }

  @override
  String get renameCategory => 'Kategoriyi yeniden adlandır';

  @override
  String get reorder => 'Yeniden sırala';

  @override
  String get row => 'Satır';

  @override
  String get rowHeight => 'Satır yüksekliği';

  @override
  String get save => 'Kaydet';

  @override
  String get spacer => 'Boşluk';

  @override
  String get spacerMaxHeightRequirement =>
      '0\'dan büyük ve 500\'e eşit veya küçük olmalıdır';

  @override
  String get statusBar => 'Durum çubuğu';

  @override
  String get settings => 'Ayarlar';

  @override
  String get show => 'Göster';

  @override
  String get showCategoryTitles => 'Kategori başlıklarını göster';

  @override
  String get sort => 'Sırala';

  @override
  String get systemSettings => 'Sistem ayarları';

  @override
  String get updateCheck => 'Güncellemeleri denetle';

  @override
  String get updateNoUpdateTitle => 'Güncelleme yok';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'Zaten en son sürümü ($currentVersion) kullanıyorsunuz.';
  }

  @override
  String get updateAvailableTitle => 'Güncelleme mevcut';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return '$latestVersion sürümü mevcut (geçerli: $currentVersion).';
  }

  @override
  String get updateChangelog => 'Yenilikler';

  @override
  String get updateDownloadButton => 'İndir';

  @override
  String get updateReadyToInstallTitle => 'Yüklemeye hazır';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return '$latestVersion sürümünün APK\'si indirildi. Yükleme şimdi başlatılsın mı?';
  }

  @override
  String get updateInstallButton => 'Yükle';

  @override
  String get updateInstallPermissionTitle => 'Yükleyici izni gerekli';

  @override
  String get updateInstallPermissionBody =>
      'Arc Launcher\'ın bilinmeyen uygulamaları yüklemesine izin verin, ardından güncellemeyi yeniden deneyin.';

  @override
  String get updateOpenPermissionSettingsButton => 'İzin ayarlarını aç';

  @override
  String get updateErrorGeneric =>
      'Güncelleme denetimi başarısız oldu. Lütfen tekrar deneyin.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'Arc Launcher, FLauncher tabanlı, Android TV için özelleştirilmiş açık kaynaklı bir başlatıcıdır.\n\nGeliştiren: Meddouri Badis.\nKaynak kodu $repoUrl adresinde mevcuttur.';
  }

  @override
  String get textEmptyCategory => 'Bu kategori boş.';

  @override
  String get time => 'Saat';

  @override
  String get titleStatusBarSettingsPage =>
      'Durum çubuğunda gösterilecekleri seçin';

  @override
  String get tvApplications => 'TV Uygulamaları';

  @override
  String get type => 'Tür';

  @override
  String get typeInTheDateFormat => 'Tarih biçimini yazın';

  @override
  String get typeInTheHourFormat => 'Saat biçimini yazın';

  @override
  String get uninstall => 'Kaldır';

  @override
  String get wallpaper => 'Duvar kağıdı';

  @override
  String get withEllipsisAddTo => 'Şuna ekle...';

  @override
  String get timeBasedWallpaper => 'Zamana dayalı duvar kağıdı';

  @override
  String get unsplashSlideshow => 'Unsplash slayt gösterisi';

  @override
  String get unsplashEnable => 'Unsplash fotoğraflarını göster';

  @override
  String get unsplashAccessKey => 'Unsplash erişim anahtarı';

  @override
  String get unsplashAccessKeyHelp =>
      'unsplash.com/developers adresinde ücretsiz bir uygulama oluşturun ve Access Key\'i yapıştırın.';

  @override
  String get unsplashNotSet => 'Ayarlanmadı';

  @override
  String get unsplashInterval => 'Değiştirme sıklığı';

  @override
  String unsplashIntervalMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get slideshowCategories => 'Kategoriler';

  @override
  String get slideshowDay => 'Gündüz (6:00 - 18:00)';

  @override
  String get slideshowNight => 'Gece (18:00 - 6:00)';

  @override
  String unsplashPhotoCredit(String author) {
    return 'Fotoğraf: $author / Unsplash';
  }

  @override
  String get pickDayWallpaper => 'Gündüz duvar kağıdını seç';

  @override
  String get pickNightWallpaper => 'Gece duvar kağıdını seç';

  @override
  String get video => 'Video';

  @override
  String get pickDayVideoWallpaper => 'Gündüz videosunu seç';

  @override
  String get pickNightVideoWallpaper => 'Gece videosunu seç';

  @override
  String get watchNextSectionTitle => 'Sıradaki İzlenecek';

  @override
  String get showWatchNextSection => 'Sıradaki İzlenecek Bölümünü Göster';

  @override
  String get watchNextPermissionTitle => 'Sıradaki İzlenecek izni gerekli';

  @override
  String get watchNextPermissionBody =>
      'İzlemeye devam et öğelerinizi göstermek için TV listelerine erişime izin verin.';

  @override
  String get watchNextGrantPermission => 'İzin ver';

  @override
  String get watchNextCheckPermission => 'Tekrar denetle';

  @override
  String get interface => 'Arayüz';

  @override
  String get system => 'Sistem';

  @override
  String get accentColor => 'Vurgu rengi';

  @override
  String get miscellaneous => 'Çeşitli';

  @override
  String get brightnessScheduler => 'Parlaklık zamanlayıcı';

  @override
  String get screensaverSettings => 'Ekran koruyucu ayarları';

  @override
  String get screensaverClockStyle => 'Ekran koruyucu saat stili';

  @override
  String get wifiUsagePeriod => 'Wi-Fi kullanım dönemi';

  @override
  String get showAppNamesBelowIcons => 'Simge altında uygulama adlarını göster';

  @override
  String get wifiUsage => 'Wi-Fi kullanımı';

  @override
  String get networkIndicator => 'Ağ göstergesi';

  @override
  String get showCpuLoad => 'CPU yükünü göster';

  @override
  String get customName => 'Özel ad';

  @override
  String get lastUsed => 'Son kullanım';

  @override
  String get daily => 'Günlük';

  @override
  String get weekly => 'Haftalık';

  @override
  String get monthly => 'Aylık';

  @override
  String get grantPermission => 'İzin ver';

  @override
  String get checkStatus => 'Durumu denetle';

  @override
  String get watchNextBigPictureMode => 'Sürükleyici mod';

  @override
  String get watchNextBigPictureModeDescription =>
      'İzle düğmeli tam ekran arka plan olarak göster';

  @override
  String get watchNextWatch => 'İzle';

  @override
  String get watchNextResume => 'Devam Et';

  @override
  String get watchNextRefresh => 'İçeriği yenile';

  @override
  String get watchNextRefreshDescription =>
      'Medya sağlayıcılarından önerileri yeniden yükle';

  @override
  String get watchNextRefreshed => 'Sıradakiler içeriği yenilendi';

  @override
  String get watchNextFilterApps => 'Uygulamaları filtrele';

  @override
  String get watchNextFilterAppsDescription =>
      'Hangi uygulamaların Sıradakiler bölümünde içerik göstereceğini seçin';

  @override
  String get watchNextNoApps =>
      'Şu anda Sıradakiler içeriği sağlayan medya uygulaması yok';

  @override
  String get watchNextShowAllApps => 'Yüklü tüm uygulamaları göster';

  @override
  String get watchNextHideWithoutImages => 'Resimsiz programları gizle';

  @override
  String get watchNextHideWithoutImagesDescription =>
      'Yalnızca afiş veya arka plan resmi olan programları göster';

  @override
  String get watchNextMaxItems => 'Maksimum program sayısı';

  @override
  String get watchNextMaxItemsDescription =>
      'Sıradakiler bölümünde gösterilen program sayısını sınırla';

  @override
  String get watchNextMaxItemsUnlimited => 'Sınırsız';

  @override
  String get redditWallpaper => 'Reddit duvar kağıdı';

  @override
  String get redditWallpaperEnable => 'Reddit fotoğraflarını göster';

  @override
  String get redditSubreddits => 'Subreddit\'ler';

  @override
  String get redditSort => 'Sırala';

  @override
  String get redditSortHot => 'Popüler';

  @override
  String get redditSortTopDay => 'En İyiler (Bugün)';

  @override
  String get redditSortTopWeek => 'En İyiler (Bu Hafta)';

  @override
  String get redditSortTopMonth => 'En İyiler (Bu Ay)';

  @override
  String get redditSortTopAll => 'En İyiler (Tüm Zamanlar)';

  @override
  String get redditSortNew => 'Yeni';

  @override
  String get redditInterval => 'Değiştirme sıklığı';

  @override
  String redditIntervalMinutes(int minutes) {
    return '$minutes dk';
  }

  @override
  String get redditInterval1Hour => '1 saat';

  @override
  String redditIntervalHours(int hours) {
    return '$hours saat';
  }

  @override
  String get redditInterval1Day => '1 gün';

  @override
  String redditIntervalDays(int days) {
    return '$days gün';
  }

  @override
  String get redditClientId => 'Reddit İstemci Kimliği (İsteğe bağlı)';

  @override
  String get redditClientIdHelp =>
      'İsteğe bağlı. reddit.com/prefs/apps adresinden yüklü uygulama oluşturup kimliğini yapıştırın.';

  @override
  String get redditChangeNow => 'Duvar kağıdını şimdi değiştir';

  @override
  String get redditAddSubreddit => 'Özel subreddit ekle';

  @override
  String get redditSubredditName => 'Subreddit adı (r/ olmadan)';

  @override
  String get redditSubredditAdded => 'Subreddit eklendi';

  @override
  String get redditSubredditInvalid => 'Lütfen geçerli bir subreddit adı girin';

  @override
  String get redditWallpaperUpdated => 'Duvar kağıdı başarıyla güncellendi';

  @override
  String get redditWallpaperFailed =>
      'Duvar kağıdı alınamadı. Sorun devam ederse ayarlardan bir Reddit İstemci Kimliği girin.';

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
