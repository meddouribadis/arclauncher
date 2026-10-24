import 'dart:typed_data';

import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/widgets/settings/applications_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:flauncher/l10n/app_localizations.dart';

import '../../mocks.dart';
import '../../mocks.mocks.dart';

void main() {
  setUpAll(() async {
    final binding = TestWidgetsFlutterBinding.ensureInitialized();
    binding.window.physicalSizeTestValue = const Size(1280, 720);
    binding.window.devicePixelRatioTestValue = 1.0;
  });

  testWidgets("Left/Right arrow keys switch categories in ApplicationsPanelPage", (tester) async {
    final appsService = MockAppsService();
    final transparentPng = Uint8List.fromList([
      0x89, 0x50, 0x4E, 0x47, 0x0D, 0x0A, 0x1A, 0x0A, 0x00, 0x00, 0x00, 0x0D,
      0x49, 0x48, 0x44, 0x52, 0x00, 0x00, 0x00, 0x01, 0x00, 0x00, 0x00, 0x01,
      0x08, 0x06, 0x00, 0x00, 0x00, 0x1F, 0x15, 0xC4, 0x89, 0x00, 0x00, 0x00,
      0x0A, 0x49, 0x44, 0x41, 0x54, 0x78, 0x9C, 0x63, 0x00, 0x01, 0x00, 0x00,
      0x05, 0x00, 0x01, 0x0D, 0x0A, 0x2D, 0xB4, 0x00, 0x00, 0x00, 0x00, 0x49,
      0x45, 0x4E, 0x44, 0xAE, 0x42, 0x60, 0x82
    ]);
    when(appsService.getAppIcon(any)).thenAnswer((_) => Future.value(transparentPng));

    // Setup some fake apps to populate tabs
    when(appsService.applications).thenReturn([
      fakeApp(packageName: "pkg.tv", name: "TV App", sideloaded: false, hidden: false),
      fakeApp(packageName: "pkg.sideload", name: "Sideload App", sideloaded: true, hidden: false),
    ]);
    // Mock category for favorites (even if empty)
    when(appsService.categories).thenReturn([]); 

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<AppsService>.value(value: appsService),
        ],
        builder: (_, __) => MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: ApplicationsPanelPage()),
          onGenerateRoute: (settings) => MaterialPageRoute(builder: (_) => Container()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    // Initial state: All Apps (index 0)
    expect(find.text("All Apps"), findsWidgets, reason: "Should start on All Apps tab");

    // Focus on the list
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
    
    // Simulate Right Arrow
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowRight);
    await tester.pumpAndSettle();

    // Should now be on Favorite Apps (index 1)
    expect(find.text("Favorite Apps"), findsWidgets, reason: "Should switch to Favorite Apps after Right Arrow");

    // Simulate Left Arrow
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();

    // Should be back on All Apps (index 0)
    expect(find.text("All Apps"), findsWidgets, reason: "Should switch back to All Apps after Left Arrow");
    expect(find.text("TV App"), findsOneWidget);

    // Check boundary (Left on first tab)
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowLeft);
    await tester.pumpAndSettle();
    expect(find.text("All Apps"), findsWidgets, reason: "Should stay on All Apps when pressing Left on first tab");
  });
}
