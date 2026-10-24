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
import 'package:flauncher/models/category.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/settings/launcher_section_panel_page.dart';
import 'package:flauncher/widgets/settings/launcher_sections_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("Categories are displayed", (tester) async {
    final appsService = MockAppsService();
    when(appsService.launcherSections).thenReturn([
      fakeCategory(name: "Favorites"),
      fakeCategory(name: "Applications"),
    ]);

    await _pumpWidgetWithProviders(tester, appsService);

    expect(find.text("Favorites"), findsOneWidget);
    expect(find.text("Applications"), findsOneWidget);
  });

  testWidgets("Selecting a section opens LauncherSectionPanelPage", (tester) async {
    final appsService = MockAppsService();
    when(appsService.launcherSections).thenReturn([
      fakeCategory(name: "Favorites"),
      fakeCategory(name: "Applications"),
    ]);
    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.text("Favorites"));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("LauncherSectionPanelPage")), findsOneWidget);
  });

  testWidgets("'Add Section' opens LauncherSectionPanelPage", (tester) async {
    final appsService = MockAppsService();
    when(appsService.launcherSections).thenReturn([
      fakeCategory(name: "Favorites"),
      fakeCategory(name: "Applications"),
    ]);
    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.text("Add section"));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("LauncherSectionPanelPage")), findsOneWidget);
  });
}

Future<void> _pumpWidgetWithProviders(WidgetTester tester, AppsService appsService) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppsService>.value(value: appsService),
      ],
      builder: (_, __) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        routes: {
          LauncherSectionPanelPage.routeName: (_) => const Scaffold(body: Text("Section", key: Key("LauncherSectionPanelPage"))),
        },
        home: Scaffold(body: LauncherSectionsPanelPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
