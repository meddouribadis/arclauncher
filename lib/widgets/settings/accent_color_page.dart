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

import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:flauncher/l10n/app_localizations.dart';
import '../../providers/settings_service.dart';

class AccentColorPage extends StatelessWidget {
  static const String routeName = "accent_color_panel";

  // Define accent color presets with names
  static const List<(String hex, String name)> colorPresets = [
    (ACCENT_COLOR_PURPLE, 'Purple'),
    (ACCENT_COLOR_TEAL, 'Teal'),
    (ACCENT_COLOR_BLUE, 'Blue'),
    (ACCENT_COLOR_ORANGE, 'Orange'),
    (ACCENT_COLOR_PINK, 'Pink'),
    (ACCENT_COLOR_GREEN, 'Green'),
    (ACCENT_COLOR_WHITE, 'White'),
    (ACCENT_COLOR_YELLOW, 'Yellow'),
    (ACCENT_COLOR_RED, 'Red'),
    (ACCENT_COLOR_CYAN, 'Cyan'),
    (ACCENT_COLOR_INDIGO, 'Indigo'),
    (ACCENT_COLOR_LIME, 'Lime'),
    (ACCENT_COLOR_AMBER, 'Amber'),
    (ACCENT_COLOR_ROSE, 'Rose'),
    (ACCENT_COLOR_ICE_BLUE, 'Ice Blue'),
  ];

  const AccentColorPage({super.key});

  String _localizedColorName(BuildContext context, String name) {
    final localizations = AppLocalizations.of(context)!;
    return switch (name) {
      'Purple' => localizations.colorPurple,
      'Teal' => localizations.colorTeal,
      'Blue' => localizations.colorBlue,
      'Orange' => localizations.colorOrange,
      'Pink' => localizations.colorPink,
      'Green' => localizations.colorGreen,
      'White' => localizations.colorWhite,
      'Yellow' => localizations.colorYellow,
      'Red' => localizations.colorRed,
      'Cyan' => localizations.colorCyan,
      'Indigo' => localizations.colorIndigo,
      'Lime' => localizations.colorLime,
      'Amber' => localizations.colorAmber,
      'Rose' => localizations.colorRose,
      'Ice Blue' => localizations.colorIceBlue,
      _ => name,
    };
  }

  Color _hexToColor(String hex) {
    return Color(int.parse('FF$hex', radix: 16));
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<SettingsService>(
      builder: (context, settingsService, _) {
        final currentColor = settingsService.accentColorHex;
        
        return Column(
          children: [
            SettingsPageHeader(title: AppLocalizations.of(context)!.accentColor),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.all(16),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 1.3,
                ),
                itemCount: colorPresets.length,
                itemBuilder: (context, index) {
                  final (hex, name) = colorPresets[index];
                  final isSelected = currentColor == hex;
                  
                  return _ColorTile(
                    color: _hexToColor(hex),
                    name: _localizedColorName(context, name),
                    isSelected: isSelected,
                    autofocus: index == 0,
                    onTap: () => settingsService.setAccentColor(hex),
                  );
                },
              ),
            ),
            // Preview section
            Padding(
              padding: const EdgeInsets.all(16),
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.black26,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _hexToColor(currentColor),
                    width: 3,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.palette,
                      color: _hexToColor(currentColor),
                      size: 32,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      AppLocalizations.of(context)!.preview,
                      style: TextStyle(
                        color: _hexToColor(currentColor),
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ColorTile extends StatefulWidget {
  final Color color;
  final String name;
  final bool isSelected;
  final bool autofocus;
  final VoidCallback onTap;

  const _ColorTile({
    required this.color,
    required this.name,
    required this.isSelected,
    required this.onTap,
    this.autofocus = false,
  });

  @override
  State<_ColorTile> createState() => _ColorTileState();
}

class _ColorTileState extends State<_ColorTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final foreground = widget.color.computeLuminance() > 0.62 ? Colors.black87 : Colors.white;
    final ring = _focused || widget.isSelected;

    return Actions(
      actions: <Type, Action<Intent>>{
        ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => widget.onTap()),
        ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => widget.onTap()),
      },
      child: Focus(
        autofocus: widget.autofocus,
        onFocusChange: (hasFocus) => setState(() => _focused = hasFocus),
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: widget.onTap,
          child: AnimatedScale(
            scale: _focused ? 1.04 : 1.0,
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOutCubic,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              curve: Curves.easeOutCubic,
              // A light-to-dark sheen gives the swatch depth without a shadow
              // layer, which is expensive to composite on TV hardware.
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    Color.lerp(widget.color, Colors.white, 0.18)!,
                    widget.color,
                    Color.lerp(widget.color, Colors.black, 0.14)!,
                  ],
                ),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: ring ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.12),
                  width: 2,
                ),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (widget.isSelected)
                      Icon(Icons.check_rounded, color: foreground, size: 24),
                    if (widget.isSelected) const SizedBox(height: 2),
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        widget.name,
                        style: TextStyle(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
