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
import 'package:flauncher/widgets/settings/weather_city_dialog.dart';
import 'package:flauncher/widgets/weather_geocoding.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  const oslo = WeatherCity(name: 'Oslo', region: 'Oslo', country: 'Norway', latitude: 59.91, longitude: 10.75);

  Future<WeatherCity?> openDialog(WidgetTester tester, WeatherCitySearch search) async {
    WeatherCity? result;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => result = await showDialog<WeatherCity>(
              context: context,
              builder: (_) => WeatherCityDialog(search: search),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    return result;
  }

  testWidgets('has no coordinate fields, only a city name field', (tester) async {
    await openDialog(tester, (_, __) async => [oslo]);
    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('City name'), findsOneWidget);
  });

  testWidgets('searching by name and tapping a match returns that city', (tester) async {
    String? searched;
    WeatherCity? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showDialog<WeatherCity>(
              context: context,
              builder: (_) => WeatherCityDialog(
                search: (query, language) async {
                  searched = query;
                  return [oslo];
                },
              ),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Oslo');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Oslo, Oslo, Norway'));
    await tester.pumpAndSettle();

    expect(searched, 'Oslo');
    expect(picked?.latitude, 59.91);
    expect(picked?.longitude, 10.75);
  });

  testWidgets('D-pad: down from the field focuses the list, OK picks a city', (tester) async {
    const kazan = WeatherCity(
      name: 'Kazan',
      region: 'Tatarstan',
      country: 'Russia',
      latitude: 55.79,
      longitude: 49.12,
    );
    WeatherCity? picked;
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        supportedLocales: AppLocalizations.supportedLocales,
        home: Builder(
          builder: (context) => TextButton(
            onPressed: () async => picked = await showDialog<WeatherCity>(
              context: context,
              builder: (_) => WeatherCityDialog(search: (q, l) async => [kazan, oslo]),
            ),
            child: const Text('open'),
          ),
        ),
      ),
    );
    await tester.tap(find.text('open'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'k');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();

    FocusNode? primary() => FocusManager.instance.primaryFocus;
    String? focused() => primary()?.debugLabel;

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused(), 'weatherCity0');
    final tile = tester.widget<ListTile>(
      find.byWidgetPredicate((w) => w is ListTile && w.focusNode == primary()),
    );
    expect(tile.tileColor, isNotNull, reason: 'focused row is highlighted');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(focused(), 'weatherCity1');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(
      primary()?.context?.findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
      reason: 'up from the first row returns to the field',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.byType(WeatherCityDialog), findsNothing);
    expect(picked, kazan);
  });

  testWidgets('remote without Enter: OK in the field starts the search', (tester) async {
    var calls = 0;
    await openDialog(tester, (q, lang) async {
      calls++;
      return const [];
    });
    await tester.enterText(find.byType(TextField), 'Kazan');
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(calls, 1);
  });

  testWidgets('remote: OK in an empty field does not search', (tester) async {
    var calls = 0;
    await openDialog(tester, (q, lang) async {
      calls++;
      return const [];
    });
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(calls, 0);
  });

  testWidgets('remote: down with an empty list reaches the Search button', (tester) async {
    await openDialog(tester, (q, lang) async => const []);
    await tester.enterText(find.byType(TextField), 'zzzz');
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'weatherCitySearch');

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pump();
    expect(
      FocusManager.instance.primaryFocus?.context?.findAncestorWidgetOfExactType<EditableText>(),
      isNotNull,
      reason: 'up from Search returns to the field',
    );

    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.select);
    await tester.pumpAndSettle();
    expect(find.text('No cities found'), findsOneWidget);
  });

  testWidgets('keyboard search action runs the search and hides the keyboard', (tester) async {
    var calls = 0;
    await openDialog(tester, (q, lang) async {
      calls++;
      return const [];
    });
    await tester.showKeyboard(find.byType(TextField));
    expect(tester.testTextInput.isVisible, isTrue);
    await tester.enterText(find.byType(TextField), 'Moscow');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    expect(calls, 1);
    expect(
      tester.testTextInput.isVisible,
      isFalse,
      reason: 'the keyboard covers the results and keeps the D-pad',
    );
  });

  testWidgets('down from the last result reaches the Search button', (tester) async {
    const kazan = WeatherCity(
      name: 'Kazan',
      region: 'Tatarstan',
      country: 'Russia',
      latitude: 55.79,
      longitude: 49.12,
    );
    await openDialog(tester, (q, lang) async => [kazan]);
    await tester.enterText(find.byType(TextField), 'k');
    await tester.testTextInput.receiveAction(TextInputAction.search);
    await tester.pumpAndSettle();
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pump();
    expect(FocusManager.instance.primaryFocus?.debugLabel, 'weatherCitySearch');
  });

  testWidgets('an empty result shows a message', (tester) async {
    await openDialog(tester, (_, __) async => []);
    await tester.enterText(find.byType(TextField), 'Nowhere');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('No cities found'), findsOneWidget);
  });

  testWidgets('a failed search shows an error message', (tester) async {
    await openDialog(tester, (_, __) async => throw Exception('offline'));
    await tester.enterText(find.byType(TextField), 'Oslo');
    await tester.tap(find.text('Search'));
    await tester.pumpAndSettle();
    expect(find.text('Search failed. Check the network connection.'), findsOneWidget);
  });
}
