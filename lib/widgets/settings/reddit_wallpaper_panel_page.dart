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
import 'package:flauncher/providers/reddit_slideshow.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/reddit_subreddits_panel_page.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedditWallpaperPanelPage extends StatelessWidget {
  static const String routeName = "reddit_wallpaper_panel";

  const RedditWallpaperPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<SettingsService>(
      builder: (context, settings, _) {
        final hasClientId = settings.redditClientId.isNotEmpty;

        Future<void> editClientId() async {
          final clientId = await _askText(
            context,
            localizations.redditClientId,
            settings.redditClientId,
            help: localizations.redditClientIdHelp,
          );
          if (clientId != null) await settings.setRedditClientId(clientId);
        }

        return Column(
          children: [
            SettingsPageHeader(title: localizations.redditWallpaper),
            Expanded(
              child: ListView(
                children: [
                  RoundedSwitchListTile(
                    autofocus: true,
                    title: Text(localizations.redditWallpaperEnable),
                    secondary: const Icon(Icons.photo_library_outlined),
                    value: settings.redditWallpaperEnabled,
                    onChanged: (value) => settings.setRedditWallpaperEnabled(value),
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.explore_outlined),
                    title: Text(localizations.redditSubreddits),
                    trailing: Text(
                      settings.redditSubreddits.length == 1
                          ? 'r/${settings.redditSubreddits.first}'
                          : '${settings.redditSubreddits.length}',
                    ),
                    onPressed: () => Navigator.of(context).pushNamed(RedditSubredditsPanelPage.routeName),
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.sort),
                    title: Text(localizations.redditSort),
                    trailing: Text(_sortLabel(localizations, settings.redditSort)),
                    onPressed: () => settings.setRedditSort(_nextSort(settings.redditSort)),
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.timer_outlined),
                    title: Text(localizations.redditInterval),
                    trailing: Text(_intervalLabel(localizations, settings.redditIntervalMinutes)),
                    onPressed: () => settings.setRedditIntervalMinutes(_nextInterval(settings.redditIntervalMinutes)),
                  ),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.key_outlined),
                    title: Text(localizations.redditClientId),
                    trailing: Text(
                      hasClientId ? "••••${_tail(settings.redditClientId)}" : localizations.unsplashNotSet,
                    ),
                    onPressed: editClientId,
                  ),
                  if (settings.redditWallpaperEnabled)
                    FocusableSettingsTile(
                      leading: const Icon(Icons.refresh),
                      title: Text(localizations.redditChangeNow),
                      onPressed: () async {
                        final service = context.read<WallpaperService>();
                        final prevRev = service.wallpaperRevision;
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Row(
                              children: [
                                const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                                ),
                                const SizedBox(width: 12),
                                Text(localizations.redditChangeNow),
                              ],
                            ),
                            duration: const Duration(seconds: 10),
                          ),
                        );
                        await service.advanceRedditWallpaper();
                        if (context.mounted) {
                          final success = service.wallpaperRevision != prevRev;
                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                success ? localizations.redditWallpaperUpdated : localizations.redditWallpaperFailed,
                              ),
                              duration: const Duration(seconds: 4),
                            ),
                          );
                        }
                      },
                    ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  static String _tail(String key) => key.length <= 4 ? key : key.substring(key.length - 4);

  static String _intervalLabel(AppLocalizations localizations, int minutes) {
    if (minutes >= 1440) {
      final days = minutes ~/ 1440;
      return days == 1 ? localizations.redditInterval1Day : localizations.redditIntervalDays(days);
    } else if (minutes >= 60) {
      final hours = minutes ~/ 60;
      return hours == 1 ? localizations.redditInterval1Hour : localizations.redditIntervalHours(hours);
    } else {
      return localizations.redditIntervalMinutes(minutes);
    }
  }

  static int _nextInterval(int current) {
    const choices = SettingsService.redditIntervalChoices;
    final index = choices.indexOf(current);
    if (index == -1) return choices.first;
    return choices[(index + 1) % choices.length];
  }

  static String _nextSort(String current) {
    final values = RedditSort.values.map((s) => s.key).toList();
    final index = values.indexOf(current);
    if (index == -1) return values.first;
    return values[(index + 1) % values.length];
  }

  static String _sortLabel(AppLocalizations localizations, String key) {
    switch (key) {
      case 'hot':
        return localizations.redditSortHot;
      case 'top_day':
        return localizations.redditSortTopDay;
      case 'top_week':
        return localizations.redditSortTopWeek;
      case 'top_month':
        return localizations.redditSortTopMonth;
      case 'top_all':
        return localizations.redditSortTopAll;
      case 'new':
        return localizations.redditSortNew;
      default:
        return localizations.redditSortHot;
    }
  }

  Future<String?> _askText(BuildContext context, String title, String initialValue, {String? help}) =>
      showDialog<String>(
        context: context,
        builder: (context) => SimpleDialog(
          insetPadding: const EdgeInsets.only(bottom: 120),
          contentPadding: const EdgeInsets.all(24),
          title: Text(title),
          children: [
            if (help != null) Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(help)),
            TextFormField(
              autofocus: true,
              initialValue: initialValue,
              keyboardType: TextInputType.text,
              onFieldSubmitted: (value) => Navigator.of(context).pop(value),
            ),
          ],
        ),
      );
}
