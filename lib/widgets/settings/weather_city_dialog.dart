/*
 * FLauncher
 * Copyright (C) 2024 Oscar Rojas
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
import 'package:flauncher/widgets/weather_geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// Asks for a city name, lists the geocoding matches and returns the chosen one.
/// Nothing is saved until the user picks a match.
class WeatherCityDialog extends StatefulWidget {
  final WeatherCitySearch search;

  const WeatherCityDialog({super.key, this.search = _defaultSearch});

  static Future<List<WeatherCity>> _defaultSearch(String query, String language) =>
      searchWeatherCities(query, language);

  @override
  State<WeatherCityDialog> createState() => _WeatherCityDialogState();
}

class _WeatherCityDialogState extends State<WeatherCityDialog> {
  final _controller = TextEditingController();
  final _fieldFocus = FocusNode();
  final _searchFocus = FocusNode(debugLabel: 'weatherCitySearch');
  // One node per result: the remote has no Tab key, so D-pad moves focus
  // between the field and the list explicitly.
  List<FocusNode> _itemNodes = const [];
  List<WeatherCity> _results = const [];
  bool _loading = false;
  String? _message;

  @override
  void dispose() {
    _controller.dispose();
    _fieldFocus.dispose();
    _searchFocus.dispose();
    _disposeItemNodes();
    super.dispose();
  }

  void _disposeItemNodes() {
    // Widgets still listen to the old nodes until the next frame is built.
    final old = _itemNodes;
    _itemNodes = const [];
    if (old.isEmpty) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      for (final node in old) {
        node.dispose();
      }
    });
  }

  KeyEventResult _moveFocus(KeyEvent event, FocusNode? up, FocusNode? down) {
    if (event is! KeyDownEvent) return KeyEventResult.ignored;
    final target = event.logicalKey == LogicalKeyboardKey.arrowDown
        ? down
        : event.logicalKey == LogicalKeyboardKey.arrowUp
            ? up
            : null;
    if (target == null) return KeyEventResult.ignored;
    target.requestFocus();
    return KeyEventResult.handled;
  }

  // The remote has no Enter key: OK (select) starts the search, and down always leaves the
  // field (first result, or the search button when the list is empty).
  KeyEventResult _onFieldKey(FocusNode _, KeyEvent event) {
    if (event is KeyDownEvent &&
        (event.logicalKey == LogicalKeyboardKey.select ||
            event.logicalKey == LogicalKeyboardKey.enter ||
            event.logicalKey == LogicalKeyboardKey.numpadEnter)) {
      _search();
      return KeyEventResult.handled;
    }
    return _moveFocus(event, null, _itemNodes.isEmpty ? _searchFocus : _itemNodes.first);
  }

  void _setResults(List<WeatherCity> found) {
    _disposeItemNodes();
    _results = found;
    _itemNodes = [for (var i = 0; i < found.length; i++) FocusNode(debugLabel: 'weatherCity$i')];
  }

  Future<void> _search() async {
    final query = _controller.text.trim();
    if (query.isEmpty || _loading) return;
    // The on-screen keyboard keeps D-pad keys and shrinks the dialog so the results stay
    // hidden; the field keeps focus, only the keyboard goes away.
    SystemChannels.textInput.invokeMethod<void>('TextInput.hide');
    final localizations = AppLocalizations.of(context)!;
    final language = Localizations.localeOf(context).languageCode;
    setState(() {
      _loading = true;
      _message = null;
      _setResults(const []);
    });
    try {
      final found = await widget.search(query, language);
      if (!mounted) return;
      setState(() {
        _setResults(found);
        _message = found.isEmpty ? localizations.weatherNoResults : null;
      });
    } catch (_) {
      if (mounted) setState(() => _message = localizations.weatherSearchFailed);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final primary = Theme.of(context).colorScheme.primary;
    return AlertDialog(
      title: Text(localizations.weatherLocation),
      content: SizedBox(
        width: 480,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Focus(
              onKeyEvent: _onFieldKey,
              child: TextField(
                controller: _controller,
                focusNode: _fieldFocus,
                autofocus: true,
                textInputAction: TextInputAction.search,
                decoration: InputDecoration(labelText: localizations.weatherCityName),
                // onEditingComplete (not onSubmitted) keeps focus in the field: the default
                // for TextInputAction.search unfocuses it, and then D-pad down has nothing
                // to move from.
                onEditingComplete: _search,
              ),
            ),
            const SizedBox(height: 8),
            if (_loading) const LinearProgressIndicator(),
            if (_message != null)
              Padding(padding: const EdgeInsets.symmetric(vertical: 8), child: Text(_message!)),
            Flexible(
              child: ListView(
                shrinkWrap: true,
                children: [
                  for (var i = 0; i < _results.length; i++)
                    _CityTile(
                      city: _results[i],
                      focusNode: _itemNodes[i],
                      onKeyEvent: (event) => _moveFocus(
                        event,
                        i == 0 ? _fieldFocus : _itemNodes[i - 1],
                        i + 1 < _itemNodes.length ? _itemNodes[i + 1] : _searchFocus,
                      ),
                      onTap: () => Navigator.pop(context, _results[i]),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
      actions: [
        Focus(
          canRequestFocus: false,
          skipTraversal: true,
          onKeyEvent: (_, event) =>
              _moveFocus(event, _itemNodes.isEmpty ? _fieldFocus : _itemNodes.last, null),
          child: TextButton(
            focusNode: _searchFocus,
            onPressed: _search,
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.focused) ? primary.withValues(alpha: 0.25) : null,
              ),
              side: WidgetStateProperty.resolveWith(
                (states) =>
                    states.contains(WidgetState.focused) ? BorderSide(color: primary, width: 2) : null,
              ),
            ),
            child: Text(localizations.weatherSearch),
          ),
        ),
      ],
    );
  }
}

/// Result row with a visible focus highlight (the default ripple is barely visible on a TV).
class _CityTile extends StatefulWidget {
  final WeatherCity city;
  final FocusNode focusNode;
  final KeyEventResult Function(KeyEvent event) onKeyEvent;
  final VoidCallback onTap;

  const _CityTile({
    required this.city,
    required this.focusNode,
    required this.onKeyEvent,
    required this.onTap,
  });

  @override
  State<_CityTile> createState() => _CityTileState();
}

class _CityTileState extends State<_CityTile> {
  bool _focused = false;

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Focus(
      canRequestFocus: false,
      skipTraversal: true,
      onKeyEvent: (_, event) => widget.onKeyEvent(event),
      child: ListTile(
        focusNode: widget.focusNode,
        onFocusChange: (value) => setState(() => _focused = value),
        tileColor: _focused ? color.withValues(alpha: 0.25) : null,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: _focused ? color : Colors.transparent, width: 2),
        ),
        title: Text(widget.city.label),
        onTap: widget.onTap,
      ),
    );
  }
}
