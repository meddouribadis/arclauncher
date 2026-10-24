/*
 * FLauncher
 * Copyright (C) 2026 LeanBitLab
 *
 * This program is free software: you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation, either version 3 of the License, or
 * (at your option) any later version.
 *
 * This program is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE. See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with this program. If not, see <https://www.gnu.org/licenses/>.
 */

import 'dart:typed_data';

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/models/app.dart';
import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/providers/watch_next_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/watch_next_max_items_page.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WatchNextPanelPage extends StatefulWidget {
  static const String routeName = "watch_next_panel";

  const WatchNextPanelPage({super.key});

  @override
  State<WatchNextPanelPage> createState() => _WatchNextPanelPageState();
}

class _WatchNextPanelPageState extends State<WatchNextPanelPage> {
  bool _isRefreshing = false;
  bool _showAllApps = false;

  Future<void> _refreshContent(BuildContext context, AppLocalizations localizations) async {
    if (_isRefreshing) return;
    setState(() => _isRefreshing = true);
    try {
      await context.read<WatchNextService>().forceRefresh();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(localizations.watchNextRefreshed),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isRefreshing = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settingsService = context.watch<SettingsService>();
    final watchNextService = context.watch<WatchNextService>();
    final appsService = context.watch<AppsService>();

    final availablePkgs = watchNextService.availablePackageNames;
    final excludedPkgs = settingsService.watchNextExcludedPackages.toSet();
    final knownPkgs = {...availablePkgs, ...excludedPkgs};

    final List<String> displayPkgs;
    if (_showAllApps) {
      final allInstalled = appsService.applications.map((a) => a.packageName).toSet();
      displayPkgs = {...knownPkgs, ...allInstalled}.toList();
    } else {
      displayPkgs = knownPkgs.toList();
    }

    displayPkgs.sort((a, b) {
      final appA = appsService.getApplication(a);
      final appB = appsService.getApplication(b);
      final nameA = appA?.name.toLowerCase() ?? a.toLowerCase();
      final nameB = appB?.name.toLowerCase() ?? b.toLowerCase();
      return nameA.compareTo(nameB);
    });

    return Column(
      children: [
        SettingsPageHeader(title: localizations.watchNextSectionTitle),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: settingsService.showWatchNextSection,
                onChanged: (value) async {
                  await settingsService.setShowWatchNextSection(value);
                  if (value && context.mounted) {
                    final service = context.read<WatchNextService>();
                    if (!service.hasPermission) {
                      await service.requestPermission();
                    }
                  }
                },
                title: Text(localizations.showWatchNextSection, style: Theme.of(context).textTheme.bodyMedium),
                secondary: const Icon(Icons.play_circle_outline),
              ),

              if (settingsService.showWatchNextSection) ...[
                if (!watchNextService.hasPermission)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Card(
                      color: Theme.of(context).colorScheme.errorContainer.withValues(alpha: 0.5),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              localizations.watchNextPermissionTitle,
                              style: Theme.of(context).textTheme.titleSmall,
                            ),
                            const SizedBox(height: 4),
                            Text(
                              localizations.watchNextPermissionBody,
                              style: Theme.of(context).textTheme.bodySmall,
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: () => watchNextService.requestPermission(),
                              child: Text(localizations.watchNextGrantPermission),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),

                RoundedSwitchListTile(
                  value: settingsService.watchNextBigPictureMode,
                  onChanged: settingsService.setWatchNextBigPictureMode,
                  title: Text(localizations.watchNextBigPictureMode, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(
                    localizations.watchNextBigPictureModeDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  secondary: const Icon(Icons.photo_size_select_actual_outlined),
                ),

                RoundedSwitchListTile(
                  value: settingsService.watchNextHideProgramsWithoutImages,
                  onChanged: settingsService.setWatchNextHideProgramsWithoutImages,
                  title: Text(localizations.watchNextHideWithoutImages, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(
                    localizations.watchNextHideWithoutImagesDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  secondary: const Icon(Icons.hide_image_outlined),
                ),

                FocusableSettingsTile(
                  leading: const Icon(Icons.format_list_numbered),
                  title: Text(localizations.watchNextMaxItems, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(
                    settingsService.watchNextMaxItems == 0
                        ? localizations.watchNextMaxItemsUnlimited
                        : '${settingsService.watchNextMaxItems}',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  trailing: const Icon(Icons.chevron_right, size: 20),
                  onPressed: () => Navigator.of(context).pushNamed(WatchNextMaxItemsPage.routeName),
                ),

                FocusableSettingsTile(
                  leading: _isRefreshing
                      ? const SizedBox(
                          width: 24,
                          height: 24,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Icon(Icons.refresh),
                  title: Text(localizations.watchNextRefresh, style: Theme.of(context).textTheme.bodyMedium),
                  subtitle: Text(
                    localizations.watchNextRefreshDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  onPressed: _isRefreshing ? null : () => _refreshContent(context, localizations),
                ),

                const SettingsSectionDivider(),
                Padding(
                  padding: const EdgeInsets.only(top: 8, bottom: 4),
                  child: Text(
                    localizations.watchNextFilterApps,
                    style: Theme.of(context).textTheme.titleSmall?.copyWith(
                          color: Theme.of(context).colorScheme.primary,
                        ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    localizations.watchNextFilterAppsDescription,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ),

                if (displayPkgs.isEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    child: Center(
                      child: Text(
                        localizations.watchNextNoApps,
                        style: Theme.of(context).textTheme.bodySmall,
                        textAlign: TextAlign.center,
                      ),
                    ),
                  )
                else
                  ...displayPkgs.map((pkg) {
                    final App? app = appsService.getApplication(pkg);
                    final String appName = app?.name ?? pkg;
                    final bool isExcluded = settingsService.isWatchNextPackageExcluded(pkg);

                    return RoundedSwitchListTile(
                      value: !isExcluded,
                      onChanged: (_) => settingsService.toggleWatchNextExcludedPackage(pkg),
                      title: Text(appName, style: Theme.of(context).textTheme.bodyMedium),
                      subtitle: Text(
                        pkg,
                        style: const TextStyle(fontSize: 10, color: Colors.white54),
                      ),
                      secondary: _AppIcon(packageName: pkg, appsService: appsService),
                    );
                  }),

                const SizedBox(height: 8),
                Center(
                  child: TextButton.icon(
                    onPressed: () => setState(() => _showAllApps = !_showAllApps),
                    icon: Icon(_showAllApps ? Icons.filter_list : Icons.apps_outlined, size: 18),
                    label: Text(
                      _showAllApps ? localizations.watchNextFilterApps : localizations.watchNextShowAllApps,
                      style: const TextStyle(fontSize: 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _AppIcon extends StatelessWidget {
  final String packageName;
  final AppsService appsService;

  const _AppIcon({required this.packageName, required this.appsService});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Uint8List>(
      future: appsService.getAppIcon(packageName),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.isNotEmpty) {
          return ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: Image.memory(
              snapshot.data!,
              width: 28,
              height: 28,
              fit: BoxFit.contain,
            ),
          );
        }
        return const Icon(Icons.tv_outlined);
      },
    );
  }
}
