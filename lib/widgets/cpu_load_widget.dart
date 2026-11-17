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
import 'dart:io';

import 'package:flutter/material.dart';

/// Reads the first line of /proc/stat. Throws when the file is not readable (SELinux blocks it on
/// Android 8+ for ordinary apps).
Future<String> readProcStat() async => (await File('/proc/stat').readAsLines()).first;

/// Aggregate CPU time counters taken from the first /proc/stat line.
class CpuSample {
  final int total;
  final int idle;

  const CpuSample(this.total, this.idle);

  static CpuSample? parse(String line) {
    final fields = line.trim().split(RegExp(r'\s+')).skip(1).map(int.tryParse).toList();
    if (fields.length < 5 || fields.contains(null)) return null;
    final values = fields.cast<int>();
    return CpuSample(values.fold<int>(0, (sum, value) => sum + value), values[3] + values[4]);
  }
}

/// Status bar CPU load in percent, computed from /proc/stat deltas. Polls only while the launcher is
/// in the foreground. If /proc/stat cannot be read the widget hides itself and stops polling.
class CpuLoadWidget extends StatefulWidget {
  final Future<String> Function() readStat;
  final Duration interval;

  const CpuLoadWidget({super.key, this.readStat = readProcStat, this.interval = const Duration(seconds: 3)});

  @override
  State<CpuLoadWidget> createState() => _CpuLoadWidgetState();
}

class _CpuLoadWidgetState extends State<CpuLoadWidget> with WidgetsBindingObserver {
  Timer? _timer;
  CpuSample? _last;
  int? _percent;
  bool _unreadable = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _start();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _start();
    } else {
      _stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _stop();
    super.dispose();
  }

  void _start() {
    if (_timer != null || _unreadable) return;
    _read();
    _timer = Timer.periodic(widget.interval, (_) => _read());
  }

  void _stop() {
    _timer?.cancel();
    _timer = null;
    _last = null;
  }

  Future<void> _read() async {
    try {
      final sample = CpuSample.parse(await widget.readStat());
      if (sample == null) throw const FormatException('Unexpected /proc/stat format');
      final last = _last;
      _last = sample;
      if (last == null || !mounted) return;
      final deltaTotal = sample.total - last.total;
      if (deltaTotal <= 0) return;
      final busy = deltaTotal - (sample.idle - last.idle);
      setState(() => _percent = (busy * 100 / deltaTotal).round().clamp(0, 100));
    } catch (_) {
      _stop();
      _unreadable = true;
      if (mounted) setState(() => _percent = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final percent = _percent;
    if (percent == null) return const SizedBox.shrink();
    return Padding(
      padding: const EdgeInsets.only(left: 8),
      child: Text(
        'CPU $percent%',
        style: const TextStyle(
          fontSize: 18,
          color: Colors.white,
          shadows: [Shadow(color: Colors.black54, offset: Offset(0, 2), blurRadius: 4)],
        ),
      ),
    );
  }
}
