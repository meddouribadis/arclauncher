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

import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flauncher/providers/settings_service.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:provider/provider.dart';

class WeatherReading {
  final int temperature;
  final int code;

  const WeatherReading(this.temperature, this.code);
}

typedef WeatherFetcher = Future<WeatherReading> Function(double latitude, double longitude);

/// Current conditions from Open-Meteo.
Future<WeatherReading> fetchOpenMeteoWeather(double latitude, double longitude) async {
  final response = await http
      .get(
        Uri.https('api.open-meteo.com', '/v1/forecast', {
          'latitude': latitude.toString(),
          'longitude': longitude.toString(),
          'current': 'temperature_2m,weather_code',
        }),
      )
      .timeout(const Duration(seconds: 10));
  if (response.statusCode != 200) throw const HttpException('Weather unavailable');
  final current = (jsonDecode(response.body) as Map<String, dynamic>)['current'] as Map<String, dynamic>;
  return WeatherReading((current['temperature_2m'] as num).round(), (current['weather_code'] as num).toInt());
}

/// Status bar temperature for the city chosen in the settings. Shows nothing until a city is chosen,
/// and requests the network only while the launcher is in the foreground.
class WeatherWidget extends StatefulWidget {
  final WeatherFetcher fetcher;
  final Duration refreshInterval;

  const WeatherWidget({
    super.key,
    this.fetcher = fetchOpenMeteoWeather,
    this.refreshInterval = const Duration(minutes: 45),
  });

  @override
  State<WeatherWidget> createState() => _WeatherWidgetState();
}

class _WeatherWidgetState extends State<WeatherWidget> with WidgetsBindingObserver {
  Timer? _timer;
  WeatherReading? _reading;
  String? _locationKey;
  bool _foreground = true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    if (_foreground) {
      _refresh();
    } else {
      _timer?.cancel();
      _timer = null;
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer?.cancel();
    super.dispose();
  }

  Future<void> _refresh() async {
    if (!mounted || !_foreground) return;
    final settings = context.read<SettingsService>();
    final latitude = settings.weatherLatitude;
    final longitude = settings.weatherLongitude;
    if (!settings.showWeatherInStatusBar || settings.weatherCity == null || latitude == null || longitude == null) {
      _timer?.cancel();
      _timer = null;
      return;
    }
    final key = '$latitude,$longitude';
    if (key != _locationKey) {
      _locationKey = key;
      setState(() => _reading = null);
    }
    _timer ??= Timer.periodic(widget.refreshInterval, (_) => _refresh());
    try {
      final reading = await widget.fetcher(latitude, longitude);
      if (mounted && _locationKey == key) setState(() => _reading = reading);
    } catch (_) {
      if (mounted && _locationKey == key) setState(() => _reading = null);
    }
  }

  IconData _icon(int code) {
    if (code == 0) return Icons.wb_sunny_outlined;
    if (code <= 3) return Icons.cloud_outlined;
    if (code >= 71 && code <= 77) return Icons.ac_unit;
    if (code >= 95) return Icons.thunderstorm_outlined;
    return Icons.water_drop_outlined;
  }

  @override
  Widget build(BuildContext context) {
    final city = context.select<SettingsService, String?>((s) => s.weatherCity);
    final key = context.select<SettingsService, String>((s) => '${s.weatherLatitude},${s.weatherLongitude}');
    if (key != _locationKey) WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
    final reading = _reading;
    if (city == null || reading == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(right: 16),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(_icon(reading.code), color: Colors.white, size: 20),
          const SizedBox(width: 4),
          Text(
            '$city ${reading.temperature}°',
            style: const TextStyle(
              fontSize: 18,
              color: Colors.white,
              shadows: [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4)],
            ),
          ),
        ],
      ),
    );
  }
}
