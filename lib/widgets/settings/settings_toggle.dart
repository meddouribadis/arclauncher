import 'package:flutter/material.dart';

import 'settings_theme.dart';

/// A compact, low-overhead switch.
///
/// Replaces [Switch] inside settings rows: it is 42x24 instead of the 59x40
/// Material switch, animates with cheap [AnimatedContainer]s only (no ink, no
/// layout animation) and never needs an explicit thumb/track theme.
class SettingsSwitch extends StatelessWidget {
  final bool value;
  final Color accentColor;
  final Duration duration;

  static const double _width = 42;
  static const double _height = 24;
  static const double _knob = 18;

  /// Used instead of a white knob on light accent colours (white, yellow,
  /// cyan...), which would otherwise paint white on white.
  static const Color _darkKnob = Color(0xFF1A1A1E);

  const SettingsSwitch({
    super.key,
    required this.value,
    required this.accentColor,
    this.duration = SettingsStyle.focusDuration,
  });

  @override
  Widget build(BuildContext context) {
    // The knob must stay readable whatever accent the user picked.
    final lightTrack = accentColor.computeLuminance() > 0.55;
    final trackColor =
        value ? accentColor : Colors.white.withValues(alpha: 0.16);
    final borderColor = value
        ? (lightTrack
            ? Colors.black.withValues(alpha: 0.18)
            : Colors.white.withValues(alpha: 0.18))
        : Colors.white.withValues(alpha: 0.08);

    return Semantics(
      toggled: value,
      child: AnimatedContainer(
        duration: duration,
        curve: Curves.easeOutCubic,
        width: _width,
        height: _height,
        padding: const EdgeInsets.all(3),
        decoration: BoxDecoration(
          color: trackColor,
          borderRadius: BorderRadius.circular(_height / 2),
          border: Border.all(color: borderColor),
        ),
        child: AnimatedAlign(
          duration: duration,
          curve: Curves.easeOutCubic,
          alignment: value ? Alignment.centerRight : Alignment.centerLeft,
          child: AnimatedContainer(
            duration: duration,
            curve: Curves.easeOutCubic,
            width: _knob,
            height: _knob,
            decoration: BoxDecoration(
              color: value
                  ? (lightTrack ? _darkKnob : Colors.white)
                  : Colors.white.withValues(alpha: 0.78),
              shape: BoxShape.circle,
            ),
          ),
        ),
      ),
    );
  }
}
