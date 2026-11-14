import 'package:flauncher/l10n/app_localizations.dart';
import 'package:flauncher/widgets/tv_media_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('me.efesser.flauncher/method'),
      (MethodCall methodCall) async {
        if (methodCall.method == 'checkMediaPermissions') {
          return true;
        }
        if (methodCall.method == 'getMediaStoreImages' || methodCall.method == 'getMediaStoreVideos') {
          return <Map<String, dynamic>>[];
        }
        return null;
      },
    );
  });

  tearDown(() {
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger.setMockMethodCallHandler(
      const MethodChannel('me.efesser.flauncher/method'),
      null,
    );
  });

  Widget buildTestWidget(TvMediaPickerMode mode) {
    return MaterialApp(
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      supportedLocales: AppLocalizations.supportedLocales,
      home: Scaffold(body: TvMediaPicker(mode: mode)),
    );
  }

  testWidgets('displays imagePickerEmptyHint when image picker is empty', (tester) async {
    await tester.pumpWidget(buildTestWidget(TvMediaPickerMode.image));
    await tester.pumpAndSettle();

    expect(find.text('No images found on device'), findsOneWidget);
    expect(
      find.text('Pushed images with adb push? Clear their pending flag (see README) so they appear here.'),
      findsOneWidget,
    );
  });

  testWidgets('does not display imagePickerEmptyHint when video picker is empty', (tester) async {
    await tester.pumpWidget(buildTestWidget(TvMediaPickerMode.video));
    await tester.pumpAndSettle();

    expect(find.text('No videos found on device'), findsOneWidget);
    expect(
      find.text('Pushed images with adb push? Clear their pending flag (see README) so they appear here.'),
      findsNothing,
    );
  });
}
