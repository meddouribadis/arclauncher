import 'package:flutter/material.dart';

/// Shared visual language for the settings side panel.
///
/// Features dark glass rows, a soft specular
/// hairline, a restrained lift on focus and generous breathing room.
///
/// Everything here is deliberately cheap to paint. There is no
/// [BackdropFilter], no [BoxShadow] and no animated layout property: focus
/// feedback is a single [CustomPaint] plus a composited scale transform, so a
/// focus change repaints one small row instead of the whole panel.
abstract final class SettingsStyle {
  /// Focus lift/highlight animation.
  static const Duration focusDuration = Duration(milliseconds: 160);

  /// Row card geometry.
  static const double cardRadius = 16;
  static const EdgeInsets cardMargin = EdgeInsets.symmetric(
    horizontal: 8,
    vertical: 3,
  );
  static const EdgeInsets cardPadding = EdgeInsets.symmetric(
    horizontal: 14,
    vertical: 11,
  );

  /// Page header geometry.
  static const EdgeInsets headerPadding = EdgeInsets.fromLTRB(8, 6, 8, 8);

  /// Leading icon chip geometry.
  static const double iconChipSize = 34;
  static const double iconChipRadius = 10;
  static const double iconSize = 20;

  /// Scale applied to the focused row (1.0 means no lift).
  static const double focusScale = 1.018;

  static const double panelWidth = 380;
  static const double panelRadius = 32;

  static const Color panelTop = Color(0xFF2A2A2F);
  static const Color panelBottom = Color(0xFF161618);

  static const Color rowRestFill = Color(0x0AFFFFFF); // white @ 4%
  static const Color rowFocusFill = Color(0x1CFFFFFF); // white @ 11%

  static Duration focusDurationFor(BuildContext context) {
    final reduceMotion =
        MediaQuery.maybeOf(context)?.disableAnimations ?? false;
    return reduceMotion ? Duration.zero : focusDuration;
  }
}

/// Title block used at the top of every settings page.
///
/// It replaces the former `Text(title)` + `Divider()` pair with a large,
/// left-aligned title and a specular hairline that fades out to the right.
class SettingsPageHeader extends StatelessWidget {
  final String title;

  const SettingsPageHeader({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Padding(
      padding: SettingsStyle.headerPadding,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          Padding(
            padding: const EdgeInsets.only(left: 6, top: 8),
            child: Text(
              title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w600,
                letterSpacing: 0.1,
                height: 1.15,
              ),
            ),
          ),
          const SizedBox(height: 12),
          const SettingsHairline(),
        ],
      ),
    );
  }
}

/// A one pixel divider that dissolves towards the trailing edge.
class SettingsHairline extends StatelessWidget {
  final double opacity;

  const SettingsHairline({super.key, this.opacity = 1});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.white.withValues(alpha: 0.12 * opacity),
            Colors.white.withValues(alpha: 0.02 * opacity),
          ],
        ),
      ),
    );
  }
}

/// Separator between logical groups of rows inside a settings page.
class SettingsSectionDivider extends StatelessWidget {
  final EdgeInsetsGeometry margin;

  const SettingsSectionDivider({
    super.key,
    this.margin = const EdgeInsets.fromLTRB(14, 10, 14, 10),
  });

  @override
  Widget build(BuildContext context) =>
      Padding(padding: margin, child: const SettingsHairline());
}

/// A focusable glass surface with interactive focus feedback.
///
/// Focus and hover both drive a single 0..1 animation that:
/// - lifts the card with a composited scale transform,
/// - brightens the glass fill,
/// - paints a specular gradient hairline.
///
/// The [builder] is rebuilt only when the highlight state changes, never on
/// animation ticks, which keeps focus navigation at a stable frame rate.
class SettingsFocusCard extends StatefulWidget {
  final Widget Function(BuildContext context, bool highlighted) builder;
  final VoidCallback? onPressed;
  final ValueChanged<bool>? onFocusChange;
  final bool autofocus;
  final EdgeInsetsGeometry margin;
  final EdgeInsetsGeometry padding;
  final double radius;

  const SettingsFocusCard({
    super.key,
    required this.builder,
    this.onPressed,
    this.onFocusChange,
    this.autofocus = false,
    this.margin = SettingsStyle.cardMargin,
    this.padding = SettingsStyle.cardPadding,
    this.radius = SettingsStyle.cardRadius,
  });

  @override
  State<SettingsFocusCard> createState() => _SettingsFocusCardState();
}

class _SettingsFocusCardState extends State<SettingsFocusCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _highlight = AnimationController(
    vsync: this,
    duration: SettingsStyle.focusDuration,
  );
  Duration _duration = SettingsStyle.focusDuration;
  bool _focused = false;
  bool _hovered = false;

  bool get _highlighted => _focused || _hovered;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Respect the platform "reduce motion" setting.
    _duration = SettingsStyle.focusDurationFor(context);
  }

  @override
  void dispose() {
    _highlight.dispose();
    super.dispose();
  }

  void _syncHighlight() {
    final target = _highlighted ? 1.0 : 0.0;
    if (_duration == Duration.zero) {
      _highlight.value = target;
    } else {
      _highlight.animateTo(
        target,
        duration: _duration,
        curve: Curves.easeOutCubic,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final accentColor = Theme.of(context).colorScheme.primary;
    final content = Padding(
      padding: widget.padding,
      child: widget.builder(context, _highlighted),
    );

    return Padding(
      padding: widget.margin,
      child: RepaintBoundary(
        child: Actions(
          actions: <Type, Action<Intent>>{
            ActivateIntent: CallbackAction<ActivateIntent>(
              onInvoke: (_) => widget.onPressed?.call(),
            ),
            ButtonActivateIntent: CallbackAction<ButtonActivateIntent>(
              onInvoke: (_) => widget.onPressed?.call(),
            ),
          },
          child: MouseRegion(
            cursor: widget.onPressed == null
                ? MouseCursor.defer
                : SystemMouseCursors.click,
            onEnter: (_) {
              if (!_hovered) {
                setState(() => _hovered = true);
                _syncHighlight();
              }
            },
            onExit: (_) {
              if (_hovered) {
                setState(() => _hovered = false);
                _syncHighlight();
              }
            },
            child: Focus(
              autofocus: widget.autofocus,
              onFocusChange: (focused) {
                if (_focused != focused) {
                  setState(() => _focused = focused);
                  _syncHighlight();
                  widget.onFocusChange?.call(focused);
                }
              },
              child: GestureDetector(
                behavior: HitTestBehavior.opaque,
                onTap: widget.onPressed,
                child: AnimatedBuilder(
                  animation: _highlight,
                  child: content,
                  builder: (context, child) => Transform.scale(
                    scale:
                        1 + (SettingsStyle.focusScale - 1) * _highlight.value,
                    child: CustomPaint(
                      painter: SettingsSurfacePainter(
                        progress: _highlight.value,
                        accentColor: accentColor,
                        radius: widget.radius,
                      ),
                      child: child,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Paints the glass fill and specular hairline of a settings row.
class SettingsSurfacePainter extends CustomPainter {
  final double progress;
  final Color accentColor;
  final double radius;

  const SettingsSurfacePainter({
    required this.progress,
    required this.accentColor,
    this.radius = SettingsStyle.cardRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) return;

    final rect = Offset.zero & size;
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(radius));
    final t = progress.clamp(0.0, 1.0);

    // Glass fill: slightly brighter when highlighted.
    canvas.drawRRect(
      rrect,
      Paint()
        ..color = Color.lerp(
          SettingsStyle.rowRestFill,
          SettingsStyle.rowFocusFill,
          t,
        )!,
    );

    // Accent wash, so focus picks up the user's accent color.
    if (t > 0.001) {
      canvas.drawRRect(
        rrect,
        Paint()..color = accentColor.withValues(alpha: 0.12 * t),
      );
    }

    // Specular hairline: neutral at rest, white -> accent -> white on focus.
    final borderRect = rect.deflate(0.5);
    final borderRRect = RRect.fromRectAndRadius(
      borderRect,
      Radius.circular((radius - 0.5).clamp(0.0, double.infinity)),
    );
    final white = Colors.white;
    final borderPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        stops: const [0.0, 0.45, 1.0],
        colors: [
          Color.lerp(
            white.withValues(alpha: 0.07),
            white.withValues(alpha: 0.62),
            t,
          )!,
          Color.lerp(
            white.withValues(alpha: 0.04),
            accentColor.withValues(alpha: 0.55),
            t,
          )!,
          Color.lerp(
            white.withValues(alpha: 0.07),
            white.withValues(alpha: 0.26),
            t,
          )!,
        ],
      ).createShader(borderRect);

    canvas.drawRRect(borderRRect, borderPaint);
  }

  @override
  bool shouldRepaint(covariant SettingsSurfacePainter oldDelegate) =>
      oldDelegate.progress != progress ||
      oldDelegate.accentColor != accentColor ||
      oldDelegate.radius != radius;
}
