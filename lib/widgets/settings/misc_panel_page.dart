
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/watch_next_panel_page.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

class MiscPanelPage extends StatelessWidget {
  static const String routeName = "misc_panel";

  const MiscPanelPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;
    SettingsService settingsService = Provider.of(context);

    return Column(
      children: [
        SettingsPageHeader(title: localizations.miscellaneous),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: settingsService.appHighlightAnimationEnabled,
                onChanged: (value) => settingsService.setAppHighlightAnimationEnabled(value),
                title: Text(localizations.appCardHighlightAnimation, style: Theme.of(context).textTheme.bodyMedium),
                secondary: Icon(Icons.filter_center_focus),
              ),
              RoundedSwitchListTile(
                value: settingsService.appKeyClickEnabled,
                onChanged: (value) => settingsService.setAppKeyClickEnabled(value),
                title: Text(localizations.appKeyClick, style: Theme.of(context).textTheme.bodyMedium),
                secondary: Icon(Icons.notifications_active),
              ),
              RoundedSwitchListTile(
                value: settingsService.showCategoryTitles,
                onChanged: (value) => settingsService.setShowCategoryTitles(value),
                title: Text(localizations.showCategoryTitles, style: Theme.of(context).textTheme.bodyMedium),
                secondary: Icon(Icons.abc),
              ),
              RoundedSwitchListTile(
                value: settingsService.showAppNamesBelowIcons,
                onChanged: (value) => settingsService.setShowAppNamesBelowIcons(value),
                title: Text(localizations.showAppNamesBelowIcons, style: Theme.of(context).textTheme.bodyMedium),
                secondary: Icon(Icons.subtitles),
              ),
              RoundedSwitchListTile(
                value: settingsService.showFocusBorders,
                onChanged: (value) => settingsService.setShowFocusBorders(value),
                title: Text(localizations.showFocusBorders, style: Theme.of(context).textTheme.bodyMedium),
                secondary: Icon(Icons.border_outer),
              ),
              FocusableSettingsTile(
                showChevron: true,
                leading: const Icon(Icons.play_circle_outline),
                title: Text(localizations.watchNextSectionTitle, style: Theme.of(context).textTheme.bodyMedium),
                onPressed: () => Navigator.of(context).pushNamed(WatchNextPanelPage.routeName),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
