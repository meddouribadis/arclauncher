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

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/unsplash_slideshow.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Lets the user tick the slideshow categories used by day and by night.
class SlideshowSourcesPanelPage extends StatelessWidget {
  static const String routeName = "slideshow_sources_panel";


  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        SettingsPageHeader(title: localizations.slideshowCategories),
        Expanded(
          child: Consumer<SettingsService>(
            builder: (_, settings, __) => ListView(
              children: [
                _header(context, Icons.wb_sunny, localizations.slideshowDay),
                ..._switches(settings, day: true, selected: settings.unsplashDaySources),
                _header(context, Icons.nights_stay, localizations.slideshowNight),
                ..._switches(settings, day: false, selected: settings.unsplashNightSources),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _header(BuildContext context, IconData icon, String text) => Padding(
        padding: const EdgeInsets.fromLTRB(8, 16, 8, 4),
        child: Row(children: [
          Icon(icon, size: 18),
          const SizedBox(width: 8),
          Text(text, style: Theme.of(context).textTheme.titleSmall),
        ]),
      );

  Iterable<Widget> _switches(SettingsService settings, {required bool day, required List<String> selected}) =>
      slideshowSources.indexed.map((entry) {
        final (index, source) = entry;
        return EnsureVisible(
          alignment: 0.5,
          child: RoundedSwitchListTile(
            autofocus: day && index == 0,
            title: Text(source.label),
            secondary: Icon(source.icon),
            value: selected.contains(source.key),
            onChanged: (checked) => settings.setUnsplashSources(
              day: day,
              keys: checked ? [...selected, source.key] : selected.where((k) => k != source.key).toList(),
            ),
          ),
        );
      });
}
