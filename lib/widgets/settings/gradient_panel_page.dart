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

import 'package:flauncher/gradients.dart';
import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class GradientPanelPage extends StatelessWidget {
  static const String routeName = "gradient_panel";

  @override
  Widget build(BuildContext context) => Column(
        children: [
          SettingsPageHeader(title: AppLocalizations.of(context)!.gradient),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 4 / 3,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              padding: const EdgeInsets.fromLTRB(8, 4, 8, 16),
              children: FLauncherGradients.all
                  .map((gradient) => EnsureVisible(alignment: 0.5, child: _gradientCard(context, gradient)))
                  .toList(),
            ),
          ),
        ],
      );

  Widget _gradientCard(BuildContext context, FLauncherGradient fLauncherGradient) => Actions(
        actions: <Type, Action<Intent>>{
          ActivateIntent: CallbackAction<ActivateIntent>(onInvoke: (_) => context.read<WallpaperService>().setGradient(fLauncherGradient)),
          ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(onInvoke: (_) => context.read<WallpaperService>().setGradient(fLauncherGradient)),
        },
        child: Focus(
          key: Key("gradient-${fLauncherGradient.uuid}"),
          canRequestFocus: false,
          child: Builder(
            builder: (context) => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    elevation: 0,
                    color: Colors.transparent,
                    shape: _cardBorder(Focus.of(context).hasFocus),
                    child: InkWell(
                      autofocus: fLauncherGradient == FLauncherGradients.greatWhale,
                      onTap: () => context.read<WallpaperService>().setGradient(fLauncherGradient),
                      child: Container(decoration: BoxDecoration(gradient: fLauncherGradient.gradient)),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: AnimatedDefaultTextStyle(
                    style: Theme.of(context).textTheme.bodySmall!.copyWith(
                          color: Focus.of(context).hasFocus ? Colors.white : Colors.white.withValues(alpha: 0.7),
                        ),
                    duration: const Duration(milliseconds: 150),
                    child: Text(fLauncherGradient.name, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ],
            ),
          ),
        ),
      );

  ShapeBorder? _cardBorder(bool hasFocus) => RoundedRectangleBorder(
        side: BorderSide(
          color: hasFocus ? Colors.white.withValues(alpha: 0.9) : Colors.white.withValues(alpha: 0.10),
          width: hasFocus ? 2 : 1,
        ),
        borderRadius: BorderRadius.circular(14),
      );
}
