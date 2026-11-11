import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/settings/status_bar_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

void main() {
  group('StatusBarPanelPage', () {
    late MockSettingsService settingsService;

    setUp(() {
      settingsService = MockSettingsService();
      when(settingsService.autoHideAppBarEnabled).thenReturn(false);
      when(settingsService.hideStatusBarInGrid).thenReturn(false);
      when(settingsService.showDateInStatusBar).thenReturn(false);
      when(settingsService.showTimeInStatusBar).thenReturn(true);
      when(settingsService.showCpuLoadInStatusBar).thenReturn(false);
      when(settingsService.setShowCpuLoadInStatusBar(any)).thenAnswer((_) async {});
      when(settingsService.showWifiWidgetInStatusBar).thenReturn(false);
      when(settingsService.showNetworkIndicatorInStatusBar).thenReturn(true);
      when(settingsService.setAutoHideAppBarEnabled(any)).thenAnswer((_) async {});
      when(settingsService.setHideStatusBarInGrid(any)).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<SettingsService>.value(
        value: settingsService,
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: StatusBarPanelPage()),
        ),
      );
    }

    testWidgets('renders hideStatusBarInGrid switch tile', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Hide status bar in grid'), findsOneWidget);
      expect(find.text('Automatically hide status bar'), findsOneWidget);
    });

    testWidgets('toggling the CPU load switch calls setShowCpuLoadInStatusBar', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Show CPU load'));
      await tester.pumpAndSettle();

      verify(settingsService.setShowCpuLoadInStatusBar(true)).called(1);
    });

    testWidgets('toggling hideStatusBarInGrid calls setHideStatusBarInGrid', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Hide status bar in grid'));
      await tester.pumpAndSettle();

      verify(settingsService.setHideStatusBarInGrid(true)).called(1);
    });
  });
}
