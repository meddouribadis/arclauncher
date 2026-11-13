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

import 'package:flauncher/providers/settings_service.dart';
import 'package:flauncher/widgets/weather_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  late SettingsService settings;
  late int fetchCount;

  Future<WeatherReading> fakeFetch(double latitude, double longitude) async {
    fetchCount++;
    return const WeatherReading(7, 0);
  }

  setUp(() async {
    SharedPreferences.setMockInitialValues({});
    settings = SettingsService(await SharedPreferences.getInstance());
    fetchCount = 0;
  });

  Widget host() => ChangeNotifierProvider<SettingsService>.value(
        value: settings,
        child: MaterialApp(home: Scaffold(body: WeatherWidget(fetcher: fakeFetch))),
      );

  test('weather is off and has no city by default', () {
    expect(settings.showWeatherInStatusBar, isFalse);
    expect(settings.weatherCity, isNull);
    expect(settings.weatherLatitude, isNull);
  });

  testWidgets('without a chosen city nothing is shown and the network is not used', (tester) async {
    await settings.setShowWeatherInStatusBar(true);
    await tester.pumpWidget(host());
    await tester.pump();

    expect(fetchCount, 0);
    expect(find.byType(Text), findsNothing);
  });

  testWidgets('with a chosen city the temperature is fetched and shown', (tester) async {
    await settings.setShowWeatherInStatusBar(true);
    await settings.setWeatherLocation('Oslo', 59.91, 10.75);
    await tester.pumpWidget(host());
    await tester.pump();
    await tester.pump();

    expect(fetchCount, 1);
    expect(find.text('Oslo 7°'), findsOneWidget);
  });

  testWidgets('a failed request hides the widget', (tester) async {
    await settings.setShowWeatherInStatusBar(true);
    await settings.setWeatherLocation('Oslo', 59.91, 10.75);
    await tester.pumpWidget(
      ChangeNotifierProvider<SettingsService>.value(
        value: settings,
        child: MaterialApp(
          home: Scaffold(body: WeatherWidget(fetcher: (_, __) async => throw Exception('offline'))),
        ),
      ),
    );
    await tester.pump();
    await tester.pump();

    expect(find.byType(Text), findsNothing);
  });
}
