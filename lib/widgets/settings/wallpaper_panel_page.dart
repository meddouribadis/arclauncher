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

import 'dart:io';

import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/gradient_panel_page.dart';
import 'package:flauncher/widgets/settings/reddit_wallpaper_panel_page.dart';
import 'package:flauncher/widgets/settings/unsplash_slideshow_panel_page.dart';
import 'package:flauncher/widgets/tv_media_picker.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

import 'package:flauncher/widgets/rounded_switch_list_tile.dart';

class WallpaperPanelPage extends StatelessWidget {
  static const String routeName = "wallpaper_panel";

  const WallpaperPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    AppLocalizations localizations = AppLocalizations.of(context)!;

    return Column(
      children: [
        SettingsPageHeader(title: localizations.wallpaper),
        Expanded(
          child: ListView(
            children: [
              Consumer<SettingsService>(
                builder: (_, settings, __) {
                  return RoundedSwitchListTile(
                    title: Text(localizations.timeBasedWallpaper),
                    secondary: Icon(Icons.access_time),
                    value: settings.timeBasedWallpaperEnabled,
                    onChanged: (value) => settings.setTimeBasedWallpaperEnabled(value),
                  );
                },
              ),
              Consumer<SettingsService>(
                builder: (_, settings, __) {
                  if (settings.timeBasedWallpaperEnabled) {
                    return Column(
                      children: [
                        FocusableSettingsTile(
                          leading: Icon(Icons.wb_sunny),
                          title: Text(localizations.pickDayWallpaper),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickWallpaperDayFromUri(media.uri), false),
                        ),
                        FocusableSettingsTile(
                          leading: Icon(Icons.videocam_outlined),
                          title: Text(localizations.pickDayVideoWallpaper),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickVideoWallpaperDay(File(media.path)), true),
                        ),
                        FocusableSettingsTile(
                          leading: Icon(Icons.nights_stay),
                          title: Text(localizations.pickNightWallpaper),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickWallpaperNightFromUri(media.uri), false),
                        ),
                        FocusableSettingsTile(
                          leading: Icon(Icons.videocam_outlined),
                          title: Text(localizations.pickNightVideoWallpaper),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickVideoWallpaperNight(File(media.path)), true),
                        ),
                      ],
                    );
                  } else {
                    return Column(
                      children: [
                        FocusableSettingsTile(
                          autofocus: true,
                          leading: Icon(Icons.gradient),
                          title: Text(localizations.gradient, style: Theme.of(context).textTheme.bodyMedium),
                          onPressed: () => Navigator.of(context).pushNamed(GradientPanelPage.routeName),
                        ),
                        FocusableSettingsTile(
                          leading: Icon(Icons.insert_drive_file_outlined),
                          title: Text(localizations.picture, style: Theme.of(context).textTheme.bodyMedium),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickWallpaperFromUri(media.uri), false),
                        ),
                        FocusableSettingsTile(
                          leading: Icon(Icons.videocam_outlined),
                          title: Text(localizations.video, style: Theme.of(context).textTheme.bodyMedium),
                          onPressed: () =>
                              _pickWallpaper(context, (s, media) => s.pickVideoWallpaper(File(media.path)), true),
                        ),
                      ],
                    );
                  }
                },
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.slideshow),
                title: Text(localizations.unsplashSlideshow),
                onPressed: () => Navigator.of(context).pushNamed(UnsplashSlideshowPanelPage.routeName),
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.photo_library_outlined),
                title: Text(localizations.redditWallpaper),
                onPressed: () => Navigator.of(context).pushNamed(RedditWallpaperPanelPage.routeName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickWallpaper(
    BuildContext context,
    Future<void> Function(WallpaperService, TvMediaSelection) action,
    bool isVideo,
  ) async {
    final media = await TvMediaPicker.show(context, mode: isVideo ? TvMediaPickerMode.video : TvMediaPickerMode.image);
    if (media != null && context.mounted) {
      await action(context.read<WallpaperService>(), media);
    }
  }
}
