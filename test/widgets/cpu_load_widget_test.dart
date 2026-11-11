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
import 'package:flauncher/widgets/cpu_load_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  const interval = Duration(seconds: 3);

  Widget host(Future<String> Function() readStat) =>
      MaterialApp(home: Scaffold(body: CpuLoadWidget(readStat: readStat, interval: interval)));

  testWidgets('shows the load computed from two /proc/stat samples', (tester) async {
    final samples = [
      'cpu  100 0 100 800 0 0 0 0 0 0',
      'cpu  150 0 150 900 0 0 0 0 0 0', // 100 busy of 200 total -> 50%
    ];
    var reads = 0;
    await tester.pumpWidget(host(() async => samples[(reads++).clamp(0, 1)]));
    await tester.pump();
    expect(find.textContaining('CPU'), findsNothing); // one sample is not enough yet

    await tester.pump(interval);
    await tester.pump();
    expect(find.text('CPU 50%'), findsOneWidget);

    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('an unreadable /proc/stat hides the widget and stops polling', (tester) async {
    var reads = 0;
    await tester.pumpWidget(host(() async {
      reads++;
      throw const FormatException('Permission denied');
    }));
    await tester.pump();
    expect(reads, 1);
    expect(find.textContaining('CPU'), findsNothing);
    expect(find.textContaining('0%'), findsNothing);

    await tester.pump(interval * 3);
    expect(reads, 1);
    // No periodic timer is left running.
    expect(tester.binding.hasScheduledFrame, isFalse);
  });

  testWidgets('garbled /proc/stat content counts as unreadable', (tester) async {
    await tester.pumpWidget(host(() async => 'cpu not numbers'));
    await tester.pump();
    expect(find.textContaining('CPU'), findsNothing);
  });

  test('CpuSample parses the aggregate line', () {
    final sample = CpuSample.parse('cpu  10 0 10 70 10 0 0 0 0 0')!;
    expect(sample.total, 100);
    expect(sample.idle, 80);
    expect(CpuSample.parse('cpu 1 2'), isNull);
  });

  test('the CPU load switch is off by default and persists', () async {
    SharedPreferences.setMockInitialValues({});
    final settings = SettingsService(await SharedPreferences.getInstance());
    expect(settings.showCpuLoadInStatusBar, isFalse);
    await settings.setShowCpuLoadInStatusBar(true);
    expect(settings.showCpuLoadInStatusBar, isTrue);
  });
}
