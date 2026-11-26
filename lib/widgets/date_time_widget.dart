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

import 'dart:async';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'animated_character.dart';

class DateTimeWidget extends StatefulWidget {
  final Duration?   updateInterval;
  final String      _dateTimeFormatString;
  final TextStyle?  textStyle;
  final bool        animate;

  const DateTimeWidget(String dateTimeFormatString, {
    super.key,
    this.updateInterval,
    this.textStyle,
    this.animate = false,
  }) :
      _dateTimeFormatString = dateTimeFormatString;

  @override
  State<DateTimeWidget> createState() => _DateTimeWidgetState();
}

class _DateTimeWidgetState extends State<DateTimeWidget> with WidgetsBindingObserver {
  late DateFormat _dateFormat;
  late DateTime   _now;
  late Timer      _timer;
  String?         _lastFormatted;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    _dateFormat = DateFormat(widget._dateTimeFormatString, Platform.localeName);
    _now = DateTime.now();
    _lastFormatted = _dateFormat.format(_now);
    _startTimer();
  }

  /// Starts the timer, aligning minute ticks to :00 so the clock updates
  /// exactly on the minute instead of up to a minute after rollover.
  void _startTimer() {
    final interval = widget.updateInterval ?? _defaultInterval();
    final first = interval == const Duration(minutes: 1)
        ? _delayToNextMinute()
        : Duration.zero;
    _timer = Timer(first, () {
      _refreshTime();
      _timer = Timer.periodic(interval, (_) => _refreshTime());
    });
  }

  Duration _delayToNextMinute() {
    final now = DateTime.now();
    final next = DateTime(now.year, now.month, now.day, now.hour, now.minute + 1);
    return next.difference(now);
  }

  // shortcut: only minute intervals are aligned; second-based formats poll every
  // second and are already within one second of the real time.

  /// Returns 1-second interval if format contains seconds, otherwise 1-minute.
  Duration _defaultInterval() {
    final fmt = widget._dateTimeFormatString;
    return (fmt.contains('s') || fmt.contains('S'))
        ? const Duration(seconds: 1)
        : const Duration(minutes: 1);
  }

  @override
  void didUpdateWidget(DateTimeWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Update format if it changed
    if (oldWidget._dateTimeFormatString != widget._dateTimeFormatString) {
      _dateFormat = DateFormat(widget._dateTimeFormatString, Platform.localeName);
      setState(() {
        _now = DateTime.now();
      });
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _timer.cancel();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) _refreshTime();
  }

  @override
  Widget build(BuildContext context) {
    final formattedText = _dateFormat.format(_now);
    
    if (widget.animate) {
      return AnimatedTimeDisplay(
        displayText: formattedText,
        textStyle: widget.textStyle,
      );
    }
    
    return Text(formattedText, style: widget.textStyle);
  }

  void _refreshTime() {
    final formatted = _dateFormat.format(DateTime.now());
    if (formatted == _lastFormatted) return;
    _lastFormatted = formatted;
    setState(() {
      _now = DateTime.now();
    });
  }
}
