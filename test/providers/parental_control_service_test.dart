import 'package:flauncher/providers/parental_control_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shared_preferences_platform_interface/shared_preferences_platform_interface.dart';

void main() {
  late SharedPreferences prefs;
  late DateTime now;
  late ParentalControlService service;

  setUp(() async {
    SharedPreferencesStorePlatform.instance = InMemorySharedPreferencesStore.empty();
    prefs = await SharedPreferences.getInstance();
    now = DateTime(2026, 1, 1, 12);
    service = ParentalControlService(prefs, now: () => now);
  });

  const code = ["U", "U", "D", "L", "R"];

  test("nothing is gated without a code", () async {
    await service.setPackageProtected("com.youtube", true);
    expect(service.enabled, isFalse);
    expect(service.requiresCode("com.youtube"), isFalse);
  });

  test("code is not stored in clear", () async {
    await service.setCode(code);
    final stored = prefs.getKeys().map((k) => prefs.get(k).toString()).join("|");
    expect(stored.contains("UUDLR"), isFalse);
  });

  test("too short code is rejected", () async {
    expect(() => service.setCode(["U", "D"]), throwsArgumentError);
  });

  test("protected app requires code until correct code, then grace for 15 min", () async {
    await service.setCode(code);
    await service.setEnabled(true);
    await service.setPackageProtected("com.youtube", true);

    expect(service.requiresCode("com.youtube"), isTrue);
    expect(service.requiresCode("com.other"), isFalse);

    expect(await service.verify(code), ParentalCheckResult.ok);
    expect(service.requiresCode("com.youtube"), isFalse);

    now = now.add(const Duration(minutes: 16));
    expect(service.requiresCode("com.youtube"), isTrue);
  });

  test("wrong code does not open grace", () async {
    await service.setCode(code);
    await service.setEnabled(true);
    await service.setPackageProtected("com.youtube", true);
    expect(await service.verify(["D", "D", "D", "D"]), ParentalCheckResult.wrong);
    expect(service.requiresCode("com.youtube"), isTrue);
  });

  test("lockout after repeated failures, even for the right code", () async {
    await service.setCode(code);
    for (var i = 0; i < ParentalControlService.maxFailuresBeforeLock - 1; i++) {
      expect(await service.verify(["D", "D", "D", "D"]), ParentalCheckResult.wrong);
    }
    expect(await service.verify(["D", "D", "D", "D"]), ParentalCheckResult.lockedOut);
    expect(await service.verify(code), ParentalCheckResult.lockedOut);

    now = now.add(const Duration(seconds: 31));
    expect(await service.verify(code), ParentalCheckResult.ok);
  });

  test("relock ends grace period", () async {
    await service.setCode(code);
    await service.setEnabled(true);
    await service.setPackageProtected("com.youtube", true);
    await service.verify(code);
    await service.relock();
    expect(service.requiresCode("com.youtube"), isTrue);
  });

  test("settings gate only when protectSettings is on", () async {
    await service.setCode(code);
    await service.setEnabled(true);
    expect(service.settingsRequireCode, isFalse);
    await service.setProtectSettings(true);
    expect(service.settingsRequireCode, isTrue);
  });
}
