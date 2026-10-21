import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'lobby_cats.dart';
import 'nam_cat_state_controller.dart';

/// Per-cat atlas regions enclose complete authored poses, excluding loose parts.
abstract final class NamFrames {
  static Rect searchRegion(Rect selection, int width, int height) => selection
      .inflate(32)
      .intersect(Rect.fromLTWH(0, 0, width.toDouble(), height.toDouble()));
  static bool supports(
    CatPose pose,
    CatExpression expression, [
    CatType type = CatType.black,
  ]) => expression == CatExpression.observing
      ? switch ((type, pose)) {
          (CatType.black, CatPose.standing) ||
          (CatType.orange, CatPose.sitting) ||
          (CatType.tuxedo, CatPose.standing) ||
          (CatType.tuxedo, CatPose.resting) => true,
          _ => false,
        }
      : (type != CatType.tuxedo ||
                pose != CatPose.sitting ||
                expression == CatExpression.neutral) &&
            (expression != CatExpression.annoyed ||
                (type == CatType.black
                    ? pose == CatPose.standing || pose == CatPose.resting
                    : type == CatType.tuxedo ||
                          pose == CatPose.sitting ||
                          pose == CatPose.standing));
  static String name(CatType type) => type.assetName;
  static String asset(CatPose pose, [CatType type = CatType.black]) =>
      LobbyCat(type, pose).asset;
  static String label(CatPose pose) => switch (pose) {
    CatPose.sitting => 'Ngồi',
    CatPose.standing => 'Đứng',
    CatPose.sleeping => 'Ngủ',
    CatPose.resting => 'Chuẩn bị vồ',
  };
  static Size canvas(CatPose pose) => switch (pose) {
    CatPose.sitting => const Size(480, 480),
    CatPose.standing => const Size(360, 360),
    _ => const Size(340, 280),
  };
  static Rect source(
    CatPose pose,
    CatExpression expression, [
    CatType type = CatType.black,
  ]) {
    if (expression == CatExpression.observing) {
      // Whole authored figures; no head/eye compositing or synthetic rotation.
      return switch ((type, pose)) {
        (CatType.black, CatPose.standing) => const Rect.fromLTWH(
          330,
          765,
          267,
          310,
        ),
        (CatType.orange, CatPose.sitting) => const Rect.fromLTWH(
          35,
          360,
          280,
          345,
        ),
        (CatType.tuxedo, CatPose.standing) => const Rect.fromLTWH(
          1140,
          320,
          308,
          290,
        ),
        (CatType.tuxedo, CatPose.resting) => const Rect.fromLTWH(
          1015,
          950,
          239,
          265,
        ),
        _ => source(pose, CatExpression.neutral, type),
      };
    }
    final index = expression.index;
    // Each rectangle encloses one complete authored character. No face parts,
    // synthetic eyelids, or composites are used for any reaction.
    final regions = switch ((type, pose)) {
      (CatType.black, CatPose.sitting) => const [
        Rect.fromLTWH(115, 635, 390, 440),
        Rect.fromLTWH(950, 640, 465, 435),
        Rect.fromLTWH(535, 635, 405, 440),
        Rect.fromLTWH(115, 635, 390, 440),
      ],
      (CatType.black, CatPose.standing) => const [
        Rect.fromLTWH(30, 765, 297, 310),
        Rect.fromLTWH(598, 765, 267, 310),
        Rect.fromLTWH(865, 765, 285, 310),
        Rect.fromLTWH(1145, 765, 290, 310),
      ],
      (CatType.black, CatPose.sleeping) => const [
        Rect.fromLTWH(15, 830, 276, 245),
        Rect.fromLTWH(1150, 830, 285, 245),
        Rect.fromLTWH(15, 830, 276, 245),
        Rect.fromLTWH(15, 830, 276, 245),
      ],
      (CatType.black, CatPose.resting) => const [
        Rect.fromLTWH(15, 825, 288, 250),
        Rect.fromLTWH(1150, 825, 290, 250),
        Rect.fromLTWH(303, 825, 285, 250),
        Rect.fromLTWH(590, 825, 280, 250),
      ],
      (CatType.orange, CatPose.sitting) => const [
        Rect.fromLTWH(40, 10, 310, 350),
        Rect.fromLTWH(610, 10, 282, 350),
        Rect.fromLTWH(890, 10, 277, 350),
        Rect.fromLTWH(1165, 10, 280, 350),
      ],
      (CatType.orange, CatPose.standing) => const [
        Rect.fromLTWH(610, 30, 320, 340),
        Rect.fromLTWH(570, 370, 240, 310),
        Rect.fromLTWH(935, 30, 319, 340),
        Rect.fromLTWH(810, 370, 230, 310),
      ],
      (CatType.orange, CatPose.sleeping) => const [
        Rect.fromLTWH(435, 75, 250, 235),
        Rect.fromLTWH(1180, 75, 250, 235),
        Rect.fromLTWH(435, 75, 250, 235),
        Rect.fromLTWH(435, 75, 250, 235),
      ],
      (CatType.orange, CatPose.resting) => const [
        Rect.fromLTWH(575, 0, 330, 330),
        Rect.fromLTWH(915, 0, 339, 330),
        Rect.fromLTWH(1030, 330, 224, 265),
        Rect.fromLTWH(575, 0, 330, 330),
      ],
      (CatType.tuxedo, CatPose.sitting) => const [
        // The top-row figures overlap through their hips/tails in the source.
        // This complete second-row figure is isolated by transparent gutters.
        Rect.fromLTWH(20, 385, 270, 360),
        Rect.fromLTWH(20, 385, 270, 360),
        Rect.fromLTWH(20, 385, 270, 360),
        Rect.fromLTWH(20, 385, 270, 360),
      ],
      (CatType.tuxedo, CatPose.standing) => const [
        Rect.fromLTWH(450, 10, 360, 310),
        Rect.fromLTWH(450, 320, 360, 290),
        Rect.fromLTWH(810, 10, 330, 310),
        Rect.fromLTWH(1140, 10, 308, 310),
      ],
      (CatType.tuxedo, CatPose.sleeping) => const [
        Rect.fromLTWH(475, 50, 255, 225),
        Rect.fromLTWH(730, 50, 260, 225),
        Rect.fromLTWH(475, 50, 255, 225),
        Rect.fromLTWH(990, 50, 264, 225),
      ],
      (CatType.tuxedo, CatPose.resting) => const [
        Rect.fromLTWH(0, 950, 277, 265),
        Rect.fromLTWH(760, 950, 250, 265),
        Rect.fromLTWH(275, 950, 240, 265),
        Rect.fromLTWH(510, 950, 250, 265),
      ],
    };
    return regions[index];
  }
}

class NamFrame {
  NamFrame(
    this.image,
    this.pixels,
    this.bounds,
    this.pose, {
    this.sourceOrigin = Offset.zero,
    this.sourceRegion = Rect.zero,
  });
  final ui.Image image;
  final Uint8List pixels;
  final Rect bounds;
  final CatPose pose;
  final Offset sourceOrigin;
  final Rect sourceRegion;
  late Size referenceSize = bounds.size;
  late double referenceHeight = bounds.height;
  double get pixelsPerReferenceUnit => bounds.height / referenceHeight;

  /// Contact between the authored front paws (or the curled body's support).
  /// Keep this point fixed when pose/expression changes, rather than centring
  /// the silhouette including its tail.
  Offset get contactFraction => switch (pose) {
    CatPose.sitting => const Offset(.40, 1),
    CatPose.standing => const Offset(.32, 1),
    CatPose.sleeping => const Offset(.50, 1),
    CatPose.resting => const Offset(.28, 1),
  };
  late final Offset contactPoint = _measureContact();

  Offset _measureContact() {
    // Measure the supporting paw pixels of each authored frame. The tail can
    // change shape between expressions without pulling the paws sideways.
    final band = switch (pose) {
      CatPose.sitting => .04,
      CatPose.standing => .025,
      CatPose.sleeping => .025,
      CatPose.resting => .035,
    };
    final endX =
        (bounds.left + bounds.width * (pose == CatPose.sleeping ? 1 : .75))
            .ceil();
    var left = image.width, right = -1;
    for (
      var y = (bounds.bottom - bounds.height * band).floor();
      y < bounds.bottom.toInt();
      y++
    ) {
      for (var x = bounds.left.toInt(); x < endX; x++) {
        if (pixels[(y * image.width + x) * 4 + 3] <= 32) continue;
        if (x < left) left = x;
        if (x > right) right = x;
      }
    }
    return Offset(
      right >= left
          ? (left + right + 1) / 2
          : bounds.left + bounds.width * contactFraction.dx,
      bounds.bottom,
    );
  }

  bool opaque(Offset point, Size display) {
    if (!(Offset.zero & display).contains(point)) return false;
    final x = (point.dx / display.width * image.width).floor();
    final y = (point.dy / display.height * image.height).floor();
    return pixels[(y * image.width + x) * 4 + 3] > 32;
  }

  CatRegion region(Offset point, Size display) {
    final pixel = Offset(
      point.dx / display.width * image.width,
      point.dy / display.height * image.height,
    );
    final p = Offset(
      (pixel.dx - bounds.left) / bounds.width,
      (pixel.dy - bounds.top) / bounds.height,
    );
    final head = switch (pose) {
      CatPose.sitting => const Rect.fromLTWH(.05, 0, .72, .48),
      CatPose.standing => const Rect.fromLTWH(0, 0, .68, .52),
      CatPose.sleeping => const Rect.fromLTWH(0, 0, .68, .65),
      CatPose.resting => const Rect.fromLTWH(0, .34, .63, .50),
    };
    if (head.contains(p)) return CatRegion.head;
    if (p.dx > .78 && pose != CatPose.sleeping) return CatRegion.tail;
    return CatRegion.body;
  }
}

/// Decodes once per mounted character, never per touch. Original PNGs are
/// untouched. The renderer isolates connected character pixels in memory,
/// so stray feet in an atlas gutter cannot leak through rectangular cropping.
class NamSpriteSet {
  final frames = <(CatPose, CatExpression), NamFrame>{};
  static Future<NamSpriteSet> load({CatType type = CatType.black}) async {
    final result = NamSpriteSet();
    try {
      for (final pose in CatPose.values) {
        final data = await rootBundle.load(NamFrames.asset(pose, type));
        final codec = await ui.instantiateImageCodec(
          data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
        );
        final source = (await codec.getNextFrame()).image;
        try {
          final bytes = (await source.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final rgba = bytes.buffer.asUint8List(
            bytes.offsetInBytes,
            bytes.lengthInBytes,
          );
          for (final expression in CatExpression.values) {
            if (expression == CatExpression.observing &&
                !NamFrames.supports(pose, expression, type)) {
              continue;
            }
            final frame = await _isolate(
              rgba,
              source.width,
              NamFrames.source(pose, expression, type),
              pose,
              type,
            );
            result.frames[(pose, expression)] = frame;
          }
          // Recovering cut pixels must not shrink the existing character.
          final (_, previousBounds, _, _, _) = await compute(_extract, (
            rgba,
            source.width,
            type == CatType.tuxedo && pose == CatPose.resting
                ? const Rect.fromLTWH(0, 950, 265, 265)
                : type == CatType.tuxedo && pose == CatPose.sitting
                ? const Rect.fromLTWH(10, 20, 265, 365)
                : NamFrames.source(pose, CatExpression.neutral, type),
            pose,
            type,
            false,
          ));
          final referenceSize = previousBounds.size;
          for (final expression in CatExpression.values) {
            final frame = result.frames[(pose, expression)];
            if (frame == null) continue;
            frame.referenceSize = referenceSize;
            frame.referenceHeight = referenceSize.height;
          }
        } finally {
          source.dispose();
          codec.dispose();
        }
      }
      return result;
    } catch (_) {
      result.dispose();
      rethrow;
    }
  }

  static Future<NamFrame> _isolate(
    Uint8List source,
    int stride,
    Rect roi,
    CatPose pose,
    CatType type,
  ) async {
    final (pixels, bounds, canvas, origin, region) = await compute(_extract, (
      source,
      stride,
      roi,
      pose,
      type,
      true,
    ));
    final buffer = await ui.ImmutableBuffer.fromUint8List(pixels);
    final descriptor = ui.ImageDescriptor.raw(
      buffer,
      width: canvas.width.toInt(),
      height: canvas.height.toInt(),
      pixelFormat: ui.PixelFormat.rgba8888,
    );
    final codec = await descriptor.instantiateCodec();
    try {
      return NamFrame(
        (await codec.getNextFrame()).image,
        pixels,
        bounds,
        pose,
        sourceOrigin: origin,
        sourceRegion: region,
      );
    } finally {
      codec.dispose();
      descriptor.dispose();
      buffer.dispose();
    }
  }

  static (Uint8List, Rect, Size, Offset, Rect) _extract(
    (Uint8List, int, Rect, CatPose, CatType, bool) args,
  ) {
    final (source, stride, selection, pose, type, isolateNeighbours) = args;
    final roi = isolateNeighbours
        ? NamFrames.searchRegion(
            selection,
            stride,
            source.length ~/ (stride * 4),
          )
        : selection;
    final w = roi.width.toInt(), h = roi.height.toInt();
    final labels = Int32List(w * h);
    var label = 0, biggest = 0, biggestCount = 0;
    final queue = Int32List(w * h);
    int offset(int i) =>
        ((roi.top.toInt() + i ~/ w) * stride + roi.left.toInt() + i % w) * 4;
    final background = Uint8List(w * h);
    // Two supplied atlases contain an opaque checkerboard. Remove only its
    // border-connected grey pixels in memory; enclosed white fur stays intact.
    if ((type == CatType.orange && pose == CatPose.sitting) ||
        (type == CatType.tuxedo && pose == CatPose.standing)) {
      bool grey(int i) {
        final p = offset(i);
        final r = source[p], g = source[p + 1], b = source[p + 2];
        final low = r < g ? (r < b ? r : b) : (g < b ? g : b);
        final high = r > g ? (r > b ? r : b) : (g > b ? g : b);
        return low >= 120 && high - low <= 24;
      }

      var front = 0, back = 0;
      void seed(int i) {
        if (background[i] == 0 && grey(i)) {
          background[i] = 1;
          queue[back++] = i;
        }
      }

      for (var x = 0; x < w; x++) {
        seed(x);
        seed((h - 1) * w + x);
      }
      for (var y = 0; y < h; y++) {
        seed(y * w);
        seed(y * w + w - 1);
      }
      while (front < back) {
        final i = queue[front++], x = i % w, y = i ~/ w;
        if (x > 0) seed(i - 1);
        if (x + 1 < w) seed(i + 1);
        if (y > 0) seed(i - w);
        if (y + 1 < h) seed(i + w);
      }
    }
    int sourceAlpha(int i) => background[i] == 1 ? 0 : source[offset(i) + 3];
    final owners = Uint8List(w * h);
    if (isolateNeighbours) {
      // Atlas characters can touch through thin whiskers/outline pixels.
      // Find solid body cores, then partition their original pixels before
      // selecting the character. No pixels are painted or resampled.
      const radius = 6;
      final horizontal = Uint8List(w * h);
      final cores = Uint8List(w * h);
      for (var y = 0; y < h; y++) {
        for (var x = radius; x < w - radius; x++) {
          var solid = true;
          for (var dx = -radius; dx <= radius; dx++) {
            if (sourceAlpha(y * w + x + dx) < 128) {
              solid = false;
              break;
            }
          }
          if (solid) horizontal[y * w + x] = 1;
        }
      }
      for (var y = radius; y < h - radius; y++) {
        for (var x = radius; x < w - radius; x++) {
          var solid = true;
          for (var dy = -radius; dy <= radius; dy++) {
            if (horizontal[(y + dy) * w + x] == 0) {
              solid = false;
              break;
            }
          }
          if (solid) cores[y * w + x] = 1;
        }
      }
      var front = 0, back = 0;
      final ownCore = selection.deflate(12);
      final ownEnvelope = selection.inflate(12);
      // Separate touching bodies using their solid interiors, not rectangular
      // cuts through their toes or tails. Original edge pixels are assigned
      // by distance along the foreground to these interior seeds.
      for (final foreign in [true, false]) {
        for (var i = 0; i < cores.length; i++) {
          if (cores[i] == 0) continue;
          final point = Offset(roi.left + i % w, roi.top + i ~/ w);
          final isForeign = !ownEnvelope.contains(point);
          if (foreign != isForeign ||
              (!isForeign && !ownCore.contains(point))) {
            continue;
          }
          owners[i] = isForeign ? 2 : 1;
          queue[back++] = i;
        }
      }
      while (front < back) {
        final at = queue[front++], x = at % w, y = at ~/ w;
        for (final next in [
          if (x > 0) at - 1,
          if (x + 1 < w) at + 1,
          if (y > 0) at - w,
          if (y + 1 < h) at + w,
        ]) {
          if (owners[next] == 0 && sourceAlpha(next) >= 32) {
            owners[next] = owners[at];
            queue[back++] = next;
          }
        }
      }
    }
    int alpha(int i) => owners[i] == 2 ? 0 : sourceAlpha(i);
    for (var start = 0; start < labels.length; start++) {
      if (labels[start] != 0 || alpha(start) < 32) continue;
      label++;
      var front = 0, back = 1;
      queue[0] = start;
      labels[start] = label;
      while (front < back) {
        final i = queue[front++], x = i % w, y = i ~/ w;
        for (final j in [
          if (x > 0) i - 1,
          if (x + 1 < w) i + 1,
          if (y > 0) i - w,
          if (y + 1 < h) i + w,
        ]) {
          if (labels[j] == 0 && alpha(j) >= 32) {
            labels[j] = label;
            queue[back++] = j;
          }
        }
      }
      if (back > biggestCount) {
        biggestCount = back;
        biggest = label;
      }
    }
    if (biggestCount < 10000) {
      throw StateError(
        '${NamFrames.name(type)} has no complete character: $pose $roi',
      );
    }
    var left = w, top = h, right = 0, bottom = 0;
    for (var i = 0; i < labels.length; i++) {
      if (labels[i] != biggest) continue;
      final x = i % w, y = i ~/ w;
      if (x < left) left = x;
      if (x > right) right = x;
      if (y < top) top = y;
      if (y > bottom) bottom = y;
    }
    final canvas = type == CatType.black
        ? NamFrames.canvas(pose)
        : Size((right - left + 17).toDouble(), (bottom - top + 17).toDouble());
    final cw = canvas.width.toInt(), ch = canvas.height.toInt();
    final pixels = Uint8List(cw * ch * 4);
    final dx = (cw - (right - left + 1)) ~/ 2 - left;
    final dy = ch - 8 - bottom - 1;
    // Keep the main component plus its one-pixel anti-aliased edge only.
    // Foreign components are never copied, even if they share the atlas ROI.
    for (var i = 0; i < labels.length; i++) {
      final x = i % w, y = i ~/ w;
      var keep = labels[i] == biggest;
      if (!keep && labels[i] == 0 && alpha(i) > 0) {
        for (var yy = y - 1; yy <= y + 1 && !keep; yy++) {
          for (var xx = x - 1; xx <= x + 1; xx++) {
            if (xx >= 0 &&
                xx < w &&
                yy >= 0 &&
                yy < h &&
                labels[yy * w + xx] == biggest) {
              keep = true;
              break;
            }
          }
        }
      }
      final tx = x + dx, ty = y + dy;
      if (!keep || tx < 0 || tx >= cw || ty < 0 || ty >= ch) continue;
      final from = ((roi.top.toInt() + y) * stride + roi.left.toInt() + x) * 4;
      pixels.setRange((ty * cw + tx) * 4, (ty * cw + tx) * 4 + 4, source, from);
    }
    return (
      pixels,
      Rect.fromLTWH(
        left + dx.toDouble(),
        top + dy.toDouble(),
        (right - left + 1).toDouble(),
        (bottom - top + 1).toDouble(),
      ),
      canvas,
      Offset(roi.left + left, roi.top + top),
      roi,
    );
  }

  void dispose() {
    for (final frame in frames.values) {
      frame.image.dispose();
    }
    frames.clear();
  }
}
