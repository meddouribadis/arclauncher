import 'package:arclauncher/widgets/app_card_contour_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AppCardContourPainter', () {
    test('shouldRepaint returns true when properties differ', () {
      const painter1 = AppCardContourPainter(accentColor: Colors.blue);
      const painter2 = AppCardContourPainter(accentColor: Colors.blue);
      const painterDifferentColor = AppCardContourPainter(accentColor: Colors.red);
      const painterDifferentAlpha = AppCardContourPainter(accentColor: Colors.blue, alpha: 0.5);
      const painterDifferentMoving = AppCardContourPainter(accentColor: Colors.blue, isMoving: true);

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painterDifferentColor), isTrue);
      expect(painter1.shouldRepaint(painterDifferentAlpha), isTrue);
      expect(painter1.shouldRepaint(painterDifferentMoving), isTrue);
    });

    testWidgets('paints normal focused specular sheen without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: const Size(200, 120),
                foregroundPainter: const AppCardContourPainter(
                  radius: 12.0,
                  strokeWidth: 1.0,
                  accentColor: Colors.amber,
                ),
                child: Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('paints moving state without error', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: const Size(200, 120),
                foregroundPainter: const AppCardContourPainter(
                  radius: 12.0,
                  strokeWidth: 2.0,
                  accentColor: Colors.blue,
                  isMoving: true,
                ),
                child: Container(
                  width: 200,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black,
                    borderRadius: BorderRadius.circular(12.0),
                  ),
                ),
              ),
            ),
          ),
        ),
      );

      expect(find.byType(CustomPaint), findsWidgets);
      await tester.pumpAndSettle();
    });

    testWidgets('handles empty or zero-stroke size gracefully', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: Size.zero,
                foregroundPainter: AppCardContourPainter(
                  radius: 12.0,
                  strokeWidth: 0.0,
                  accentColor: Colors.blue,
                ),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
