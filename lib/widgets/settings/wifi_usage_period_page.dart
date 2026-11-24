
import 'package:arclauncher/l10n/app_localizations.dart';
import 'package:arclauncher/providers/settings_service.dart';
import 'package:arclauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:arclauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class WifiUsagePeriodPage extends StatelessWidget {
  static const String routeName = "wifi_usage_period_panel";

  const WifiUsagePeriodPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Consumer<SettingsService>(
        builder: (context, service, _) {
          return Column(
            children: [
              SettingsPageHeader(title: localizations.wifiUsagePeriod),
              Expanded(
                child: ListView(
                  children: [
                    _radioTile(context, service, localizations.daily, WIFI_USAGE_DAILY),
                    _radioTile(context, service, localizations.weekly, WIFI_USAGE_WEEKLY),
                    _radioTile(context, service, localizations.monthly, WIFI_USAGE_MONTHLY),
                  ],
                ),
              ),
            ],
          );
        }
    );
  }

  Widget _radioTile(BuildContext context, SettingsService service, String label, String value) {
    final isSelected = service.wifiUsagePeriod == value;
    return FocusableSettingsTile(
      frameLeading: false,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onPressed: () => service.setWifiUsagePeriod(value),
    );
  }
}
