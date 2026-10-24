import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flauncher/widgets/settings/settings_toggle.dart';
import 'package:flutter/material.dart';

class RoundedSwitchListTile extends StatelessWidget {
  final bool value;
  final bool autofocus;
  final ValueChanged<bool> onChanged;
  final Widget title;
  final Widget? subtitle;
  final Widget secondary;

  const RoundedSwitchListTile({
    super.key,
    required this.value,
    required this.onChanged,
    required this.title,
    this.subtitle,
    required this.secondary,
    this.autofocus = false,
  });

  @override
  Widget build(BuildContext context) {
    return FocusableSettingsTile(
      autofocus: autofocus,
      onPressed: () => onChanged(!value),
      leading: secondary,
      title: title,
      subtitle: subtitle,
      trailing: SettingsSwitch(
        value: value,
        accentColor: Theme.of(context).colorScheme.primary,
        duration: SettingsStyle.focusDurationFor(context),
      ),
    );
  }
}
