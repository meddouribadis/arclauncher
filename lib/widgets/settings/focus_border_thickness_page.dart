/*
 * FLauncher
 * Copyright (C) 2024 LeanBitLab
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

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/app_card_contour_painter.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class FocusBorderThicknessPage extends StatelessWidget {
  static const String routeName = "focus_border_thickness_panel";

  const FocusBorderThicknessPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Consumer<SettingsService>(
      builder: (context, service, _) {
        final currentThickness = service.focusBorderThickness;
        final accentColorHex = service.accentColorHex;
        final accentColor = Color(int.parse('FF$accentColorHex', radix: 16));

        return Column(
          children: [
            SettingsPageHeader(title: localizations.focusBorderThickness),
            // Live Preview Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Center(
                child: SizedBox(
                  width: 160,
                  height: 90,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [Color(0xFF2C2C31), Color(0xFF1A1A1D)],
                          ),
                          border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                        ),
                        child: Center(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.tv, size: 28, color: Colors.white.withValues(alpha: 0.8)),
                              const SizedBox(width: 8),
                              Text(
                                "${currentThickness.toStringAsFixed(1)} dp",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      CustomPaint(
                        foregroundPainter: AppCardContourPainter(
                          radius: 12.0,
                          strokeWidth: currentThickness,
                          accentColor: accentColor,
                          alpha: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SettingsSectionDivider(),
            Expanded(
              child: ListView(
                children: [
                  _radioTile(
                    context,
                    service,
                    localizations.focusBorderThin,
                    FOCUS_BORDER_THIN,
                    currentThickness,
                    autofocus: currentThickness == FOCUS_BORDER_THIN,
                  ),
                  _radioTile(
                    context,
                    service,
                    localizations.focusBorderDefault,
                    FOCUS_BORDER_DEFAULT,
                    currentThickness,
                    autofocus: currentThickness == FOCUS_BORDER_DEFAULT,
                  ),
                  _radioTile(
                    context,
                    service,
                    localizations.focusBorderMedium,
                    FOCUS_BORDER_MEDIUM,
                    currentThickness,
                    autofocus: currentThickness == FOCUS_BORDER_MEDIUM,
                  ),
                  _radioTile(
                    context,
                    service,
                    localizations.focusBorderBold,
                    FOCUS_BORDER_BOLD,
                    currentThickness,
                    autofocus: currentThickness == FOCUS_BORDER_BOLD,
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _radioTile(
    BuildContext context,
    SettingsService service,
    String label,
    double value,
    double currentValue, {
    bool autofocus = false,
  }) {
    final isSelected = (currentValue - value).abs() < 0.05;
    return FocusableSettingsTile(
      autofocus: autofocus,
      frameLeading: false,
      leading: Icon(
        isSelected ? Icons.radio_button_checked : Icons.radio_button_unchecked,
        color: isSelected ? Theme.of(context).colorScheme.secondary : Colors.grey,
      ),
      title: Text(label, style: Theme.of(context).textTheme.bodyMedium),
      onPressed: () => service.setFocusBorderThickness(value),
    );
  }
}
