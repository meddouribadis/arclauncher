import 'dart:ui' as ui;

import 'package:flutter/material.dart';

/// Rasterizes [painter] once into a texture and blits it on later frames.
///
/// Skia shades and dithers gradients per pixel on every frame, which costs
/// several milliseconds per layer on Fire TV GPUs; a texture blit does not.
/// Smooth content can be baked at a fraction of the device [resolution].
class BakedPaint extends StatefulWidget {
  final CustomPainter painter;
  final double resolution;

  const BakedPaint({super.key, required this.painter, this.resolution = 1.0});

  @override
  State<BakedPaint> createState() => _BakedPaintState();
}

class _BakedPaintState extends State<BakedPaint> {
  ui.Image? _image;
  CustomPainter? _bakedPainter;
  Size _bakedSize = Size.zero;
  double _bakedScale = 0;

  @override
  void dispose() {
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scale = MediaQuery.devicePixelRatioOf(context) * widget.resolution;
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = constraints.biggest;
        if (size.isEmpty) {
          return const SizedBox.shrink();
        }
        if (_image == null ||
            size != _bakedSize ||
            scale != _bakedScale ||
            widget.painter.shouldRepaint(_bakedPainter!)) {
          _bake(size, scale);
        }
        return RawImage(
          image: _image,
          width: size.width,
          height: size.height,
          fit: BoxFit.fill,
          filterQuality: FilterQuality.low,
        );
      },
    );
  }

  void _bake(Size size, double scale) {
    final recorder = ui.PictureRecorder();
    final canvas = Canvas(recorder)..scale(scale);
    widget.painter.paint(canvas, size);
    final picture = recorder.endRecording();
    final image = picture.toImageSync(
      (size.width * scale).ceil().clamp(1, 1 << 14),
      (size.height * scale).ceil().clamp(1, 1 << 14),
    );
    picture.dispose();
    _image?.dispose();
    _image = image;
    _bakedPainter = widget.painter;
    _bakedSize = size;
    _bakedScale = scale;
  }
}
