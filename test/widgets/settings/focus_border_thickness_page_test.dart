import 'package:arclauncher/l10n/app_localizations.dart';
import 'package:arclauncher/providers/settings_service.dart';
import 'package:arclauncher/widgets/settings/focus_border_thickness_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

void main() {
  group('FocusBorderThicknessPage', () {
    late MockSettingsService settingsService;

    setUp(() {
      settingsService = MockSettingsService();
      when(settingsService.focusBorderThickness).thenReturn(FOCUS_BORDER_DEFAULT);
      when(settingsService.accentColorHex).thenReturn('6750A4');
      when(settingsService.setFocusBorderThickness(any)).thenAnswer((_) async {});
    });

    Widget createTestWidget() {
      return ChangeNotifierProvider<SettingsService>.value(
        value: settingsService,
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: FocusBorderThicknessPage()),
        ),
      );
    }

    testWidgets('renders all thickness options and preview card', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Focus border thickness'), findsOneWidget);
      expect(find.text('Subtle (1.0 dp)'), findsOneWidget);
      expect(find.text('Default (1.5 dp)'), findsOneWidget);
      expect(find.text('Medium (2.0 dp)'), findsOneWidget);
      expect(find.text('Bold (3.0 dp)'), findsOneWidget);
      expect(find.text('1.5 dp'), findsOneWidget);
    });

    testWidgets('selecting an option calls setFocusBorderThickness', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.text('Bold (3.0 dp)'));
      await tester.pumpAndSettle();

      verify(settingsService.setFocusBorderThickness(FOCUS_BORDER_BOLD)).called(1);
    });
  });
}
