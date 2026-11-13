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

import 'dart:convert';

import 'package:http/http.dart' as http;

/// One Open-Meteo geocoding match.
class WeatherCity {
  final String name;
  final String? region;
  final String? country;
  final double latitude;
  final double longitude;

  const WeatherCity({
    required this.name,
    this.region,
    this.country,
    required this.latitude,
    required this.longitude,
  });

  /// "city, region, country" without empty parts.
  String get label => [name, region, country].whereType<String>().where((part) => part.isNotEmpty).join(', ');
}

typedef WeatherCitySearch = Future<List<WeatherCity>> Function(String query, String language);

/// Searches cities by name. Throws on network or server errors; an empty list means "no matches".
Future<List<WeatherCity>> searchWeatherCities(String query, String language, {http.Client? client}) async {
  final uri = Uri.https('geocoding-api.open-meteo.com', '/v1/search', {
    'name': query.trim(),
    'count': '8',
    'language': language,
    'format': 'json',
  });
  final response = await (client?.get(uri) ?? http.get(uri)).timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) {
    throw http.ClientException('Geocoding status ${response.statusCode}', uri);
  }
  final results = (jsonDecode(utf8.decode(response.bodyBytes)) as Map<String, dynamic>)['results'] as List<dynamic>?;
  return [
    for (final item in results ?? const [])
      WeatherCity(
        name: item['name'] as String,
        region: item['admin1'] as String?,
        country: item['country'] as String?,
        latitude: (item['latitude'] as num).toDouble(),
        longitude: (item['longitude'] as num).toDouble(),
      ),
  ];
}
