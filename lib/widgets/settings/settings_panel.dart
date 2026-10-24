/*
 * FLauncher
 * Copyright (C) 2021  Étienne Fesser
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program.  If not, see <https://www.gnu.org/licenses/>.
 */

import 'package:flauncher/widgets/side_panel_dialog.dart';
import 'package:flauncher/widgets/settings/applications_panel_page.dart';
import 'package:flauncher/widgets/settings/launcher_sections_panel_page.dart';
import 'package:flauncher/widgets/settings/gradient_panel_page.dart';
import 'package:flauncher/widgets/settings/reddit_subreddits_panel_page.dart';
import 'package:flauncher/widgets/settings/reddit_wallpaper_panel_page.dart';
import 'package:flauncher/widgets/settings/unsplash_slideshow_panel_page.dart';
import 'package:flauncher/widgets/settings/launcher_section_panel_page.dart';
import 'package:flauncher/widgets/settings/settings_panel_page.dart';
import 'package:flauncher/widgets/settings/status_bar_panel_page.dart';
import 'package:flauncher/widgets/settings/wallpaper_panel_page.dart';
import 'package:flauncher/widgets/settings/wifi_usage_period_page.dart';
import 'package:flauncher/widgets/settings/back_button_action_page.dart';
import 'package:flauncher/widgets/settings/date_time_format_page.dart';
import 'package:flauncher/widgets/settings/app_details_page.dart';
import 'package:flauncher/widgets/settings/accent_color_page.dart';
import 'package:flauncher/widgets/settings/brightness_settings_page.dart';
import 'package:flauncher/widgets/settings/appearance_panel_page.dart';
import 'package:flauncher/widgets/settings/focus_border_thickness_page.dart';
import 'package:flauncher/widgets/settings/misc_panel_page.dart';
import 'package:flauncher/widgets/settings/watch_next_panel_page.dart';
import 'package:flauncher/widgets/settings/watch_next_max_items_page.dart';
import 'package:flauncher/widgets/settings/interface_settings_page.dart';
import 'package:flauncher/widgets/settings/general_settings_page.dart';
import 'package:flauncher/widgets/settings/screensaver_clock_style_page.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/widgets/settings/slideshow_sources_panel_page.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';

class SettingsPanel extends StatefulWidget {
  final String? initialRoute;

  const SettingsPanel({Key? key, this.initialRoute}) : super(key: key);

  @override
  State<SettingsPanel> createState() => _SettingsPanelState();
}

class _SettingsPanelState extends State<SettingsPanel> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => !await _navigatorKey.currentState!.maybePop(),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Stack(
          children: [
            // Tap outside to close. A single gradient scrim adds depth next to
            // the panel without a second full-screen colour layer.
            GestureDetector(
              onTap: () => Navigator.of(context).pop(),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.centerLeft,
                    end: Alignment.centerRight,
                    colors: [Color(0x8C000000), Color(0x1A000000)],
                  ),
                ),
              ),
            ),
            // The side panel
            SidePanelDialog(
              width: SettingsStyle.panelWidth,
              isRightSide: false,
              child: Navigator(
                key: _navigatorKey,
                initialRoute: widget.initialRoute ?? SettingsPanelPage.routeName,
                onGenerateRoute: (settings) {
                  switch (settings.name) {
                    case SettingsPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => SettingsPanelPage());
                    case GeneralSettingsPage.routeName:
                      return _FastPageRoute(builder: (_) => GeneralSettingsPage());
                    case InterfaceSettingsPage.routeName:
                      return _FastPageRoute(builder: (_) => InterfaceSettingsPage());
                    case WallpaperPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => WallpaperPanelPage());
                    case StatusBarPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => StatusBarPanelPage());
                    case GradientPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => GradientPanelPage());
                    case SlideshowSourcesPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => SlideshowSourcesPanelPage());
                    case UnsplashSlideshowPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => UnsplashSlideshowPanelPage());
                    case RedditWallpaperPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => const RedditWallpaperPanelPage());
                    case RedditSubredditsPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => const RedditSubredditsPanelPage());
                    case ApplicationsPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => ApplicationsPanelPage());
                    case LauncherSectionsPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => LauncherSectionsPanelPage());
                    case LauncherSectionPanelPage.routeName:
                      return _FastPageRoute(
                        builder: (_) => LauncherSectionPanelPage(sectionIndex: settings.arguments as int?),
                      );
                    case WifiUsagePeriodPage.routeName:
                      return _FastPageRoute(builder: (_) => WifiUsagePeriodPage());
                    case BackButtonActionPage.routeName:
                      return _FastPageRoute(builder: (_) => BackButtonActionPage());
                    case DateTimeFormatPage.routeName:
                      return _FastPageRoute(builder: (_) => DateTimeFormatPage());
                    case AppearancePanelPage.routeName:
                      return _FastPageRoute(builder: (_) => const AppearancePanelPage());
                    case FocusBorderThicknessPage.routeName:
                      return _FastPageRoute(builder: (_) => const FocusBorderThicknessPage());
                    case MiscPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => MiscPanelPage());
                    case WatchNextPanelPage.routeName:
                      return _FastPageRoute(builder: (_) => const WatchNextPanelPage());
                    case WatchNextMaxItemsPage.routeName:
                      return _FastPageRoute(builder: (_) => const WatchNextMaxItemsPage());
                    case ScreensaverClockStylePage.routeName:
                      return _FastPageRoute(builder: (_) => const ScreensaverClockStylePage());
                    case AccentColorPage.routeName:
                      return _FastPageRoute(builder: (_) => AccentColorPage());
                    case BrightnessSettingsPage.routeName:
                      return _FastPageRoute(builder: (_) => BrightnessSettingsPage());
                    case AppDetailsPage.routeName:
                      return _FastPageRoute(builder: (_) => AppDetailsPage(application: settings.arguments as App));
                    default:
                      throw ArgumentError.value(settings.name, "settings.name", "Route not supported.");
                  }
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// A faster page route: a short fade + slide instead of the default Material
/// transition. Both effects are composited, so navigation stays smooth on
/// low-power TV boxes.
class _FastPageRoute<T> extends PageRouteBuilder<T> {
  _FastPageRoute({required WidgetBuilder builder, RouteSettings? settings})
      : super(
          settings: settings,
          transitionDuration: const Duration(milliseconds: 200),
          reverseTransitionDuration: const Duration(milliseconds: 150),
          pageBuilder: (context, animation, secondaryAnimation) => builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curve = CurveTween(curve: Curves.easeOutCubic);
            return FadeTransition(
              opacity: animation.drive(curve),
              child: SlideTransition(
                position: animation.drive(
                  Tween<Offset>(begin: const Offset(0.05, 0), end: Offset.zero).chain(curve),
                ),
                child: child,
              ),
            );
          },
        );
}
