import 'package:flauncher/providers/launcher_state.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/focus_aware_app_bar.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  group('FocusAwareAppBar', () {
    late MockSettingsService settingsService;
    late LauncherState launcherState;
    late GlobalKey<FocusAwareAppBarState> appBarKey;

    setUp(() {
      settingsService = MockSettingsService();
      launcherState = LauncherState();
      appBarKey = GlobalKey<FocusAwareAppBarState>();

      when(settingsService.autoHideAppBarEnabled).thenReturn(false);
      when(settingsService.hideStatusBarInGrid).thenReturn(false);
      when(settingsService.showDateInStatusBar).thenReturn(false);
      when(settingsService.showTimeInStatusBar).thenReturn(true);
      when(settingsService.showWifiWidgetInStatusBar).thenReturn(false);
      when(settingsService.showNetworkIndicatorInStatusBar).thenReturn(false);
      when(settingsService.timeFormat).thenReturn('HH:mm');
      when(settingsService.dateFormat).thenReturn('yyyy-MM-dd');
      when(settingsService.accentColorHex).thenReturn('6750A4');
    });

    Widget createTestWidget() {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<LauncherState>.value(value: launcherState),
        ],
        child: MaterialApp(
          home: Scaffold(
            appBar: FocusAwareAppBar(key: appBarKey),
            body: const SizedBox.expand(),
          ),
        ),
      );
    }

    testWidgets('status bar is fully visible when neither autoHide nor hideInGrid is active', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
      final container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      final opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      expect(container.constraints?.maxHeight, kToolbarHeight);
      expect(opacity.opacity, 1.0);
    });

    testWidgets('hides status bar when in grid if hideStatusBarInGrid is true', (tester) async {
      when(settingsService.hideStatusBarInGrid).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially on home/dock (appGridFocused is false), status bar is visible
      AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      expect(container.constraints?.maxHeight, kToolbarHeight);
      expect(opacity.opacity, 1.0);

      // User navigates down into the grid
      launcherState.setAppGridFocused(true);
      await tester.pumpAndSettle();

      // Status bar should be hidden
      container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      expect(container.constraints?.maxHeight, 0.0);
      expect(opacity.opacity, 0.0);

      // User navigates back up to dock
      launcherState.setAppGridFocused(false);
      await tester.pumpAndSettle();

      // Status bar should be visible again
      container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      expect(container.constraints?.maxHeight, kToolbarHeight);
      expect(opacity.opacity, 1.0);
    });

    testWidgets('remains visible in grid if hideStatusBarInGrid is false', (tester) async {
      when(settingsService.hideStatusBarInGrid).thenReturn(false);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      launcherState.setAppGridFocused(true);
      await tester.pumpAndSettle();

      expect(find.byType(AppBar), findsOneWidget);
    });

    testWidgets('focusing settings button makes status bar visible even when autoHide is true', (tester) async {
      when(settingsService.autoHideAppBarEnabled).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Initially auto-hidden
      AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      AnimatedOpacity opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      IgnorePointer ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(IgnorePointer)),
      );
      expect(container.constraints?.maxHeight, 0.0);
      expect(opacity.opacity, 0.0);
      expect(ignorePointer.ignoring, isTrue);

      // Focus settings
      appBarKey.currentState?.focusSettings();
      await tester.pumpAndSettle();

      container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      opacity = tester.widget<AnimatedOpacity>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedOpacity)),
      );
      ignorePointer = tester.widget<IgnorePointer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(IgnorePointer)),
      );
      expect(container.constraints?.maxHeight, kToolbarHeight);
      expect(opacity.opacity, 1.0);
      expect(ignorePointer.ignoring, isFalse);
    });

    testWidgets('focusing settings resets appGridFocused and reveals status bar', (tester) async {
      when(settingsService.hideStatusBarInGrid).thenReturn(true);

      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      launcherState.setAppGridFocused(true);
      await tester.pumpAndSettle();

      expect(launcherState.appGridFocused, isTrue);
      AnimatedContainer container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      expect(container.constraints?.maxHeight, 0.0);

      appBarKey.currentState?.focusSettings();
      await tester.pumpAndSettle();

      expect(launcherState.appGridFocused, isFalse);
      container = tester.widget<AnimatedContainer>(
        find.descendant(of: find.byType(FocusAwareAppBar), matching: find.byType(AnimatedContainer)),
      );
      expect(container.constraints?.maxHeight, kToolbarHeight);
    });
  });
}
