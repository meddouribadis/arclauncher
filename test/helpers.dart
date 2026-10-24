import 'package:flauncher/widgets/app_bar_focus_ring.dart';
import 'package:flauncher/widgets/app_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Finder findAppCard(String packageName) => find.byWidgetPredicate(
  (w) => w is AppCard && w.application.packageName == packageName,
);

Element? findAppCardByPackageName(WidgetTester tester, String packageName) {
  for (var val in tester.elementList(find.byType(AppCard))) {
    if ((val.widget as AppCard).application.packageName == packageName) {
      return val;
    }
  }
  return null;
}

Element? findSettingsIcon(WidgetTester tester) {
  final elements = tester.elementList(find.byIcon(Icons.settings_outlined));
  return elements.isNotEmpty ? elements.first : null;
}

bool isAppCardFocused(WidgetTester tester, String packageName) {
  final appCardFinder = findAppCard(packageName);
  final inkWellFinder = find.descendant(of: appCardFinder, matching: find.byType(InkWell));
  if (inkWellFinder.evaluate().isEmpty) return false;
  final inkWell = tester.widget<InkWell>(inkWellFinder.first);
  return inkWell.focusNode?.hasFocus ?? false;
}

bool isSettingsIconFocused(WidgetTester tester) {
  final ringFinder = find.byType(AppBarFocusRing);
  if (ringFinder.evaluate().isEmpty) return false;
  final ring = tester.widget<AppBarFocusRing>(ringFinder.first);
  return ring.focusNode?.hasFocus ?? false;
}
