import 'package:arclauncher/widgets/dock_contour_painter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DockContourPainter', () {
    test('defines contour gradient matching the native Arc dock specular bevel', () {
      const gradient = DockContourPainter.contourGradient;
      expect(gradient.begin, Alignment.topCenter);
      expect(gradient.end, Alignment.bottomCenter);
      expect(gradient.stops, [0.0, 0.4, 1.0]);
      expect(gradient.colors, [
        const Color(0x40FFFFFF), // 25% white
        const Color(0x1AFFFFFF), // 10% white
        const Color(0x0AFFFFFF), // 4% white
      ]);
    });

    test('shouldRepaint returns true only when radius or strokeWidth differs', () {
      const painter1 = DockContourPainter(radius: 24.0, strokeWidth: 1.0);
      const painter2 = DockContourPainter(radius: 24.0, strokeWidth: 1.0);
      const painterDifferentRadius = DockContourPainter(radius: 16.0, strokeWidth: 1.0);
      const painterDifferentStroke = DockContourPainter(radius: 24.0, strokeWidth: 2.0);

      expect(painter1.shouldRepaint(painter2), isFalse);
      expect(painter1.shouldRepaint(painterDifferentRadius), isTrue);
      expect(painter1.shouldRepaint(painterDifferentStroke), isTrue);
    });

    testWidgets('paints without error on canvas', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: CustomPaint(
                size: const Size(600, 120),
                foregroundPainter: const DockContourPainter(radius: 24.0, strokeWidth: 1.0),
                child: Container(
                  width: 600,
                  height: 120,
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.3),
                    borderRadius: BorderRadius.circular(24.0),
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
                foregroundPainter: DockContourPainter(radius: 24.0, strokeWidth: 0.0),
              ),
            ),
          ),
        ),
      );

      expect(tester.takeException(), isNull);
    });
  });
}
