import 'package:arclauncher/actions.dart';
import 'package:flutter/material.dart';

import 'baked_paint.dart';
import 'settings/settings_theme.dart';

/// The sliding settings surface.
///
/// Dark glass material: a soft dark gradient with a faint accent glow in
/// the top corner and a single specular hairline on the inner edge. Deliberately
/// avoids [BackdropFilter] and elevation shadows, both of which force expensive
/// offscreen layers on TV GPUs.
class SidePanelDialog extends StatelessWidget {
  final Widget child;
  final double width;
  final bool isRightSide;

  const SidePanelDialog({
    required this.child,
    this.width = 250,
    this.isRightSide = false,
  });

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final radius = BorderRadius.horizontal(
      right: isRightSide ? Radius.zero : const Radius.circular(SettingsStyle.panelRadius),
      left: isRightSide ? const Radius.circular(SettingsStyle.panelRadius) : Radius.zero,
    );

    return Align(
      alignment: isRightSide ? Alignment.centerRight : Alignment.centerLeft,
      child: ClipRRect(
        borderRadius: radius,
        child: SizedBox(
          width: width,
          child: Stack(
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: BakedPaint(
                    resolution: 0.5,
                    painter: _PanelBackgroundPainter(accentColor: accentColor, isRightSide: isRightSide),
                  ),
                ),
              ),
              Positioned(
                top: 0,
                bottom: 0,
                left: isRightSide ? 0 : null,
                right: isRightSide ? null : 0,
                child: Container(width: 1, color: Colors.white.withValues(alpha: 0.08)),
              ),
              Material(
                color: Colors.transparent,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Actions(
                    actions: {BackIntent: BackAction(context)},
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PanelBackgroundPainter extends CustomPainter {
  final Color accentColor;
  final bool isRightSide;

  const _PanelBackgroundPainter({required this.accentColor, required this.isRightSide});

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Offset.zero & size;
    canvas.drawRect(
      rect,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [SettingsStyle.panelTop, SettingsStyle.panelBottom],
        ).createShader(rect),
    );
    canvas.drawRect(
      rect,
      Paint()
        ..shader = RadialGradient(
          center: isRightSide ? const Alignment(1, -1.2) : const Alignment(-1, -1.2),
          radius: 1.4,
          colors: [accentColor.withValues(alpha: 0.20), accentColor.withValues(alpha: 0.04), Colors.transparent],
          stops: const [0.0, 0.45, 1.0],
        ).createShader(rect),
    );
  }

  @override
  bool shouldRepaint(_PanelBackgroundPainter oldDelegate) =>
      oldDelegate.accentColor != accentColor || oldDelegate.isRightSide != isRightSide;
}
