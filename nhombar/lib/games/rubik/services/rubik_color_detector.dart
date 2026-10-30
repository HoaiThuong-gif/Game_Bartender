import 'dart:isolate';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

import '../models/rubik_face.dart';

/// Shared by the camera overlay and still-image sampler.
const scanFrameFraction = 0.82;

class DetectedRubikFace {
  const DetectedRubikFace(this.colors, this.uncertain, this.thumbnail);
  final List<RubikColor?> colors;
  final Set<int> uncertain;

  /// The exact square sampled, after EXIF orientation and aspect correction.
  final Uint8List thumbnail;
}

class RubikColorDetector {
  const RubikColorDetector();

  Future<DetectedRubikFace> detect(Uint8List bytes, double previewAspect) =>
      Isolate.run(() => detectStill(bytes, previewAspect));

  /// Assumes an aligned, flat face. Does not attempt contour detection.
  static DetectedRubikFace detectStill(Uint8List bytes, double previewAspect) {
    if (!previewAspect.isFinite || previewAspect <= 0) {
      throw ArgumentError('Invalid preview aspect ratio');
    }
    img.Image? decoded;
    try {
      decoded = img.decodeImage(bytes);
    } catch (_) {
      throw const FormatException('Cannot decode camera image');
    }
    if (decoded == null) {
      throw const FormatException('Cannot decode camera image');
    }
    var image = img.bakeOrientation(decoded);
    if (math.max(image.width, image.height) > 1280) {
      image = img.copyResize(
        image,
        width: image.width >= image.height ? 1280 : null,
        height: image.height > image.width ? 1280 : null,
      );
    }
    // CameraX preview and JPEG may have different aspect ratios. Match the
    // centered preview viewport first, then sample the overlay's square.
    final cropWidth = math.min(
      image.width,
      (image.height * previewAspect).round(),
    );
    final cropHeight = math.min(
      image.height,
      (image.width / previewAspect).round(),
    );
    final side = (math.min(cropWidth, cropHeight) * scanFrameFraction).floor();
    if (side < 30) throw const FormatException('Image too small');
    final face = img.copyCrop(
      image,
      x: (image.width - side) ~/ 2,
      y: (image.height - side) ~/ 2,
      width: side,
      height: side,
    );
    final colors = <RubikColor?>[];
    final uncertain = <int>{};
    for (var index = 0; index < 9; index++) {
      final red = <double>[], green = <double>[], blue = <double>[];
      final votes = <RubikColor, int>{};
      // 225 samples across the inner half of each sticker; ignore black seams.
      for (var sy = 0; sy < 15; sy++) {
        for (var sx = 0; sx < 15; sx++) {
          final x = ((index % 3 + .25 + sx / 28) * side / 3).floor();
          final y = ((index ~/ 3 + .25 + sy / 28) * side / 3).floor();
          final p = face.getPixel(x, y);
          red.add(p.r.toDouble());
          green.add(p.g.toDouble());
          blue.add(p.b.toDouble());
          final color = classifyRgb(
            p.r.toDouble(),
            p.g.toDouble(),
            p.b.toDouble(),
          );
          if (color != null) votes[color] = (votes[color] ?? 0) + 1;
        }
      }
      double median(List<double> values) {
        values.sort();
        return values[values.length ~/ 2];
      }

      final r = median(red), g = median(green), b = median(blue);
      final color = classifyRgb(r, g, b);
      colors.add(color);
      final hsv = _hsv(r, g, b);
      final nearBoundary = [
        12.0,
        40.0,
        76.0,
        170.0,
        285.0,
        345.0,
      ].any((edge) => (hsv.$1 - edge).abs() < 4);
      if (color == null ||
          (votes[color] ?? 0) / 225 < .70 ||
          hsv.$3 < .30 ||
          (hsv.$2 > .18 && hsv.$2 < .34) ||
          (hsv.$2 >= .26 && nearBoundary)) {
        uncertain.add(index);
      }
    }
    return DetectedRubikFace(
      List.unmodifiable(colors),
      Set.unmodifiable(uncertain),
      Uint8List.fromList(
        img.encodeJpg(img.copyResize(face, width: 300), quality: 85),
      ),
    );
  }

  static RubikColor? classifyRgb(double r, double g, double b) {
    final (h, s, v) = _hsv(r, g, b);
    if (v < .18) return null;
    if (s < .26) return RubikColor.white;
    if (h < 12 || h >= 345) return RubikColor.red;
    if (h < 40) return RubikColor.orange;
    if (h < 76) return RubikColor.yellow;
    if (h < 170) return RubikColor.green;
    if (h < 285) return RubikColor.blue;
    return null; // Purple/magenta are not valid stickers; require correction.
  }

  static (double, double, double) _hsv(double r, double g, double b) {
    final max = math.max(r, math.max(g, b));
    final min = math.min(r, math.min(g, b));
    final delta = max - min;
    var hue = 0.0;
    if (delta != 0) {
      if (max == r) {
        hue = 60 * (((g - b) / delta) % 6);
      } else if (max == g) {
        hue = 60 * ((b - r) / delta + 2);
      } else {
        hue = 60 * ((r - g) / delta + 4);
      }
    }
    return (hue, max == 0 ? 0 : delta / max, max / 255);
  }
}
