// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get aboutFlauncher => 'À propos d\'Arc Launcher';

  @override
  String get addCategory => 'Ajouter une catégorie';

  @override
  String get addSection => 'Ajouter une section';

  @override
  String get alphabetical => 'Alphabétique';

  @override
  String get appCardHighlightAnimation =>
      'Animation de surbrillance des applis';

  @override
  String get showFocusBorders => 'Afficher les bordures de focus';

  @override
  String get focusBorderThickness => 'Épaisseur de la bordure de focus';

  @override
  String get focusBorderThin => 'Discrète (1,0 dp)';

  @override
  String get focusBorderDefault => 'Par défaut (1,5 dp)';

  @override
  String get focusBorderMedium => 'Moyenne (2,0 dp)';

  @override
  String get focusBorderBold => 'Épaisse (3,0 dp)';

  @override
  String get appInfo => 'Informations sur l\'application';

  @override
  String get appKeyClick => 'Son de clic à l\'appui sur une touche';

  @override
  String get appearanceSettings => 'Apparence';

  @override
  String get backgroundBlur => 'Flou d\'arrière-plan';

  @override
  String get dockBlur => 'Flou du dock';

  @override
  String get dockDarkBackground => 'Fond sombre du dock';

  @override
  String get dockShadow => 'Ombre du dock';

  @override
  String get applications => 'Applications';

  @override
  String get autoHideAppBar => 'Masquer automatiquement la barre d\'état';

  @override
  String get hideStatusBarInGrid => 'Masquer la barre d\'état dans la grille';

  @override
  String get backButtonAction => 'Action du bouton Retour';

  @override
  String get category => 'Catégorie';

  @override
  String get categories => 'Catégories';

  @override
  String get columnCount => 'Nombre de colonnes';

  @override
  String get date => 'Date';

  @override
  String get dateAndTimeFormat => 'Format de la date et de l\'heure';

  @override
  String get delete => 'Supprimer';

  @override
  String get dialogOptionBackButtonActionDoNothing => 'Ne rien faire';

  @override
  String get dialogOptionBackButtonActionShowScreensaver =>
      'Afficher l\'économiseur d\'écran';

  @override
  String get dialogOptionBackButtonActionShowClock => 'Afficher l\'horloge';

  @override
  String get dialogTextNoFileExplorer =>
      'Veuillez installer un explorateur de fichiers pour choisir une image.';

  @override
  String get dialogTitleBackButtonAction =>
      'Choisir l\'action du bouton Retour';

  @override
  String disambiguateCategoryTitle(String title) {
    return '$title (Catégorie)';
  }

  @override
  String formattedDate(String dateString) {
    return 'Date formatée : $dateString';
  }

  @override
  String formattedTime(String timeString) {
    return 'Heure formatée : $timeString';
  }

  @override
  String get gradient => 'Dégradé';

  @override
  String get favoriteApps => 'Applis favorites';

  @override
  String get grid => 'Grille';

  @override
  String get height => 'Hauteur';

  @override
  String get hide => 'Masquer';

  @override
  String get hiddenApplications => 'Applis masquées';

  @override
  String get launcherSections => 'Sections';

  @override
  String get layout => 'Disposition';

  @override
  String get loading => 'Chargement';

  @override
  String get manual => 'Manuel';

  @override
  String get modifySection => 'Modifier la section';

  @override
  String get mustNotBeEmpty => 'Ne doit pas être vide';

  @override
  String get name => 'Nom';

  @override
  String get newSection => 'Nouvelle section';

  @override
  String get noDateFormatSpecified => 'Aucun format de date indiqué';

  @override
  String get noTimeFormatSpecified => 'Aucun format d\'heure indiqué';

  @override
  String get allApplications => 'Toutes les applis';

  @override
  String get nonTvApplications => 'Applis hors TV';

  @override
  String get open => 'Ouvrir';

  @override
  String get orSelectFormatSpecifiers =>
      'Ou choisissez des spécificateurs de format';

  @override
  String get picture => 'Image';

  @override
  String removeFrom(String name) {
    return 'Retirer de $name';
  }

  @override
  String get renameCategory => 'Renommer la catégorie';

  @override
  String get reorder => 'Réorganiser';

  @override
  String get row => 'Ligne';

  @override
  String get rowHeight => 'Hauteur de ligne';

  @override
  String get save => 'Enregistrer';

  @override
  String get spacer => 'Espaceur';

  @override
  String get spacerMaxHeightRequirement =>
      'Doit être supérieur à 0 et inférieur ou égal à 500';

  @override
  String get statusBar => 'Barre d\'état';

  @override
  String get settings => 'Paramètres';

  @override
  String get show => 'Afficher';

  @override
  String get showCategoryTitles => 'Afficher les titres des catégories';

  @override
  String get sort => 'Trier';

  @override
  String get systemSettings => 'Paramètres système';

  @override
  String get updateCheck => 'Rechercher des mises à jour';

  @override
  String get updateNoUpdateTitle => 'Aucune mise à jour disponible';

  @override
  String updateNoUpdateBody(String currentVersion) {
    return 'Vous utilisez déjà la dernière version ($currentVersion).';
  }

  @override
  String get updateAvailableTitle => 'Mise à jour disponible';

  @override
  String updateAvailableBody(String latestVersion, String currentVersion) {
    return 'La version $latestVersion est disponible (actuelle : $currentVersion).';
  }

  @override
  String get updateChangelog => 'Nouveautés';

  @override
  String get updateDownloadButton => 'Télécharger';

  @override
  String get updateReadyToInstallTitle => 'Prêt à installer';

  @override
  String updateReadyToInstallBody(String latestVersion) {
    return 'L\'APK de la version $latestVersion est téléchargé. Lancer l\'installation maintenant ?';
  }

  @override
  String get updateInstallButton => 'Installer';

  @override
  String get updateInstallPermissionTitle =>
      'Autorisation d\'installation requise';

  @override
  String get updateInstallPermissionBody =>
      'Autorisez Arc Launcher à installer des applis inconnues, puis relancez la mise à jour.';

  @override
  String get updateOpenPermissionSettingsButton =>
      'Ouvrir les paramètres d\'autorisation';

  @override
  String get updateErrorGeneric =>
      'La recherche de mise à jour a échoué. Veuillez réessayer.';

  @override
  String textAboutDialog(String repoUrl) {
    return 'Arc Launcher est un launcher open source personnalisé pour Android TV, basé sur FLauncher.\n\nDéveloppé par Meddouri Badis.\nCode source disponible sur $repoUrl.';
  }

  @override
  String get textEmptyCategory => 'Cette catégorie est vide.';

  @override
  String get time => 'Heure';

  @override
  String get titleStatusBarSettingsPage =>
      'Choisir ce qui s\'affiche dans la barre d\'état';

  @override
  String get tvApplications => 'Applis TV';

  @override
  String get type => 'Type';

  @override
  String get typeInTheDateFormat => 'Saisissez le format de la date';

  @override
  String get typeInTheHourFormat => 'Saisissez le format de l\'heure';

  @override
  String get uninstall => 'Désinstaller';

  @override
  String get wallpaper => 'Fond d\'écran';

  @override
  String get withEllipsisAddTo => 'Ajouter à…';

  @override
  String get timeBasedWallpaper => 'Fond d\'écran selon l\'heure';

  @override
  String get unsplashSlideshow => 'Diaporama Unsplash';

  @override
  String get unsplashEnable => 'Afficher les photos Unsplash';

  @override
  String get unsplashAccessKey => 'Clé d\'accès Unsplash';

  @override
  String get unsplashAccessKeyHelp =>
      'Créez une appli gratuite sur unsplash.com/developers et collez sa clé d\'accès.';

  @override
  String get unsplashNotSet => 'Non défini';

  @override
  String get unsplashInterval => 'Changer toutes les';

  @override
  String unsplashIntervalMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get slideshowCategories => 'Catégories';

  @override
  String get slideshowDay => 'Jour (6:00 - 18:00)';

  @override
  String get slideshowNight => 'Nuit (18:00 - 6:00)';

  @override
  String unsplashPhotoCredit(String author) {
    return 'Photo : $author / Unsplash';
  }

  @override
  String get pickDayWallpaper => 'Choisir le fond d\'écran de jour';

  @override
  String get pickNightWallpaper => 'Choisir le fond d\'écran de nuit';

  @override
  String get video => 'Vidéo';

  @override
  String get pickDayVideoWallpaper => 'Choisir la vidéo de jour';

  @override
  String get pickNightVideoWallpaper => 'Choisir la vidéo de nuit';

  @override
  String get watchNextSectionTitle => 'À suivre';

  @override
  String get showWatchNextSection => 'Afficher la section À suivre';

  @override
  String get watchNextPermissionTitle => 'Autorisation « À suivre » requise';

  @override
  String get watchNextPermissionBody =>
      'Autorisez l\'accès aux programmes TV pour afficher vos contenus à reprendre.';

  @override
  String get watchNextGrantPermission => 'Accorder l\'autorisation';

  @override
  String get watchNextCheckPermission => 'Vérifier à nouveau';

  @override
  String get interface => 'Interface';

  @override
  String get system => 'Système';

  @override
  String get accentColor => 'Couleur d\'accentuation';

  @override
  String get miscellaneous => 'Divers';

  @override
  String get brightnessScheduler => 'Planificateur de luminosité';

  @override
  String get screensaverSettings => 'Paramètres de l\'économiseur d\'écran';

  @override
  String get screensaverClockStyle =>
      'Style d\'horloge de l\'économiseur d\'écran';

  @override
  String get wifiUsagePeriod => 'Période d\'utilisation du Wi-Fi';

  @override
  String get showAppNamesBelowIcons =>
      'Afficher le nom des applis sous les icônes';

  @override
  String get wifiUsage => 'Utilisation du Wi-Fi';

  @override
  String get networkIndicator => 'Indicateur réseau';

  @override
  String get customName => 'Nom personnalisé';

  @override
  String get lastUsed => 'Dernière utilisation';

  @override
  String get daily => 'Quotidien';

  @override
  String get weekly => 'Hebdomadaire';

  @override
  String get monthly => 'Mensuel';

  @override
  String get grantPermission => 'Accorder l\'autorisation';

  @override
  String get checkStatus => 'Vérifier l\'état';

  @override
  String get watchNextBigPictureMode => 'Mode immersif';

  @override
  String get watchNextBigPictureModeDescription =>
      'Afficher une grande image de fond avec un bouton de lecture';

  @override
  String get watchNextWatch => 'Regarder';

  @override
  String get watchNextResume => 'Reprendre';

  @override
  String get watchNextRefresh => 'Actualiser le contenu';

  @override
  String get watchNextRefreshDescription =>
      'Recharger les recommandations des fournisseurs de médias';

  @override
  String get watchNextRefreshed => 'Contenu « À suivre » actualisé';

  @override
  String get watchNextFilterApps => 'Filtrer les applis';

  @override
  String get watchNextFilterAppsDescription =>
      'Choisir les applis autorisées à afficher du contenu dans « À suivre »';

  @override
  String get watchNextNoApps =>
      'Aucune appli média ne fournit actuellement de contenu « À suivre »';

  @override
  String get watchNextShowAllApps => 'Afficher toutes les applis installées';

  @override
  String get watchNextHideWithoutImages => 'Masquer les programmes sans image';

  @override
  String get watchNextHideWithoutImagesDescription =>
      'N\'afficher que les programmes avec une affiche ou une image de fond';

  @override
  String get watchNextMaxItems => 'Nombre maximal de programmes';

  @override
  String get watchNextMaxItemsDescription =>
      'Limiter le nombre de programmes affichés dans « À suivre »';

  @override
  String get watchNextMaxItemsUnlimited => 'Illimité';

  @override
  String get redditWallpaper => 'Fond d\'écran Reddit';

  @override
  String get redditWallpaperEnable => 'Afficher les fonds d\'écran Reddit';

  @override
  String get redditSubreddits => 'Subreddits';

  @override
  String get redditSort => 'Trier par';

  @override
  String get redditSortHot => 'Populaires';

  @override
  String get redditSortTopDay => 'Top (aujourd\'hui)';

  @override
  String get redditSortTopWeek => 'Top (cette semaine)';

  @override
  String get redditSortTopMonth => 'Top (ce mois-ci)';

  @override
  String get redditSortTopAll => 'Top (de tous les temps)';

  @override
  String get redditSortNew => 'Nouveautés';

  @override
  String get redditInterval => 'Changer toutes les';

  @override
  String redditIntervalMinutes(int minutes) {
    return '$minutes min';
  }

  @override
  String get redditInterval1Hour => '1 heure';

  @override
  String redditIntervalHours(int hours) {
    return '$hours heures';
  }

  @override
  String get redditInterval1Day => '1 jour';

  @override
  String redditIntervalDays(int days) {
    return '$days jours';
  }

  @override
  String get redditClientId => 'Identifiant client Reddit (facultatif)';

  @override
  String get redditClientIdHelp =>
      'Facultatif. Créez une appli de type « installed app » sur reddit.com/prefs/apps et collez son identifiant si votre réseau l\'exige.';

  @override
  String get redditChangeNow => 'Changer le fond d\'écran maintenant';

  @override
  String get redditAddSubreddit => 'Ajouter un subreddit personnalisé';

  @override
  String get redditSubredditName => 'Nom du subreddit (sans r/)';

  @override
  String get redditSubredditAdded => 'Subreddit ajouté';

  @override
  String get redditSubredditInvalid =>
      'Veuillez saisir un nom de subreddit valide';

  @override
  String get redditWallpaperUpdated => 'Fond d\'écran mis à jour';

  @override
  String get redditWallpaperFailed =>
      'Impossible de récupérer le fond d\'écran. Si le problème persiste, configurez un identifiant client Reddit dans les paramètres.';

  @override
  String get addToFavorites => 'Ajouter aux favoris';

  @override
  String get removeFromFavorites => 'Retirer des favoris';

  @override
  String get addToCategory => 'Ajouter à une catégorie';

  @override
  String get setCustomBanner => 'Définir une bannière personnalisée';

  @override
  String get clearCustomBanner => 'Supprimer la bannière personnalisée';

  @override
  String customBannerSetFailed(String error) {
    return 'Impossible de définir la bannière : $error';
  }

  @override
  String customBannerClearFailed(String error) {
    return 'Impossible de supprimer la bannière : $error';
  }

  @override
  String get selectImage => 'Choisir une image';

  @override
  String get selectVideo => 'Choisir une vidéo';

  @override
  String mediaItemCount(int count) {
    return '$count éléments';
  }

  @override
  String get noImagesFound => 'Aucune image trouvée sur l\'appareil';

  @override
  String get noVideosFound => 'Aucune vidéo trouvée sur l\'appareil';

  @override
  String get mediaNavigationHint =>
      'Croix directionnelle : naviguer  •  Retour : annuler';

  @override
  String get mediaSelectionHint =>
      'Croix directionnelle : naviguer  •  OK : définir le fond d\'écran  •  Retour : annuler';

  @override
  String get mediaPermissionRequired =>
      'L\'autorisation d\'accès aux médias est requise';

  @override
  String get mediaPermissionHelp =>
      'Autorisez l\'accès pour parcourir les photos et les vidéos';

  @override
  String get preview => 'Aperçu';

  @override
  String get colorPurple => 'Violet';

  @override
  String get colorTeal => 'Sarcelle';

  @override
  String get colorBlue => 'Bleu';

  @override
  String get colorOrange => 'Orange';

  @override
  String get colorPink => 'Rose';

  @override
  String get colorGreen => 'Vert';

  @override
  String get colorWhite => 'Blanc';

  @override
  String get colorYellow => 'Jaune';

  @override
  String get colorRed => 'Rouge';

  @override
  String get colorCyan => 'Cyan';

  @override
  String get colorIndigo => 'Indigo';

  @override
  String get colorLime => 'Citron vert';

  @override
  String get colorAmber => 'Ambre';

  @override
  String get colorRose => 'Rose vif';

  @override
  String get colorIceBlue => 'Bleu glacier';

  @override
  String get clockStyleMinimal => 'Minimal';

  @override
  String get clockStyleMinimalDescription =>
      'Police fine et élégante (par défaut)';

  @override
  String get clockStyleBold => 'Gras';

  @override
  String get clockStyleBoldDescription => 'Police épaisse et très lisible';

  @override
  String get clockStyleRetro => 'Rétro';

  @override
  String get clockStyleRetroDescription => 'Chasse fixe, style terminal rétro';

  @override
  String get clockStyleElegant => 'Élégant';

  @override
  String get clockStyleElegantDescription => 'Police à empattements classique';

  @override
  String get clockStyleNeon => 'Néon';

  @override
  String get clockStyleNeonDescription => 'Style ultra-fin et lumineux';

  @override
  String get clockStylePixel => 'Pixel';

  @override
  String get clockStylePixelDescription => 'Chasse fixe grasse, esprit arcade';

  @override
  String get clockStyleDigital => 'Numérique';

  @override
  String get clockStyleDigitalDescription => 'Affichage à chasse fixe épuré';

  @override
  String get brightnessPermissionRequired => 'Autorisation requise';

  @override
  String get brightnessPermissionHelp =>
      'Pour contrôler la luminosité sur cet appareil, vous devez accorder l\'autorisation via ADB :';

  @override
  String get brightnessExperimentalNotice =>
      'EXPÉRIMENTAL : cette fonction n\'est pas testée et pourra être retirée dans une prochaine version selon les retours des utilisateurs.';

  @override
  String get brightnessDeviceSupportNote =>
      'Remarque : certains appareils Android TV ne gèrent pas le contrôle de la luminosité au niveau de l\'appli.';

  @override
  String get enableBrightnessScheduler => 'Activer le planificateur';

  @override
  String currentBrightnessSlot(String slot) {
    return 'Actuel : $slot';
  }

  @override
  String get brightnessSlotMorning => '6 h - 9 h';

  @override
  String get brightnessSlotDay => '9 h - 15 h';

  @override
  String get brightnessSlotAfternoon => '15 h - 18 h';

  @override
  String get brightnessSlotEvening => '18 h - 22 h';

  @override
  String get brightnessSlotNight => '22 h - 6 h';

  @override
  String get parentalControl => 'Contrôle parental';

  @override
  String get parentalSetCode => 'Définir un code';

  @override
  String get parentalChangeCode => 'Changer le code';

  @override
  String get parentalProtectApps => 'Protéger les applis sélectionnées';

  @override
  String get parentalProtectSettings => 'Protéger les paramètres du launcher';

  @override
  String get parentalAskAgain => 'Redemander le code maintenant';

  @override
  String get parentalTimeWindow => 'Seulement sur une plage horaire';

  @override
  String get parentalTimeWindowStart => 'La protection commence à';

  @override
  String get parentalTimeWindowEnd => 'La protection se termine à';

  @override
  String get parentalRestrictedAccess => 'Accès restreint';

  @override
  String get parentalNewCode => 'Nouveau code parental';

  @override
  String get parentalConfirmCode => 'Confirmer le code';

  @override
  String get parentalHintVerify =>
      'Saisissez le code avec les flèches/chiffres, puis appuyez sur OK';

  @override
  String parentalHintCreate(int count) {
    return 'Choisissez au moins $count flèches/chiffres, puis appuyez sur OK';
  }

  @override
  String get parentalHintConfirm =>
      'Saisissez à nouveau le même code, puis appuyez sur OK';

  @override
  String get parentalWrongCode => 'Code erroné';

  @override
  String parentalLocked(int seconds) {
    return 'Trop de tentatives. Réessayez dans $seconds s';
  }

  @override
  String parentalTooShort(int count) {
    return 'Au moins $count symboles';
  }

  @override
  String get parentalMismatch => 'Les codes ne correspondent pas, recommencez';
}
