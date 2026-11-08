import 'package:flauncher/providers/apps_service.dart';
import 'package:flauncher/providers/parental_control_service.dart';
import 'package:flauncher/widgets/parental_code_dialog.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/// Entry tile: asks the current code (if any) before opening the page.
Future<void> openParentalControlPage(BuildContext context) async {
  final service = context.read<ParentalControlService>();
  final navigator = Navigator.of(context);
  if (service.hasCode) {
    // Always ask the code here, even during the 15 min grace period.
    final ok = await showParentalCodeDialog(context, mode: ParentalCodeDialogMode.verify);
    if (!ok) return;
  }
  navigator.pushNamed(ParentalControlPage.routeName);
}

class ParentalControlPage extends StatelessWidget {
  static const String routeName = "parental_control_panel";

  const ParentalControlPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = context.watch<ParentalControlService>();
    final apps = context.watch<AppsService>().applications;
    final textStyle = Theme.of(context).textTheme.bodyMedium;
    final protectedPackages = service.protectedPackages;

    return Column(
      children: [
        const SettingsPageHeader(title: "Parental control"),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              FocusableSettingsTile(
                autofocus: true,
                leading: const Icon(Icons.pin_outlined),
                title: Text(service.hasCode ? "Change the code" : "Set a code", style: textStyle),
                onPressed: () async {
                  final created = await showParentalCodeDialog(context, mode: ParentalCodeDialogMode.create);
                  if (created) await service.setEnabled(true);
                },
              ),
              RoundedSwitchListTile(
                value: service.enabled,
                onChanged: (value) {
                  if (service.hasCode) service.setEnabled(value);
                },
                title: Text("Protect selected apps", style: textStyle),
                secondary: const Icon(Icons.lock_outline),
              ),
              RoundedSwitchListTile(
                value: service.protectSettings,
                onChanged: (value) {
                  if (service.hasCode) service.setProtectSettings(value);
                },
                title: Text("Protect launcher settings", style: textStyle),
                secondary: const Icon(Icons.settings_outlined),
              ),
              FocusableSettingsTile(
                leading: const Icon(Icons.lock_reset),
                title: Text("Ask the code again now", style: textStyle),
                onPressed: () => service.relock(),
              ),
              const SettingsSectionDivider(),
              for (final app in apps)
                RoundedSwitchListTile(
                  value: protectedPackages.contains(app.packageName),
                  onChanged: (value) => service.setPackageProtected(app.packageName, value),
                  title: Text(app.name, style: textStyle),
                  secondary: const Icon(Icons.apps),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
