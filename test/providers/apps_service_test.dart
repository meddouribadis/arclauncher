import 'dart:io';

import 'package:drift/drift.dart';
import 'package:flauncher/database.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  group("removeCustomAppBanner", () {
    setUp(() async {
      SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    });

    test("removes custom banner and deletes file if it exists", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      // Create a temp file
      final tempFile = await File('${Directory.systemTemp.path}/test_banner.png').create();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_banner_test.app', tempFile.path);

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      await appsService.removeCustomAppBanner('test.app');

      expect(await tempFile.exists(), isFalse);
      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });

    test("handles file deletion errors gracefully", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('custom_banner_test.app', '/invalid/path/that/does/not/exist.png');

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      // Should not throw an exception
      await appsService.removeCustomAppBanner('test.app');

      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });

    test("works when custom banner path is null", () async {
      final channel = MockFLauncherChannel();
      final database = MockFLauncherDatabase();
      final appsService = await _buildInitialisedAppsService(channel, database);

      final prefs = await SharedPreferences.getInstance();

      var notified = false;
      appsService.addListener(() {
        notified = true;
      });

      // Should not throw an exception
      await appsService.removeCustomAppBanner('test.app');

      expect(prefs.containsKey('custom_banner_test.app'), isFalse);
      expect(notified, isTrue);
    });
  });
}

Future<AppsService> _buildInitialisedAppsService(
  MockFLauncherChannel channel,
  MockFLauncherDatabase database,
) async {
  when(channel.getApplications()).thenAnswer((_) => Future.value([]));
  when(database.getApplications()).thenAnswer((_) => Future.value([]));
  when(database.getAppsCategories()).thenAnswer((_) => Future.value([]));
  when(database.getCategories()).thenAnswer((_) => Future.value([]));
  when(database.getLauncherSpacers()).thenAnswer((_) => Future.value([]));
  when(database.transaction(any)).thenAnswer((realInvocation) => realInvocation.positionalArguments[0]());
  when(database.wasCreated).thenReturn(false);
  final appsService = AppsService(channel, database);
  await untilCalled(channel.addAppsChangedListener(any));
  clearInteractions(channel);
  clearInteractions(database);
  return appsService;
}
