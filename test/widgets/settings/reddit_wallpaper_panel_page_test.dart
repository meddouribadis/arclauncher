import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/settings/reddit_subreddits_panel_page.dart';
import 'package:flauncher/widgets/settings/reddit_wallpaper_panel_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';

import '../../mocks.mocks.dart';

void main() {
  testWidgets("RedditWallpaperPanelPage renders options correctly", (tester) async {
    final settingsService = MockSettingsService();
    final wallpaperService = MockWallpaperService();

    when(settingsService.redditWallpaperEnabled).thenReturn(true);
    when(settingsService.redditSubreddits).thenReturn(['wallpapers', 'EarthPorn']);
    when(settingsService.redditSort).thenReturn('hot');
    when(settingsService.redditIntervalMinutes).thenReturn(10);
    when(settingsService.redditClientId).thenReturn('');

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider<SettingsService>.value(value: settingsService),
          ChangeNotifierProvider<WallpaperService>.value(value: wallpaperService),
        ],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RedditWallpaperPanelPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Reddit wallpaper'), findsOneWidget);
    expect(find.text('Show Reddit wallpapers'), findsOneWidget);
    expect(find.text('Subreddits'), findsOneWidget);
    expect(find.text('2'), findsOneWidget);
    expect(find.text('Sort by'), findsOneWidget);
    expect(find.text('Hot'), findsOneWidget);
    expect(find.text('Change every'), findsOneWidget);
    expect(find.text('10 min'), findsOneWidget);
    expect(find.text('Change wallpaper now'), findsOneWidget);
  });

  testWidgets("RedditSubredditsPanelPage renders subreddits", (tester) async {
    final settingsService = MockSettingsService();

    when(settingsService.redditSubreddits).thenReturn(['wallpapers', 'wallpaper', 'EarthPorn']);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<SettingsService>.value(value: settingsService)],
        child: const MaterialApp(
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: Scaffold(body: RedditSubredditsPanelPage()),
        ),
      ),
    );
    await tester.pumpAndSettle();

    expect(find.text('Subreddits'), findsOneWidget);
    expect(find.text('r/wallpapers'), findsOneWidget);
    expect(find.text('r/wallpaper'), findsOneWidget);
    expect(find.text('r/EarthPorn'), findsOneWidget);
    expect(find.text('Add custom subreddit'), findsOneWidget);
  });
}
