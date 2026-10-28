import 'dart:async';

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/watch_next_item.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/watch_next_row.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';
import 'watch_next_hero_test.dart';

class _LoadingWatchNextService extends TestWatchNextService {
  bool loading = false;

  @override
  bool get isLoading => loading;

  void setLoading(bool value) {
    loading = value;
    notifyListeners();
  }
}

void main() {
  testWidgets('refresh keeps focus on the Watch Next card', (tester) async {
    final settings = MockSettingsService();
    when(settings.showWatchNextSection).thenReturn(true);
    when(settings.watchNextBigPictureMode).thenReturn(false);
    when(settings.showFocusBorders).thenReturn(true);
    when(settings.focusBorderThickness).thenReturn(1.5);
    when(settings.appKeyClickEnabled).thenReturn(false);

    final service = _LoadingWatchNextService();
    service.testItems = [
      WatchNextItem(id: 1, title: 'One'),
      WatchNextItem(id: 2, title: 'Two'),
    ];

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settings),
          ChangeNotifierProvider<WatchNextService>.value(value: service),
          ChangeNotifierProvider<TestAppsService>(create: (_) => TestAppsService()),
        ],
        child: MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: const Scaffold(body: WatchNextRow(isFirstSection: true)),
        ),
      ),
    );
    await tester.pumpAndSettle();

    final focused = FocusManager.instance.primaryFocus;
    expect(focused?.context, isNotNull);
    expect(
      focused!.context!.findAncestorWidgetOfExactType<WatchNextRow>(),
      isNotNull,
    );

    service.setLoading(true);
    await tester.pump();
    service.setLoading(false);
    await tester.pumpAndSettle();

    final after = FocusManager.instance.primaryFocus;
    expect(after, same(focused));
    expect(
      after!.context?.findAncestorWidgetOfExactType<WatchNextRow>(),
      isNotNull,
    );
  });

  test('section stays visible and keeps its reserved space while refreshing', () async {
    final channel = MockFLauncherChannel();
    when(channel.checkWatchNextPermission()).thenAnswer((_) async => true);
    when(channel.getWatchNextItems()).thenAnswer((_) async => [
          {'id': 1, 'title': 'One'},
        ]);
    final service = WatchNextService(channel);
    await Future<void>.delayed(Duration.zero);
    await service.refreshItems();
    expect(service.hasVisibleSection, isTrue);

    final pending = Completer<List<Map<dynamic, dynamic>>>();
    when(channel.getWatchNextItems()).thenAnswer((_) => pending.future);
    final refresh = service.refreshItems();
    expect(service.isLoading, isTrue);
    expect(service.hasVisibleSection, isTrue);

    pending.complete([
      {'id': 1, 'title': 'One'},
    ]);
    await refresh;
    expect(service.isLoading, isFalse);
    expect(service.hasVisibleSection, isTrue);
    service.dispose();
  });
}
