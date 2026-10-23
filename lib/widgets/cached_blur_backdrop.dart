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

import 'dart:async';
import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flauncher/providers/wallpaper_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:provider/provider.dart';

/// Replaces a live [BackdropFilter] over the (static) wallpaper with a
/// pre-blurred snapshot of the wallpaper that is blitted behind [child].
///
/// A live [BackdropFilter] re-samples and re-blurs the scene on *every*
/// composited frame, which is expensive on low-end GPUs (e.g. Android TV
/// sticks). Because the wallpaper is static, we blur it once into a [ui.Image]
/// and simply copy the region located under this widget each frame — a cheap
/// blit that naturally follows scrolling through the paint offset.
///
/// Falls back to a live [BackdropFilter] while the snapshot is being prepared
/// or when the wallpaper is a video (which is not static).
///
/// Full-screen blurred wallpaper layer (no foreground content).
class CachedBlurLayer extends StatefulWidget {
  final double sigma;
  final ImageProvider? imageProvider;
  final Object? imageKey;
  final ui.Image? prebakedBlur;

  /// While hidden, skip re-snapshotting; the stale snapshot is refreshed once shown.
  final bool hidden;

  const CachedBlurLayer({
    super.key,
    required this.sigma,
    this.imageProvider,
    this.imageKey,
    this.prebakedBlur,
    this.hidden = false,
  });

  @override
  State<CachedBlurLayer> createState() => _CachedBlurLayerState();
}

class _CachedBlurLayerState extends _CachedBlurBackgroundState<CachedBlurLayer> {
  @override
  double get sigma => widget.sigma;

  @override
  ImageProvider? get customImageProvider => widget.imageProvider;

  @override
  Object? get customImageKey => widget.imageKey;

  @override
  ui.Image? get prebakedBlur => widget.prebakedBlur;

  @override
  bool get hidden => widget.hidden;

  @override
  Widget buildBlurContent(Widget blurBackground) => blurBackground;

  @override
  Widget buildLiveBlur() => const SizedBox.expand();
}

class CachedBlurBackdrop extends StatefulWidget {
  final double sigma;
  final ImageProvider? imageProvider;
  final Object? imageKey;
  final ui.Image? prebakedBlur;
  final Widget child;

  const CachedBlurBackdrop({
    super.key,
    required this.sigma,
    this.imageProvider,
    this.imageKey,
    this.prebakedBlur,
    required this.child,
  });

  @override
  State<CachedBlurBackdrop> createState() => _CachedBlurBackdropState();
}

class _CachedBlurBackdropState extends _CachedBlurBackgroundState<CachedBlurBackdrop> {
  @override
  double get sigma => widget.sigma;

  @override
  ImageProvider? get customImageProvider => widget.imageProvider;

  @override
  Object? get customImageKey => widget.imageKey;

  @override
  ui.Image? get prebakedBlur => widget.prebakedBlur;

  @override
  Widget buildBlurContent(Widget blurBackground) {
    return Stack(
      fit: StackFit.passthrough,
      children: [Positioned.fill(child: blurBackground), widget.child],
    );
  }

  // Same tree shape as [buildBlurContent] so the child isn't remounted when the snapshot swaps in.
  @override
  Widget buildLiveBlur() => buildBlurContent(const SizedBox.shrink());
}

abstract class _CachedBlurBackgroundState<T extends StatefulWidget> extends State<T> {
  ui.Image? _blurred;
  Size _builtSize = Size.zero;
  int _builtRevision = -1;
  String? _builtGradientId;
  double _builtSigma = -1;
  Object? _builtCustomKey;
  bool _building = false;

  @override
  void dispose() {
    _blurred?.dispose();
    super.dispose();
  }

  double get sigma;

  ImageProvider? get customImageProvider => null;
  Object? get customImageKey => null;
  ui.Image? get prebakedBlur => null;
  bool get hidden => false;

  Widget buildBlurContent(Widget blurBackground);

  Widget buildLiveBlur();

  Future<void> _build(WallpaperService service, Size size, double dpr) async {
    if (_building) return;
    _building = true;
    try {
      final double targetWidth = math.min(size.width * dpr, 960.0);
      final double targetHeight = math.min(size.height * dpr, 540.0);
      final pxWidth = targetWidth.round();
      final pxHeight = targetHeight.round();
      final rect = Rect.fromLTWH(0, 0, pxWidth.toDouble(), pxHeight.toDouble());

      ui.Image? source;
      final provider = customImageProvider ?? service.wallpaper;
      if (provider != null) {
        source = await _resolveImage(provider);
      }

      final double scaleFactor = pxWidth / size.width;
      final recorder = ui.PictureRecorder();
      final canvas = Canvas(recorder);
      final blurPaint =
          Paint()
            ..imageFilter = ui.ImageFilter.blur(
              sigmaX: sigma * scaleFactor,
              sigmaY: sigma * scaleFactor,
              tileMode: TileMode.clamp,
            );
      canvas.saveLayer(rect, blurPaint);
      if (source != null) {
        paintImage(canvas: canvas, rect: rect, image: source, fit: BoxFit.cover, filterQuality: FilterQuality.low);
      } else {
        canvas.drawRect(rect, Paint()..shader = service.gradient.gradient.createShader(rect));
      }
      canvas.restore();

      // toImageSync keeps the snapshot GPU-resident; toImage reads it back to the CPU (~40ms on a Fire TV stick).
      final image = recorder.endRecording().toImageSync(pxWidth, pxHeight);
      source?.dispose();

      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _blurred?.dispose();
        _blurred = image;
        _builtSize = size;
        _builtRevision = service.wallpaperRevision;
        _builtGradientId = provider == null ? service.gradient.uuid : null;
        _builtSigma = sigma;
        _builtCustomKey = customImageKey;
      });
    } finally {
      _building = false;
    }
  }

  Future<ui.Image> _resolveImage(ImageProvider provider) {
    final completer = Completer<ui.Image>();
    final stream = provider.resolve(const ImageConfiguration());
    late ImageStreamListener listener;
    listener = ImageStreamListener(
      (info, _) {
        stream.removeListener(listener);
        completer.complete(info.image);
      },
      onError: (error, stack) {
        stream.removeListener(listener);
        completer.completeError(error, stack);
      },
    );
    stream.addListener(listener);
    return completer.future;
  }

  @override
  Widget build(BuildContext context) {
    final prebaked = prebakedBlur;
    final service = context.watch<WallpaperService>();
    // Video wallpapers are not static: keep the live blur ONLY if no custom image provider is given.
    if (prebaked == null && customImageProvider == null && service.wallpaperVideoFile != null) {
      return buildLiveBlur();
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        final screen = MediaQuery.sizeOf(context);
        final dpr = MediaQuery.devicePixelRatioOf(context);
        if (prebaked == null) {
          final gradientId = (customImageProvider ?? service.wallpaper) == null ? service.gradient.uuid : null;
          final stale =
              _blurred == null ||
              _builtSize != screen ||
              _builtRevision != service.wallpaperRevision ||
              _builtGradientId != gradientId ||
              _builtSigma != sigma ||
              _builtCustomKey != customImageKey;
          if (stale && !hidden && screen.width > 0 && screen.height > 0) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              if (mounted) _build(service, screen, dpr);
            });
          }
        }
        final image = prebaked ?? _blurred;
        // Keep the previous snapshot while a new one is built to avoid a blur-less flash.
        if (image == null) {
          return buildLiveBlur();
        }
        // Crossfade snapshots in step with the immersive hero background (600ms in flauncher.dart).
        return buildBlurContent(
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            child: _BlurBlit(
              key: ObjectKey(image),
              image: image,
              screenSize: screen,
              scrollPosition: Scrollable.maybeOf(context)?.position,
            ),
          ),
        );
      },
    );
  }
}

/// Blits the region of the pre-blurred wallpaper [image] located under this
/// render box (in screen space) using the paint offset, so it stays aligned
/// with the wallpaper while scrolling.
class _BlurBlit extends LeafRenderObjectWidget {
  final ui.Image image;
  final Size screenSize;

  /// Repaints on scroll: an ancestor repaint boundary (e.g. a FadeTransition)
  /// would otherwise just be moved, leaving a stale crop.
  final ScrollPosition? scrollPosition;

  const _BlurBlit({super.key, required this.image, required this.screenSize, this.scrollPosition});

  // Clones (like RawImage) so an outgoing blit can keep painting after the owner disposes its handle.
  @override
  RenderObject createRenderObject(BuildContext context) => _BlurBlitRender(image.clone(), screenSize, scrollPosition);

  @override
  void updateRenderObject(BuildContext context, _BlurBlitRender renderObject) {
    renderObject
      ..image = image.clone()
      ..screenSize = screenSize
      ..scrollPosition = scrollPosition;
  }
}

class _BlurBlitRender extends RenderBox {
  ui.Image _image;
  Size _screenSize;
  ScrollPosition? _scrollPosition;

  _BlurBlitRender(this._image, this._screenSize, this._scrollPosition);

  set image(ui.Image value) {
    if (value.isCloneOf(_image)) {
      value.dispose();
      return;
    }
    _image.dispose();
    _image = value;
    markNeedsPaint();
  }

  set screenSize(Size value) {
    if (value != _screenSize) {
      _screenSize = value;
      markNeedsPaint();
    }
  }

  set scrollPosition(ScrollPosition? value) {
    if (value == _scrollPosition) return;
    if (attached) _scrollPosition?.removeListener(markNeedsPaint);
    _scrollPosition = value;
    if (attached) _scrollPosition?.addListener(markNeedsPaint);
  }

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    _scrollPosition?.addListener(markNeedsPaint);
  }

  @override
  void detach() {
    _scrollPosition?.removeListener(markNeedsPaint);
    super.detach();
  }

  @override
  void dispose() {
    _image.dispose();
    super.dispose();
  }

  @override
  bool get sizedByParent => true;

  @override
  Size computeDryLayout(BoxConstraints constraints) => constraints.biggest;

  @override
  void paint(PaintingContext context, Offset offset) {
    final scaleX = _image.width / _screenSize.width;
    final scaleY = _image.height / _screenSize.height;
    // Sample the blurred wallpaper at this box's true on-screen position so the
    // crop stays aligned with the real wallpaper (offset alone is layer-local).
    final screenPos = localToGlobal(Offset.zero);
    final src = Rect.fromLTWH(screenPos.dx * scaleX, screenPos.dy * scaleY, size.width * scaleX, size.height * scaleY);
    final dst = offset & size;
    context.canvas.drawImageRect(_image, src, dst, Paint()..filterQuality = FilterQuality.low);
  }
}
