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

import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/providers/reddit_slideshow.dart';
import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/ensure_visible.dart';
import 'package:flauncher/widgets/rounded_switch_list_tile.dart';
import 'package:flauncher/widgets/settings/focusable_settings_tile.dart';
import 'package:flauncher/widgets/settings/settings_theme.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class RedditSubredditsPanelPage extends StatelessWidget {
  static const String routeName = "reddit_subreddits_panel";

  const RedditSubredditsPanelPage({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Column(
      children: [
        SettingsPageHeader(title: localizations.redditSubreddits),
        Expanded(
          child: Consumer<SettingsService>(
            builder: (_, settings, __) {
              final selected = settings.redditSubreddits;
              final popularKeys = popularSubreddits.map((s) => s.name).toSet();
              final customSubs = selected.where((s) => !popularKeys.contains(s)).toList();

              return ListView(
                children: [
                  ...popularSubreddits.indexed.map((entry) {
                    final (index, source) = entry;
                    final isChecked = selected.contains(source.name);
                    return EnsureVisible(
                      alignment: 0.5,
                      child: RoundedSwitchListTile(
                        autofocus: index == 0,
                        title: Text(source.displayName),
                        secondary: Icon(source.icon),
                        value: isChecked,
                        onChanged: (checked) {
                          if (!checked && selected.length <= 1) {
                            return; // Keep at least one selected
                          }
                          final updated = checked
                              ? [...selected, source.name]
                              : selected.where((k) => k != source.name).toList();
                          settings.setRedditSubreddits(updated);
                        },
                      ),
                    );
                  }),
                  if (customSubs.isNotEmpty) ...[
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                      child: Text(localizations.customName, style: Theme.of(context).textTheme.titleSmall),
                    ),
                    ...customSubs.map((sub) {
                      return EnsureVisible(
                        alignment: 0.5,
                        child: RoundedSwitchListTile(
                          title: Text('r/$sub'),
                          secondary: const Icon(Icons.tag),
                          value: true,
                          onChanged: (_) {
                            if (selected.length <= 1) return;
                            final updated = selected.where((k) => k != sub).toList();
                            settings.setRedditSubreddits(updated);
                          },
                        ),
                      );
                    }),
                  ],
                  const SizedBox(height: 8),
                  FocusableSettingsTile(
                    leading: const Icon(Icons.add),
                    title: Text(localizations.redditAddSubreddit),
                    onPressed: () async {
                      final name = await _askSubreddit(context, localizations);
                      if (name != null && name.isNotEmpty) {
                        final clean = name.replaceAll(RegExp(r'^r/'), '').trim();
                        if (clean.isNotEmpty && !selected.contains(clean)) {
                          await settings.setRedditSubreddits([...selected, clean]);
                        }
                      }
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }

  Future<String?> _askSubreddit(BuildContext context, AppLocalizations localizations) => showDialog<String>(
    context: context,
    builder: (context) => SimpleDialog(
      insetPadding: const EdgeInsets.only(bottom: 120),
      contentPadding: const EdgeInsets.all(24),
      title: Text(localizations.redditAddSubreddit),
      children: [
        Padding(padding: const EdgeInsets.only(bottom: 16), child: Text(localizations.redditSubredditName)),
        TextFormField(
          autofocus: true,
          decoration: const InputDecoration(prefixText: "r/"),
          keyboardType: TextInputType.text,
          onFieldSubmitted: (value) => Navigator.of(context).pop(value),
        ),
      ],
    ),
  );
}
