import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flauncher/widgets/app_card_contour_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.dart';
import '../mocks.mocks.dart';

void main() {
  late MockSettingsService settings;
  late MockAppsService apps;

  setUp(() {
    settings = MockSettingsService();
    apps = MockAppsService();
    when(settings.accentColorHex).thenReturn('7C4DFF');
    when(settings.showFocusBorders).thenReturn(true);
    when(settings.focusBorderThickness).thenReturn(2);
    when(settings.appHighlightAnimationEnabled).thenReturn(true);
    when(apps.getAppBanner(any))
        .thenAnswer((_) async => throw StateError('Use fallback image'));
    FocusManager.instance.highlightStrategy =
        FocusHighlightStrategy.alwaysTraditional;
  });

  tearDown(() {
    FocusManager.instance.highlightStrategy = FocusHighlightStrategy.automatic;
  });

  Future<void> pumpCards(WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settings),
          ChangeNotifierProvider<AppsService>.value(value: apps),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(
            body: Center(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  for (var index = 0; index < 2; index++)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: SizedBox(
                        width: 240,
                        height: 135,
                        child: AppCard(
                          application: fakeApp(packageName: 'app.$index'),
                          category: fakeCategory(),
                          autofocus: index == 0,
                          onMove: (_) {},
                          onMoveEnd: () {},
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.pumpAndSettle(
      const Duration(milliseconds: 20),
      EnginePhase.sendSemanticsUpdate,
      const Duration(seconds: 2),
    );
  }

  Finder outlines() => find.byWidgetPredicate(
    (w) => w is CustomPaint && w.foregroundPainter is AppCardContourPainter,
  );

  Future<void> expectIdle(WidgetTester tester) async {
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
    await tester.pump(const Duration(seconds: 3));
    expect(tester.binding.transientCallbackCount, 0);
    expect(tester.binding.hasScheduledFrame, isFalse);
  }

  testWidgets(
    'focused app keeps its accent outline without scheduling idle frames',
    (tester) async {
      await pumpCards(tester);
      expect(
        tester.widget<InkWell>(find.byType(InkWell).first).focusNode!.hasFocus,
        isTrue,
      );
      final painter =
          tester.widget<CustomPaint>(outlines()).foregroundPainter!
              as AppCardContourPainter;
      expect(painter.alpha, 1);
      expect(painter.accentColor, const Color(0xFF7C4DFF));
      expect(painter.strokeWidth, 2);
      await expectIdle(tester);
    },
  );

  testWidgets('repeated focus changes finish their existing zoom animation', (
    tester,
  ) async {
    await pumpCards(tester);
    final nodes = tester
        .widgetList<InkWell>(find.byType(InkWell))
        .map((w) => w.focusNode!)
        .toList();
    for (final index in [1, 0, 1]) {
      nodes[index].requestFocus();
      await tester.pump();
      await tester.pumpAndSettle(
        const Duration(milliseconds: 20),
        EnginePhase.sendSemanticsUpdate,
        const Duration(seconds: 2),
      );
      expect(nodes[index].hasFocus, isTrue);
      expect(outlines(), findsOneWidget);
      await expectIdle(tester);
    }
  });

  testWidgets('disabled focus borders stay hidden without an idle ticker', (
    tester,
  ) async {
    when(settings.showFocusBorders).thenReturn(false);
    await pumpCards(tester);
    expect(outlines(), findsNothing);
    await expectIdle(tester);
  });
}
