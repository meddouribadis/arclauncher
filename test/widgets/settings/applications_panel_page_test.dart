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

import 'dart:typed_data';

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/settings/app_details_page.dart';
import 'package:flauncher/widgets/settings/applications_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

final Uint8List _fakePng = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4,
  0x89, 0x00, 0x00, 0x00, 0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
  0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E, 0x44, 0xAE,
  0x42, 0x60, 0x82,
]);

final Uint8List _fakePng2 = Uint8List.fromList(<int>[
  0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D, 0x49, 0x48, 0x44, 0x52,
  0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01, 0x08, 0x02, 0x00, 0x00, 0x00, 0x90, 0x77, 0x53,
  0xDE, 0x00, 0x00, 0x00, 0x0C, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0xF8, 0xCF, 0xC0, 0x00,
  0x00, 0x03, 0x01, 0x01, 0x00, 0x18, 0xDD, 0x8D, 0xB0, 0x00, 0x00, 0x00, 0x00, 0x49, 0x45, 0x4E,
  0x44, 0xAE, 0x42, 0x60, 0x82,
]);

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
    binding.platformDispatcher.textScaleFactorTestValue = 0.8;
  });

  testWidgets("All Applications tab displays unhidden apps", (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      hidden: false,
    );
    when(appsService.applications).thenReturn([app]);
    when(appsService.categories).thenReturn([]);
    when(appsService.getAppIcon(any)).thenAnswer((_) async => _fakePng);

    await _pumpWidgetWithProviders(tester, appsService);

    expect(find.text("All Apps"), findsOneWidget);
    expect(find.text("FLauncher"), findsOneWidget);
  });

  testWidgets("Hidden Applications tab displays hidden apps", (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      hidden: true,
    );
    when(appsService.applications).thenReturn([app]);
    when(appsService.categories).thenReturn([]);
    when(appsService.getAppIcon(any)).thenAnswer((_) async => _fakePng);

    await _pumpWidgetWithProviders(tester, appsService);

    // Switch to Hidden Apps tab via its icon
    await tester.tap(find.byIcon(Icons.visibility_off_outlined));
    await tester.pumpAndSettle();

    expect(find.text("Hidden Apps"), findsOneWidget);
    expect(find.text("FLauncher"), findsOneWidget);
  });

  testWidgets("Selecting an application opens AppDetailsPage", (tester) async {
    final appsService = MockAppsService();
    final app = fakeApp(
      packageName: "me.efesser.flauncher",
      name: "FLauncher",
      hidden: false,
    );
    when(appsService.applications).thenReturn([app]);
    when(appsService.categories).thenReturn([]);
    when(appsService.getAppIcon(any)).thenAnswer((_) async => _fakePng);

    await _pumpWidgetWithProviders(tester, appsService);

    await tester.tap(find.text("FLauncher"));
    await tester.pumpAndSettle();

    expect(find.byKey(const Key("AppDetailsPage")), findsOneWidget);
  });

  testWidgets("Hiding an app updates list without shifting icons of subsequent apps (fixes #17)", (tester) async {
    final app1 = fakeApp(packageName: "pkg.one", name: "App One", hidden: false);
    final app2 = fakeApp(packageName: "pkg.two", name: "App Two", hidden: false);
    final service = TestAppsService(
      apps: [app1, app2],
      icons: {"pkg.one": _fakePng, "pkg.two": _fakePng2},
    );

    await _pumpWidgetWithProviders(tester, service);

    var images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.length, 2);
    expect((images[0].image as MemoryImage).bytes, equals(_fakePng));
    expect((images[1].image as MemoryImage).bytes, equals(_fakePng2));

    // Hide app1 so only app2 remains in the list
    service.updateApps([app2]);
    await tester.pumpAndSettle();

    images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.length, 1);
    expect(find.text("App One"), findsNothing);
    expect(find.text("App Two"), findsOneWidget);
    // Crucial check: App Two must still have its own icon (_fakePng2), not App One's icon (_fakePng)
    expect((images[0].image as MemoryImage).bytes, equals(_fakePng2));
  });

  testWidgets("Installing a new app does not cause icon discrepancy for existing apps (fixes #90)", (tester) async {
    final appExisting = fakeApp(packageName: "pkg.two", name: "App Two", hidden: false);
    final service = TestAppsService(
      apps: [appExisting],
      icons: {"pkg.one": _fakePng, "pkg.two": _fakePng2},
    );

    await _pumpWidgetWithProviders(tester, service);

    var images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.length, 1);
    expect((images[0].image as MemoryImage).bytes, equals(_fakePng2));

    // New app is installed and inserted before App Two
    final appNew = fakeApp(packageName: "pkg.one", name: "App One", hidden: false);
    service.updateApps([appNew, appExisting]);
    await tester.pumpAndSettle();

    images = tester.widgetList<Image>(find.byType(Image)).toList();
    expect(images.length, 2);
    expect(find.text("App One"), findsOneWidget);
    expect(find.text("App Two"), findsOneWidget);
    expect((images[0].image as MemoryImage).bytes, equals(_fakePng));
    expect((images[1].image as MemoryImage).bytes, equals(_fakePng2));
  });

  testWidgets("App with empty or missing icon falls back to android icon placeholder gracefully", (tester) async {
    final appNoIcon = fakeApp(packageName: "pkg.noicon", name: "No Icon App", hidden: false);
    final service = TestAppsService(
      apps: [appNoIcon],
      icons: {"pkg.noicon": Uint8List(0)},
    );

    await _pumpWidgetWithProviders(tester, service);

    expect(find.text("No Icon App"), findsOneWidget);
    expect(find.byType(Image), findsNothing);
    expect(find.byIcon(Icons.android), findsOneWidget);
  });
}

class TestAppsService extends ChangeNotifier implements AppsService {
  List<App> apps;
  final Map<String, Uint8List> icons;

  TestAppsService({required this.apps, this.icons = const {}});

  @override
  List<App> get applications => apps;

  @override
  List<Category> get categories => [];

  @override
  Future<Uint8List> getAppIcon(String packageName) async {
    return icons[packageName] ?? Uint8List(0);
  }

  void updateApps(List<App> newApps) {
    apps = newApps;
    notifyListeners();
  }

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
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
          AppDetailsPage.routeName: (_) => const Scaffold(body: Text("Details", key: Key("AppDetailsPage"))),
        },
        home: const Scaffold(body: ApplicationsPanelPage()),
      ),
    ),
  );
  await tester.pumpAndSettle();
}
