import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/widgets/settings/update_dialogs.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  Widget buildApp(Widget child) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: child),
    );
  }

  testWidgets("showUpdateAvailableDialog displays changelog when provided", (tester) async {
    bool? result;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showUpdateAvailableDialog(
                  context,
                  AppLocalizations.of(context)!,
                  latestVersion: "1.0.10",
                  currentVersion: "1.0.9",
                  changelog: "## What's Changed\n* Fixed crash on startup (#43)\n* Added dark mode",
                );
              },
              child: const Text("Open Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text("Open Dialog"));
    await tester.pumpAndSettle();

    expect(find.text("Update available"), findsOneWidget);
    expect(find.text("Version 1.0.10 is available (current: 1.0.9)."), findsOneWidget);
    expect(find.text("What's new"), findsOneWidget);
    expect(find.text("What's Changed"), findsOneWidget);
    expect(find.text("Fixed crash on startup (#43)"), findsOneWidget);
    expect(find.text("Added dark mode"), findsOneWidget);

    // Tapping Download returns true
    await tester.tap(find.text("Download"));
    await tester.pumpAndSettle();

    expect(result, isTrue);
  });

  testWidgets("showUpdateAvailableDialog omits changelog section when null", (tester) async {
    bool? result;

    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                result = await showUpdateAvailableDialog(
                  context,
                  AppLocalizations.of(context)!,
                  latestVersion: "1.0.10",
                  currentVersion: "1.0.9",
                  changelog: null,
                );
              },
              child: const Text("Open Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text("Open Dialog"));
    await tester.pumpAndSettle();

    expect(find.text("Update available"), findsOneWidget);
    expect(find.text("What's new"), findsNothing);

    // Tapping Cancel returns false
    await tester.tap(find.text("Cancel"));
    await tester.pumpAndSettle();

    expect(result, isFalse);
  });

  testWidgets("showUpdateAvailableDialog supports D-pad navigation", (tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await showUpdateAvailableDialog(
                  context,
                  AppLocalizations.of(context)!,
                  latestVersion: "1.0.10",
                  currentVersion: "1.0.9",
                  changelog: "## Changes\n" + List.generate(30, (i) => "* Item $i").join("\n"),
                );
              },
              child: const Text("Open Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text("Open Dialog"));
    await tester.pumpAndSettle();

    // Primary action button is autofocused
    expect(tester.binding.focusManager.primaryFocus?.context?.widget, isA<Focus>());

    // Navigate up into the changelog container
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowUp);
    await tester.pumpAndSettle();

    // Scroll down within changelog
    await tester.sendKeyEvent(LogicalKeyboardKey.arrowDown);
    await tester.pumpAndSettle();
  });

  testWidgets("showNoUpdateDialog displays changelog when provided", (tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await showNoUpdateDialog(
                  context,
                  AppLocalizations.of(context)!,
                  currentVersion: "1.0.10",
                  changelog: "## What's Changed\n* Added video wallpaper support",
                );
              },
              child: const Text("Open Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text("Open Dialog"));
    await tester.pumpAndSettle();

    expect(find.text("No updates available"), findsOneWidget);
    expect(find.text("You are already on the latest version (1.0.10)."), findsOneWidget);
    expect(find.text("What's new"), findsOneWidget);
    expect(find.text("What's Changed"), findsOneWidget);
    expect(find.text("Added video wallpaper support"), findsOneWidget);

    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();

    expect(find.text("No updates available"), findsNothing);
  });

  testWidgets("showNoUpdateDialog omits changelog section when null", (tester) async {
    await tester.pumpWidget(
      buildApp(
        Builder(
          builder: (context) {
            return ElevatedButton(
              onPressed: () async {
                await showNoUpdateDialog(
                  context,
                  AppLocalizations.of(context)!,
                  currentVersion: "1.0.10",
                  changelog: null,
                );
              },
              child: const Text("Open Dialog"),
            );
          },
        ),
      ),
    );

    await tester.tap(find.text("Open Dialog"));
    await tester.pumpAndSettle();

    expect(find.text("No updates available"), findsOneWidget);
    expect(find.text("What's new"), findsNothing);

    await tester.tap(find.text("OK"));
    await tester.pumpAndSettle();

    expect(find.text("No updates available"), findsNothing);
  });
}
