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

import 'dart:typed_data';

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/models/watch_next_item.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/settings/watch_next_panel_page.dart';
import 'package:flauncher/widgets/settings/watch_next_max_items_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

class MockWatchNextServiceForPanel extends ChangeNotifier implements WatchNextService {
  bool _forceRefreshed = false;
  final Set<String> _packages = {'com.plexapp.android', 'com.netflix.ninja'};

  bool get forceRefreshed => _forceRefreshed;

  @override
  Set<String> get availablePackageNames => _packages;

  @override
  bool get hasPermission => true;

  @override
  bool get hasItems => true;

  @override
  bool get hasVisibleSection => true;

  @override
  bool get isLoading => false;

  @override
  List<WatchNextItem> get items => [];

  @override
  int get activeHeroIndex => 0;

  @override
  WatchNextItem? get activeHeroItem => null;

  @override
  Future<void> forceRefresh() async {
    _forceRefreshed = true;
    notifyListeners();
  }

  @override
  Future<void> checkPermission() async {}

  @override
  void ensurePosterLoaded(String? uri) {}

  @override
  Uint8List? getCachedPoster(String? uri) => null;

  @override
  String? getPosterUriForItem(WatchNextItem? item) => null;

  @override
  bool hasPosterLoadFailed(String? uri) => false;

  @override
  bool itemHasImage(WatchNextItem item) => true;

  @override
  Future<void> launchItem(WatchNextItem item) async {}

  @override
  void nextHeroItem() {}

  @override
  void prevHeroItem() {}

  @override
  Future<void> refreshItems() async {}

  @override
  Future<void> refreshPermissionAndItems() async {}

  @override
  Future<void> requestPermission() async {}

  @override
  void setActiveHeroIndex(int index) {}
}

class FakeAppsServiceForPanel extends ChangeNotifier implements AppsService {
  @override
  List<App> get applications => [
        App(packageName: 'com.plexapp.android', name: 'Plex', version: '1.0', hidden: false),
        App(packageName: 'com.netflix.ninja', name: 'Netflix', version: '1.0', hidden: false),
      ];

  @override
  App? getApplication(String? packageName) {
    if (packageName == 'com.plexapp.android') {
      return App(packageName: 'com.plexapp.android', name: 'Plex', version: '1.0', hidden: false);
    }
    if (packageName == 'com.netflix.ninja') {
      return App(packageName: 'com.netflix.ninja', name: 'Netflix', version: '1.0', hidden: false);
    }
    return null;
  }

  @override
  Future<Uint8List> getAppIcon(String packageName) async => Uint8List(0);

  @override
  dynamic noSuchMethod(Invocation invocation) => super.noSuchMethod(invocation);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late SettingsService settingsService;
  late MockWatchNextServiceForPanel watchNextService;
  late FakeAppsServiceForPanel appsService;

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    settingsService = SettingsService(prefs);
    await settingsService.setShowWatchNextSection(true);

    watchNextService = MockWatchNextServiceForPanel();
    appsService = FakeAppsServiceForPanel();
  });

  Widget createTestWidget() {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ChangeNotifierProvider<WatchNextService>.value(value: watchNextService),
        ChangeNotifierProvider<AppsService>.value(value: appsService),
      ],
      child: const MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Scaffold(body: WatchNextPanelPage()),
      ),
    );
  }

  testWidgets('renders watch next settings, apps filter list and refresh button', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(find.text('Watch Next'), findsWidgets);
    expect(find.text('Maximum programs'), findsOneWidget);
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.text('Refresh content'), findsOneWidget);
    expect(find.text('Filter apps'), findsOneWidget);
    expect(find.text('Plex'), findsOneWidget);
    expect(find.text('Netflix'), findsOneWidget);
  });

  testWidgets('tapping refresh calls forceRefresh', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(watchNextService.forceRefreshed, isFalse);

    await tester.tap(find.text('Refresh content'));
    await tester.pumpAndSettle();

    expect(watchNextService.forceRefreshed, isTrue);
  });

  testWidgets('toggling an app switch updates excluded packages', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(settingsService.isWatchNextPackageExcluded('com.plexapp.android'), isFalse);

    // Scroll to Plex toggle and tap
    await tester.ensureVisible(find.text('Plex'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Plex'));
    await tester.pumpAndSettle();

    expect(settingsService.isWatchNextPackageExcluded('com.plexapp.android'), isTrue);

    // Tap Plex toggle again
    await tester.tap(find.text('Plex'));
    await tester.pumpAndSettle();

    expect(settingsService.isWatchNextPackageExcluded('com.plexapp.android'), isFalse);
  });

  testWidgets('toggling hide programs without image updates settings', (tester) async {
    await tester.pumpWidget(createTestWidget());
    await tester.pumpAndSettle();

    expect(settingsService.watchNextHideProgramsWithoutImages, isFalse);

    await tester.tap(find.text('Hide programs without image'));
    await tester.pumpAndSettle();

    expect(settingsService.watchNextHideProgramsWithoutImages, isTrue);

    await tester.tap(find.text('Hide programs without image'));
    await tester.pumpAndSettle();

    expect(settingsService.watchNextHideProgramsWithoutImages, isFalse);
  });

  testWidgets('WatchNextMaxItemsPage displays options and changes selection', (tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: WatchNextMaxItemsPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Maximum programs'), findsOneWidget);
    expect(find.text('Unlimited'), findsOneWidget);
    expect(find.text('10'), findsOneWidget);

    await tester.tap(find.text('10'));
    await tester.pumpAndSettle();

    expect(settingsService.watchNextMaxItems, equals(10));
  });
}
