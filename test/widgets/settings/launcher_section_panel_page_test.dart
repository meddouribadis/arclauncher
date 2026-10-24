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
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
    // Scale-down the font size because the font 'Ahem' used when running tests is much wider than Roboto
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("Category is displayed", (tester) async {
    final appsService = MockAppsService();
    final favoritesCategory =
        fakeCategory(name: "Favorites", sort: CategorySort.alphabetical, type: CategoryType.grid, columnsCount: 6);
    when(appsService.launcherSections).thenReturn([
      favoritesCategory,
      fakeCategory(name: "Applications"),
    ]);

    await _pumpWidgetWithProviders(tester, appsService, 0);

    expect(find.text("Favorites"), findsWidgets);
    expect(find.text("Alphabetical"), findsOneWidget);
    expect(find.text("Grid"), findsOneWidget);
    expect(find.text("6"), findsOneWidget);
  });

  testWidgets("Spacer is displayed", (tester) async {
    final appsService = MockAppsService();
    final spacer = LauncherSpacer(id: 1, height: 20);
    when(appsService.launcherSections).thenReturn([
      spacer,
    ]);

    await _pumpWidgetWithProviders(tester, appsService, 0);

    expect(find.text("20"), findsOneWidget);
  });

  testWidgets("'Delete' calls AppsService.deleteSection", (tester) async {
    final appsService = MockAppsService();
    final favoritesCategory =
        fakeCategory(name: "Favorites", sort: CategorySort.alphabetical, type: CategoryType.row, rowHeight: 110);
    when(appsService.launcherSections).thenReturn([
      favoritesCategory,
    ]);
    when(appsService.deleteSection(0)).thenAnswer((_) async {});

    await _pumpWidgetWithProviders(tester, appsService, 0);

    final deleteFinder = find.widgetWithText(FilledButton, "Delete");
    expect(deleteFinder, findsOneWidget);
    await tester.tap(deleteFinder);
    await tester.pumpAndSettle();

    verify(appsService.deleteSection(0)).called(1);
  });
}

Future<void> _pumpWidgetWithProviders(WidgetTester tester, AppsService appsService, int? sectionIndex) async {
  await tester.pumpWidget(
    MultiProvider(
      providers: [
        ChangeNotifierProvider<AppsService>.value(value: appsService),
      ],
      builder: (_, __) => MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: LauncherSectionPanelPage(sectionIndex: sectionIndex)),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
