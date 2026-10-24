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

import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'focusable_settings_tile.dart';
import 'launcher_sections_panel_page.dart';
import 'watch_next_panel_page.dart';
import 'wallpaper_panel_page.dart';
import 'status_bar_panel_page.dart';
import 'accent_color_page.dart';
import 'appearance_panel_page.dart';
import 'misc_panel_page.dart';

class InterfaceSettingsPage extends StatelessWidget {
  static const String routeName = "interface_settings_panel";

  const InterfaceSettingsPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        SettingsPageHeader(title: localizations.interface),
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                FocusableSettingsTile(
                  showChevron: true,
                  autofocus: true,
                  leading: const Icon(Icons.category),
                  title: Text(localizations.launcherSections, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(LauncherSectionsPanelPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.play_circle_outline),
                  title: Text(localizations.watchNextSectionTitle, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(WatchNextPanelPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.wallpaper_outlined),
                  title: Text(localizations.wallpaper, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(WallpaperPanelPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.tips_and_updates),
                  title: Text(localizations.statusBar, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(StatusBarPanelPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.palette_outlined),
                  title: Text(localizations.accentColor, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(AccentColorPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.brush_outlined),
                  title: Text(localizations.appearanceSettings, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(AppearancePanelPage.routeName),
                ),
                FocusableSettingsTile(
                  showChevron: true,
                  leading: const Icon(Icons.miscellaneous_services),
                  title: Text(localizations.miscellaneous, style: Theme.of(context).textTheme.bodyMedium),
                  onPressed: () => Navigator.of(context).pushNamed(MiscPanelPage.routeName),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
