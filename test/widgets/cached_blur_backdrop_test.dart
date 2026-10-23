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

import 'dart:ui' as ui;

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flauncher/widgets/cached_blur_backdrop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../mocks.mocks.dart';

Future<ui.Image> _createTestImage(int width, int height, Color color) async {
  final recorder = ui.PictureRecorder();
  final canvas = Canvas(recorder);
  canvas.drawRect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()), Paint()..color = color);
  final picture = recorder.endRecording();
  final image = picture.toImageSync(width, height);
  picture.dispose();
  return image;
}

void main() {
  late MockWallpaperService wallpaperService;

  setUp(() {
    wallpaperService = MockWallpaperService();
  });

  testWidgets('CachedBlurBackdrop displays prebakedBlur directly without error', (tester) async {
    final image = await _createTestImage(100, 100, Colors.red);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<WallpaperService>.value(value: wallpaperService)],
        child: MaterialApp(
          home: Scaffold(
            body: CachedBlurBackdrop(
              sigma: 5,
              prebakedBlur: image,
              child: const Text('Backdrop child'),
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(find.text('Backdrop child'), findsOneWidget);
    expect(find.byType(CachedBlurBackdrop), findsOneWidget);

    image.dispose();
  });

  testWidgets('CachedBlurBackdrop crossfades when prebakedBlur changes', (tester) async {
    final image1 = await _createTestImage(100, 100, Colors.red);
    final image2 = await _createTestImage(100, 100, Colors.blue);

    final blurNotifier = ValueNotifier<ui.Image?>(image1);

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider<WallpaperService>.value(value: wallpaperService)],
        child: MaterialApp(
          home: Scaffold(
            body: ValueListenableBuilder<ui.Image?>(
              valueListenable: blurNotifier,
              builder: (context, blur, _) {
                return CachedBlurBackdrop(
                  sigma: 5,
                  prebakedBlur: blur,
                  child: const Text('Backdrop child'),
                );
              },
            ),
          ),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Change to image2
    blurNotifier.value = image2;
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));
    await tester.pumpAndSettle();

    expect(find.text('Backdrop child'), findsOneWidget);

    image1.dispose();
    image2.dispose();
  });
}
