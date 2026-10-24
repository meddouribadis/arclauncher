/*
 * FLauncher
 * Copyright (C) 2026 LeanBitLab
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNextMaxItemsPage extends StatelessWidget {
  static const String routeName = "watch_next_max_items_panel";

  const WatchNextMaxItemsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<SettingsService>(
      builder: (context, service, _) {
        final currentMax = service.watchNextMaxItems;

        return Column(
          children: [
            SettingsPageHeader(title: localizations.watchNextMaxItems),
            Expanded(
              child: ListView(
                children: [
                  for (final count in WATCH_NEXT_MAX_ITEMS_OPTIONS)
                    _radioTile(
                      context,
                      service,
                      count == 0 ? localizations.watchNextMaxItemsUnlimited : '$count',
                      count,
                      autofocus: currentMax == count,
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _radioTile(
    BuildContext context,
    SettingsService service,
    String label,
    int value, {
    bool autofocus = false,
  }) {
    final isSelected = service.watchNextMaxItems == value;
    return FocusableSettingsTile(
      autofocus: autofocus,
      frameLeading: false,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onPressed: () => service.setWatchNextMaxItems(value),
    );
  }
}
