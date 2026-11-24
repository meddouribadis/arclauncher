/*
 * FLauncher
 * Copyright (C) 2021  Oscar Rojas
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

import 'package:arclauncher/providers/settings_service.dart';
import 'package:arclauncher/widgets/date_time_widget.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class AlternativeLauncherView extends StatelessWidget {
  const AlternativeLauncherView({super.key});

  @override
  Widget build(BuildContext context) => Selector<SettingsService, (String, String, String)>(
    selector: (_, service) => (service.timeFormat, service.dateFormat, service.screensaverClockStyle),
    builder: (context, formats, _) {
      final (timeFormat, dateFormat, clockStyle) = formats;
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildClock(context, timeFormat, clockStyle),
          const SizedBox(height: 16),
          DateTimeWidget(dateFormat,
            updateInterval: const Duration(minutes: 1),
            textStyle: Theme.of(context).textTheme.headlineLarge!.copyWith(
              fontSize: 56,
              fontWeight: FontWeight.w300,
              shadows: const [Shadow(color: Colors.black54, offset: Offset(1, 1), blurRadius: 12)],
            )
          )
        ],
      );
    },
  );

  Widget _buildClock(BuildContext context, String timeFormat, String style) {
    final FontWeight fontWeight;
    final double fontSize;
    final double letterSpacing;
    final String? fontFamily;

    switch (style) {
      case 'bold':
        fontWeight = FontWeight.bold;
        fontSize = 140;
        letterSpacing = -2.0;
        fontFamily = null;
      case 'retro':
        fontWeight = FontWeight.w400;
        fontSize = 120;
        letterSpacing = 4.0;
        fontFamily = 'monospace';
      case 'elegant':
        fontWeight = FontWeight.w300;
        fontSize = 120;
        letterSpacing = 3.0;
        fontFamily = 'serif';
      case 'neon':
        fontWeight = FontWeight.w100;
        fontSize = 130;
        letterSpacing = 4.0;
        fontFamily = null;
      case 'pixel':
        fontWeight = FontWeight.w700;
        fontSize = 110;
        letterSpacing = 6.0;
        fontFamily = 'monospace';
      case 'digital':
        fontWeight = FontWeight.w300;
        fontSize = 120;
        letterSpacing = 2.0;
        fontFamily = 'monospace';
      default: // minimal
        fontWeight = FontWeight.w200;
        fontSize = 120;
        letterSpacing = 2.0;
        fontFamily = null;
    }

    final mainStyle = Theme.of(context).textTheme.displayLarge!.copyWith(
      fontSize: fontSize,
      fontWeight: fontWeight,
      letterSpacing: letterSpacing,
      fontFamily: fontFamily,
      shadows: const [Shadow(color: Colors.black54, offset: Offset(2, 2), blurRadius: 16)],
    );

    // Check if format has AM/PM (contains 'a')
    final hasAmPm = timeFormat.contains('a');
    if (!hasAmPm) {
      return DateTimeWidget(timeFormat, textStyle: mainStyle);
    }

    // Split: render time without AM/PM at full size, AM/PM at 35% size on same line
    final timeOnly = timeFormat.replaceAll(RegExp(r'\s*a\s*'), '').trim();
    final amPmStyle = mainStyle.copyWith(
      fontSize: fontSize * 0.35,
      fontWeight: FontWeight.w400,
      letterSpacing: 1.0,
    );

    return IntrinsicHeight(
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          DateTimeWidget(timeOnly, textStyle: mainStyle),
          const SizedBox(width: 8),
          Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              DateTimeWidget('a', animate: false, textStyle: amPmStyle),
            ],
          ),
        ],
      ),
    );
  }
}
