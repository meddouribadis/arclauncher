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
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/wallpaper_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

void main() {
  testWidgets("renders Unsplash slideshow tile below wallpaper options", (tester) async {
    final settingsService = MockSettingsService();
    final wallpaperService = MockWallpaperService();
    when(settingsService.timeBasedWallpaperEnabled).thenReturn(false);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<WallpaperService>.value(value: wallpaperService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WallpaperPanelPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Unsplash slideshow'), findsOneWidget);
    expect(find.text('Reddit wallpaper'), findsOneWidget);
    expect(find.text('Gradient'), findsOneWidget);

    final gradientTop = tester.getTopLeft(find.text('Gradient')).dy;
    final unsplashTop = tester.getTopLeft(find.text('Unsplash slideshow')).dy;
    final redditTop = tester.getTopLeft(find.text('Reddit wallpaper')).dy;

    expect(unsplashTop, greaterThan(gradientTop));
    expect(redditTop, greaterThan(unsplashTop));
  });
}
