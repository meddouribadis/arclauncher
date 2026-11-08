import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

const _enabledKey = "parental_control_enabled";
const _saltKey = "parental_control_salt";
const _hashKey = "parental_control_hash";
const _packagesKey = "parental_control_packages";
const _failuresKey = "parental_control_failures";
const _lockedUntilKey = "parental_control_locked_until";
const _graceUntilKey = "parental_control_grace_until";
const _settingsProtectedKey = "parental_control_protect_settings";
const _windowEnabledKey = "parental_control_window_enabled";
const _windowStartKey = "parental_control_window_start";
const _windowEndKey = "parental_control_window_end";

/// Symbols of a code: "U", "D", "L", "R" for arrows, "0".."9" for digits.
typedef ParentalCode = List<String>;

enum ParentalCheckResult { ok, wrong, lockedOut }

/// Parental control state: protected packages and the unlock code.
///
/// The code is never stored in clear: only a salted SHA-256 is persisted.
/// Protected packages live in SharedPreferences (no database migration).
class ParentalControlService extends ChangeNotifier {
  static const int minCodeLength = 4;
  static const int maxFailuresBeforeLock = 5;
  static const Duration graceDuration = Duration(minutes: 15);

  final SharedPreferences _prefs;
  final DateTime Function() _now;

  ParentalControlService(this._prefs, {DateTime Function()? now}) : _now = now ?? DateTime.now;

  bool get hasCode => _prefs.getString(_hashKey) != null;

  /// Gate is active only when switched on AND a code exists.
  bool get enabled => hasCode && (_prefs.getBool(_enabledKey) ?? false);

  bool get protectSettings => _prefs.getBool(_settingsProtectedKey) ?? false;

  Set<String> get protectedPackages => (_prefs.getStringList(_packagesKey) ?? const <String>[]).toSet();

  bool get windowEnabled => _prefs.getBool(_windowEnabledKey) ?? false;

  /// Minutes since midnight (0..1439). Defaults: 08:00 to 20:00.
  int get windowStartMinutes => _prefs.getInt(_windowStartKey) ?? 8 * 60;
  int get windowEndMinutes => _prefs.getInt(_windowEndKey) ?? 20 * 60;

  /// True when protection applies now: always, or inside the time window.
  /// A window whose end is before its start wraps over midnight.
  bool get windowActiveNow {
    if (!windowEnabled) return true;
    final n = _now();
    final minutes = n.hour * 60 + n.minute;
    final start = windowStartMinutes;
    final end = windowEndMinutes;
    if (start == end) return true;
    return start < end ? (minutes >= start && minutes < end) : (minutes >= start || minutes < end);
  }

  Future<void> setWindowEnabled(bool value) async {
    await _prefs.setBool(_windowEnabledKey, value);
    notifyListeners();
  }

  Future<void> setWindowStartMinutes(int minutes) async {
    await _prefs.setInt(_windowStartKey, ((minutes % 1440) + 1440) % 1440);
    notifyListeners();
  }

  Future<void> setWindowEndMinutes(int minutes) async {
    await _prefs.setInt(_windowEndKey, ((minutes % 1440) + 1440) % 1440);
    notifyListeners();
  }

  bool isProtected(String? packageName) =>
      enabled && windowActiveNow && packageName != null && protectedPackages.contains(packageName);

  bool get graceActive {
    final until = _prefs.getInt(_graceUntilKey);
    return until != null && _now().millisecondsSinceEpoch < until;
  }

  /// True if launching [packageName] needs the code right now.
  bool requiresCode(String? packageName) {
    if (graceActive) return false;
    // Unknown package (e.g. Watch Next item with only an intent URI): cannot
    // tell what it opens, so gate it whenever any app is protected.
    if (packageName == null) return enabled && windowActiveNow && protectedPackages.isNotEmpty;
    return isProtected(packageName);
  }

  /// True if opening launcher settings needs the code right now.
  bool get settingsRequireCode => enabled && windowActiveNow && protectSettings && !graceActive;

  Duration get lockRemaining {
    final until = _prefs.getInt(_lockedUntilKey);
    if (until == null) return Duration.zero;
    final remaining = until - _now().millisecondsSinceEpoch;
    return remaining > 0 ? Duration(milliseconds: remaining) : Duration.zero;
  }

  Future<void> setEnabled(bool value) async {
    await _prefs.setBool(_enabledKey, value);
    notifyListeners();
  }

  Future<void> setProtectSettings(bool value) async {
    await _prefs.setBool(_settingsProtectedKey, value);
    notifyListeners();
  }

  /// Replaces the code. Caller must have verified the old one beforehand.
  Future<void> setCode(ParentalCode code) async {
    if (code.length < minCodeLength) {
      throw ArgumentError("Code must contain at least $minCodeLength symbols");
    }
    final random = Random.secure();
    final salt = base64UrlEncode(List<int>.generate(16, (_) => random.nextInt(256)));
    await _prefs.setString(_saltKey, salt);
    await _prefs.setString(_hashKey, _hash(salt, code));
    await _prefs.remove(_failuresKey);
    await _prefs.remove(_lockedUntilKey);
    await _prefs.remove(_graceUntilKey);
    notifyListeners();
  }

  Future<ParentalCheckResult> verify(ParentalCode code) async {
    if (lockRemaining > Duration.zero) return ParentalCheckResult.lockedOut;
    final salt = _prefs.getString(_saltKey);
    final hash = _prefs.getString(_hashKey);
    if (salt == null || hash == null) return ParentalCheckResult.wrong;

    if (_constantTimeEquals(_hash(salt, code), hash)) {
      await _prefs.remove(_failuresKey);
      await _prefs.remove(_lockedUntilKey);
      await _prefs.setInt(_graceUntilKey, _now().add(graceDuration).millisecondsSinceEpoch);
      return ParentalCheckResult.ok;
    }

    final failures = (_prefs.getInt(_failuresKey) ?? 0) + 1;
    await _prefs.setInt(_failuresKey, failures);
    if (failures >= maxFailuresBeforeLock) {
      // 30 s, doubling for each further failure series, capped at 15 min.
      // Cap the exponent: 30 * 2^steps overflows int64 near steps 59.
      final steps = min(failures - maxFailuresBeforeLock, 5);
      final seconds = min(30 * pow(2, steps).toInt(), 900);
      await _prefs.setInt(
          _lockedUntilKey, _now().add(Duration(seconds: seconds)).millisecondsSinceEpoch);
      return ParentalCheckResult.lockedOut;
    }
    return ParentalCheckResult.wrong;
  }

  /// Ends the grace period so the code is asked again immediately.
  Future<void> relock() async {
    await _prefs.remove(_graceUntilKey);
    notifyListeners();
  }

  Future<void> setPackageProtected(String packageName, bool protect) async {
    final packages = protectedPackages;
    final changed = protect ? packages.add(packageName) : packages.remove(packageName);
    if (!changed) return;
    await _prefs.setStringList(_packagesKey, packages.toList()..sort());
    notifyListeners();
  }

  String _hash(String salt, ParentalCode code) =>
      sha256.convert(utf8.encode("$salt:${code.join()}")).toString();

  bool _constantTimeEquals(String a, String b) {
    if (a.length != b.length) return false;
    var diff = 0;
    for (var i = 0; i < a.length; i++) {
      diff |= a.codeUnitAt(i) ^ b.codeUnitAt(i);
    }
    return diff == 0;
  }
}
