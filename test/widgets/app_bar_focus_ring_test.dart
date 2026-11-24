import 'package:arclauncher/providers/launcher_state.dart';
import 'package:arclauncher/providers/settings_service.dart';
import 'package:arclauncher/widgets/app_bar_focus_ring.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

void main() {
  group('AppBarFocusRingPainter', () {
    test('shouldRepaint returns true when properties differ', () {
      const p1 = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: false,
        isHovered: false,
        isPressed: false,
        progress: 1.0,
      );
      const p2 = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: false,
        isHovered: false,
        isPressed: false,
        progress: 1.0,
      );
      const pFocused = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: true,
        isHovered: false,
        isPressed: false,
        progress: 1.0,
      );
      const pHovered = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: false,
        isHovered: true,
        isPressed: false,
        progress: 1.0,
      );
      const pPressed = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: false,
        isHovered: false,
        isPressed: true,
        progress: 1.0,
      );
      const pDifferentColor = AppBarFocusRingPainter(
        accentColor: Colors.red,
        isFocused: false,
        isHovered: false,
        isPressed: false,
        progress: 1.0,
      );
      const pDifferentProgress = AppBarFocusRingPainter(
        accentColor: Colors.blue,
        isFocused: false,
        isHovered: false,
        isPressed: false,
        progress: 0.5,
      );

      expect(p1.shouldRepaint(p2), isFalse);
      expect(p1.shouldRepaint(pFocused), isTrue);
      expect(p1.shouldRepaint(pHovered), isTrue);
      expect(p1.shouldRepaint(pPressed), isTrue);
      expect(p1.shouldRepaint(pDifferentColor), isTrue);
      expect(p1.shouldRepaint(pDifferentProgress), isTrue);
    });

    testWidgets('paints focused, hovered, pressed states without error', (tester) async {
      for (final state in [
        (focused: true, hovered: false, pressed: false),
        (focused: false, hovered: true, pressed: false),
        (focused: false, hovered: false, pressed: true),
        (focused: false, hovered: false, pressed: false),
      ]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: Center(
                child: CustomPaint(
                  size: const Size(40, 32),
                  painter: AppBarFocusRingPainter(
                    accentColor: Colors.blue,
                    isFocused: state.focused,
                    isHovered: state.hovered,
                    isPressed: state.pressed,
                    progress: 1.0,
                  ),
                ),
              ),
            ),
          ),
        );
        expect(tester.takeException(), isNull);
      }
    });

    testWidgets('handles empty or zero-progress gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: Size.zero,
                painter: AppBarFocusRingPainter(
                  accentColor: Colors.blue,
                  isFocused: true,
                  isHovered: false,
                  isPressed: false,
                  progress: 0.0,
                ),
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });

  group('AppBarFocusRing Widget', () {
    late MockSettingsService settingsService;
    late LauncherState launcherState;

    setUp(() {
      settingsService = MockSettingsService();
      launcherState = LauncherState();
      when(settingsService.accentColorHex).thenReturn('6750A4');
    });

    Widget createTestWidget({required VoidCallback onPressed, FocusNode? focusNode}) {
      return MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<LauncherState>.value(value: launcherState),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: Center(
              child: AppBarFocusRing(
                focusNode: focusNode,
                onPressed: onPressed,
                child: const Icon(Icons.settings),
              ),
            ),
          ),
        ),
      );
    }

    testWidgets('renders child icon and activates on tap', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(createTestWidget(onPressed: () => pressed = true));

      expect(find.byIcon(Icons.settings), findsOneWidget);

      await tester.tap(find.byType(AppBarFocusRing));
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
    });

    testWidgets('activates on keyboard enter when focused', (tester) async {
      bool pressed = false;
      final focusNode = FocusNode();

      await tester.pumpWidget(createTestWidget(onPressed: () => pressed = true, focusNode: focusNode));

      focusNode.requestFocus();
      await tester.pumpAndSettle();

      expect(focusNode.hasFocus, isTrue);

      await tester.sendKeyEvent(LogicalKeyboardKey.select);
      await tester.pumpAndSettle();

      expect(pressed, isTrue);
      focusNode.dispose();
    });
  });
}
