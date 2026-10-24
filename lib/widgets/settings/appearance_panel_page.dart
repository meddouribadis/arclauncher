import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focus_border_thickness_page.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AppearancePanelPage extends StatelessWidget {
  static const String routeName = "appearance_panel";

  const AppearancePanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final settingsService = Provider.of<SettingsService>(context);

    return Column(
      children: [
        SettingsPageHeader(title: localizations.appearanceSettings),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              RoundedSwitchListTile(
                autofocus: true,
                value: !settingsService.dockBackdropFilterDisabled,
                onChanged: (value) => settingsService.setDockBackdropFilterDisabled(!value),
                title: Text(localizations.dockBlur, style: Theme.of(context).textTheme.bodyMedium),
                secondary: const Icon(Icons.blur_circular),
              ),
              RoundedSwitchListTile(
                value: !settingsService.backgroundBlurDisabled,
                onChanged: (value) => settingsService.setBackgroundBlurDisabled(!value),
                title: Text(localizations.backgroundBlur, style: Theme.of(context).textTheme.bodyMedium),
                secondary: const Icon(Icons.blur_on),
              ),
              RoundedSwitchListTile(
                value: settingsService.dockShadowEnabled,
                onChanged: settingsService.setDockShadowEnabled,
                title: Text(localizations.dockShadow, style: Theme.of(context).textTheme.bodyMedium),
                secondary: const Icon(Icons.layers),
              ),
              RoundedSwitchListTile(
                value: settingsService.dockDarkBackground,
                onChanged: settingsService.setDockDarkBackground,
                title: Text(localizations.dockDarkBackground, style: Theme.of(context).textTheme.bodyMedium),
                secondary: const Icon(Icons.dark_mode),
              ),
              FocusableSettingsTile(
                showChevron: true,
                leading: const Icon(Icons.border_style),
                title: Text(localizations.focusBorderThickness, style: Theme.of(context).textTheme.bodyMedium),
                subtitle: Text(
                  _thicknessLabel(localizations, settingsService.focusBorderThickness),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                onPressed: () => Navigator.of(context).pushNamed(FocusBorderThicknessPage.routeName),
              ),
            ],
          ),
        ),
      ],
    );
  }

  String _thicknessLabel(AppLocalizations localizations, double thickness) {
    if ((thickness - FOCUS_BORDER_THIN).abs() < 0.05) return localizations.focusBorderThin;
    if ((thickness - FOCUS_BORDER_DEFAULT).abs() < 0.05) return localizations.focusBorderDefault;
    if ((thickness - FOCUS_BORDER_MEDIUM).abs() < 0.05) return localizations.focusBorderMedium;
    if ((thickness - FOCUS_BORDER_BOLD).abs() < 0.05) return localizations.focusBorderBold;
    return "${thickness.toStringAsFixed(1)} dp";
  }
}
