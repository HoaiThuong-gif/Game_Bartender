import 'dart:convert';
import 'dart:io';
import 'dart:math' as math;
import 'dart:typed_data';

import 'package:image/image.dart' as img;

typedef Bounds = ({int x, int y, int width, int height});

String fingerprint(List<int> bytes) {
  var hash = 0x811c9dc5;
  for (final byte in bytes) {
    hash = ((hash ^ byte) * 0x01000193) & 0xffffffff;
  }
  return '${bytes.length}-${hash.toRadixString(16)}';
}

({double x, double y}) poleTip(img.Image image, Bounds body) {
  var x = 0.0, y = 0.0, weight = 0.0;
  for (final p in image) {
    if (p.y > body.y + 32 ||
        p.a < 80 ||
        p.r < 140 ||
        p.g < 80 ||
        p.b > 140 ||
        p.r < p.g * 1.12) {
      continue;
    }
    final w = p.a / 255;
    x += p.x * w;
    y += p.y * w;
    weight += w;
  }
  if (weight == 0) throw StateError('Missing flag finial');
  return (x: x / weight, y: y / weight);
}

Bounds alphaBounds(img.Image image, {int threshold = 0}) {
  var left = image.width, top = image.height, right = -1, bottom = -1;
  for (final p in image) {
    if (p.a <= threshold) continue;
    left = math.min(left, p.x);
    top = math.min(top, p.y);
    right = math.max(right, p.x);
    bottom = math.max(bottom, p.y);
  }
  if (right < left) throw StateError('Empty sprite');
  return (x: left, y: top, width: right - left + 1, height: bottom - top + 1);
}

// Clear only the nearly-black background reachable from the sheet border.
// Enclosed dark outlines and all RGB values of the authored cube remain intact.
void removeRubikBackground(img.Image image) {
  final visited = Uint8List(image.width * image.height), queue = <int>[];
  void add(int index) {
    if (visited[index] != 0) return;
    visited[index] = 1;
    final p = image.getPixel(index % image.width, index ~/ image.width);
    if (p.r < 24 && p.g < 24 && p.b < 24) queue.add(index);
  }

  for (var x = 0; x < image.width; x++) {
    add(x);
    add((image.height - 1) * image.width + x);
  }
  for (var y = 0; y < image.height; y++) {
    add(y * image.width);
    add(y * image.width + image.width - 1);
  }
  for (var i = 0; i < queue.length; i++) {
    final at = queue[i], x = at % image.width, y = at ~/ image.width;
    image.getPixel(x, y).a = 0;
    if (x > 0) add(at - 1);
    if (x + 1 < image.width) add(at + 1);
    if (y > 0) add(at - image.width);
    if (y + 1 < image.height) add(at + image.width);
  }
}

({Int32List labels, List<({Bounds bounds, int count, int label})> objects})
components(img.Image image, {int threshold = 0}) {
  final labels = Int32List(image.width * image.height)
    ..fillRange(0, image.width * image.height, -1);
  final result = <({Bounds bounds, int count, int label})>[];
  final queue = <int>[];
  for (var start = 0; start < labels.length; start++) {
    if (labels[start] >= 0 ||
        image.getPixel(start % image.width, start ~/ image.width).a <=
            threshold) {
      continue;
    }
    final label = result.length;
    queue.clear();
    queue.add(start);
    labels[start] = label;
    var left = image.width, top = image.height, right = 0, bottom = 0;
    for (var i = 0; i < queue.length; i++) {
      final at = queue[i], x = at % image.width, y = at ~/ image.width;
      left = math.min(left, x);
      top = math.min(top, y);
      right = math.max(right, x);
      bottom = math.max(bottom, y);
      for (final n in [
        if (x > 0) at - 1,
        if (x + 1 < image.width) at + 1,
        if (y > 0) at - image.width,
        if (y + 1 < image.height) at + image.width,
      ]) {
        if (labels[n] < 0 &&
            image.getPixel(n % image.width, n ~/ image.width).a > threshold) {
          labels[n] = label;
          queue.add(n);
        }
      }
    }
    result.add((
      bounds: (
        x: left,
        y: top,
        width: right - left + 1,
        height: bottom - top + 1,
      ),
      count: queue.length,
      label: label,
    ));
  }
  return (labels: labels, objects: result);
}

void main() {
  final output = Directory('assets/images/lobby/frames')
    ..createSync(recursive: true);
  final manifest = <String, Object>{};
  final generated = <String>{};
  for (final spec in [
    ('bartender', 4, 3, 400, 480, 200, 350),
    ('games', 3, 1, 500, 620, 250, 600),
    ('tv', 2, 2, 620, 620, 310, 600),
    ('rubik', 1, 1, 336, 336, 168, 168),
    ('flag', 4, 3, 600, 480, 80, 398.5),
  ]) {
    final name = spec.$1;
    final sourceBytes = File('assets/images/lobby/$name.png').readAsBytesSync();
    final sheet = img.decodePng(sourceBytes)!.convert(numChannels: 4);
    if (name == 'rubik') removeRubikBackground(sheet);
    final regions = <({Bounds bounds, int? label})>[];
    final parts = name == 'bartender' ? null : components(sheet, threshold: 40);
    if (name == 'bartender') {
      // The drawn rows start at 22, 342 and 670; equal-height cuts would
      // cut the next roof into the preceding frame. Keep complete grid cells.
      const rows = [0, 333, 657, 1086];
      for (var i = 0; i < 12; i++) {
        regions.add((
          bounds: (
            x: i % 4 * 362,
            y: rows[i ~/ 4],
            width: 362,
            height: rows[i ~/ 4 + 1] - rows[i ~/ 4],
          ),
          label: null,
        ));
      }
    } else {
      var objects = parts!.objects.where((o) => o.count > 500).toList();
      if (name == 'flag') {
        // In the current sheet a second-column flag touches the third wall mount.
        // Separate that shared component along the gap beside the third pole.
        for (final object in objects.toList()) {
          if (object.bounds.width < sheet.width / spec.$2 * 1.5) continue;
          final extraLabel = parts.objects.length;
          final split = <({Bounds bounds, int count, int label})>[];
          for (final side in [0, 1]) {
            var left = sheet.width,
                top = sheet.height,
                right = -1,
                bottom = -1,
                count = 0;
            final label = side == 0 ? object.label : extraLabel;
            for (
              var y = object.bounds.y;
              y < object.bounds.y + object.bounds.height;
              y++
            ) {
              for (
                var x = object.bounds.x;
                x < object.bounds.x + object.bounds.width;
                x++
              ) {
                final at = y * sheet.width + x;
                if (parts.labels[at] != object.label ||
                    (x <
                                math.max(
                                  773,
                                  990 - .8 * (y % (sheet.height ~/ spec.$3)),
                                )
                            ? 0
                            : 1) !=
                        side) {
                  continue;
                }
                parts.labels[at] = label;
                left = math.min(left, x);
                top = math.min(top, y);
                right = math.max(right, x);
                bottom = math.max(bottom, y);
                count++;
              }
            }
            if (count == 0) {
              throw StateError('Missing flag after pole separation');
            }
            split.add((
              bounds: (
                x: left,
                y: top,
                width: right - left + 1,
                height: bottom - top + 1,
              ),
              count: count,
              label: label,
            ));
          }
          objects.remove(object);
          objects.addAll(split);
          parts.objects[object.label] = split.first;
          parts.objects.add(split.last);
        }
      }
      if (objects.length != spec.$2 * spec.$3) {
        throw StateError('$name: found ${objects.length} complete objects');
      }
      int cell(Bounds b) =>
          ((b.y + b.height / 2) / sheet.height * spec.$3).floor() * spec.$2 +
          ((b.x + b.width / 2) / sheet.width * spec.$2).floor();
      objects.sort((a, b) => cell(a.bounds).compareTo(cell(b.bounds)));
      for (final object in objects) {
        final b = object.bounds;
        final left = math.max(0, b.x - 4), top = math.max(0, b.y - 4);
        regions.add((
          bounds: (
            x: left,
            y: top,
            width: math.min(sheet.width, b.x + b.width + 4) - left,
            height: math.min(sheet.height, b.y + b.height + 4) - top,
          ),
          label: object.label,
        ));
      }
    }
    final frames = <Map<String, Object>>[];
    ({double x, double y})? referencePole;
    for (var i = 0; i < regions.length; i++) {
      final region = regions[i], r = region.bounds;
      final crop = img.copyCrop(
        sheet,
        x: r.x,
        y: r.y,
        width: r.width,
        height: r.height,
      );
      if (region.label != null) {
        // Isolate the complete connected object, never splice frame zero into it.
        for (final p in crop) {
          if (p.a == 0) continue;
          final x = r.x + p.x,
              y = r.y + p.y,
              label = parts!.labels[y * sheet.width + x];
          if (name == 'flag') {
            var otherMount = false;
            for (final other in parts.objects.where(
              (o) => o.count > 500 && o.label != region.label,
            )) {
              final b = other.bounds;
              if (x < b.x - 4 || x > b.x + 28 || y < b.y + b.height * .45) {
                continue;
              }
              var top = sheet.height, bottom = 0;
              for (var yy = b.y; yy < b.y + b.height; yy++) {
                for (var xx = b.x; xx < b.x + 12; xx++) {
                  if (parts.labels[yy * sheet.width + xx] == other.label) {
                    top = math.min(top, yy);
                    bottom = math.max(bottom, yy);
                  }
                }
              }
              if (y >= top - 4 && y <= bottom + 4) {
                otherMount = true;
                break;
              }
            }
            if (otherMount) {
              p.a = 0;
              continue;
            }
          }
          if (label == region.label) continue;
          if (label >= 0) {
            p.a = 0;
            continue;
          }
          var fringe = false;
          for (
            var yy = math.max(0, y - 4);
            yy <= math.min(sheet.height - 1, y + 4) && !fringe;
            yy++
          ) {
            for (
              var xx = math.max(0, x - 4);
              xx <= math.min(sheet.width - 1, x + 4);
              xx++
            ) {
              if (parts.labels[yy * sheet.width + xx] == region.label) {
                fringe = true;
                break;
              }
            }
          }
          if (!fringe) p.a = 0;
        }
      }
      final body = alphaBounds(crop, threshold: 40);
      var ownPrimary = 0;
      for (final p in crop) {
        if (p.a > 40) ownPrimary++;
      }
      double ax = body.x + body.width / 2, ay = body.y + body.height.toDouble();
      if (name == 'flag') {
        var top = crop.height, bottom = 0;
        for (final p in crop) {
          if (p.a > 40 && p.x < body.x + 12) {
            top = math.min(top, p.y);
            bottom = math.max(bottom, p.y);
          }
        }
        ax = body.x + 12;
        ay = bottom.toDouble();
      } else if (name == 'rubik') {
        ax = body.x + body.width / 2;
        ay = body.y + body.height / 2;
      }
      final dx = (spec.$6 - ax).round(), dy = (spec.$7 - ay).round();
      final bounds = alphaBounds(crop);
      if (name != 'flag' &&
          name != 'rubik' &&
          (bounds.x + dx < 0 ||
              bounds.y + dy < 0 ||
              bounds.x + bounds.width + dx > spec.$4 ||
              bounds.y + bounds.height + dy > spec.$5)) {
        throw StateError('$name/$i would clip an authored part');
      }
      final frame = img.Image(width: spec.$4, height: spec.$5, numChannels: 4);
      var scale = 1.0, angle = 0.0;
      if (name == 'flag' || name == 'rubik') {
        if (name == 'flag') {
          final tip = poleTip(crop, body), vx = tip.x - ax, vy = tip.y - ay;
          referencePole ??= (x: vx, y: vy);
          scale = math.sqrt(
            (referencePole.x * referencePole.x +
                    referencePole.y * referencePole.y) /
                (vx * vx + vy * vy),
          );
          angle =
              math.atan2(referencePole.y, referencePole.x) - math.atan2(vy, vx);
        } else {
          scale = 293 / body.height;
        }
        final c = math.cos(angle), s = math.sin(angle);
        // Register the complete authored frame at both ends of the pole.
        // No pole/cloth patches from another frame are used.
        for (final point in [
          (bounds.x, bounds.y),
          (bounds.x + bounds.width, bounds.y),
          (bounds.x, bounds.y + bounds.height),
          (bounds.x + bounds.width, bounds.y + bounds.height),
        ]) {
          final x =
              spec.$6 + scale * ((point.$1 - ax) * c - (point.$2 - ay) * s);
          final y =
              spec.$7 + scale * ((point.$1 - ax) * s + (point.$2 - ay) * c);
          if (x < 1 || y < 1 || x > frame.width - 2 || y > frame.height - 2) {
            throw StateError(
              '$name/$i would clip after registration at ($x, $y)',
            );
          }
        }
        for (final p in frame) {
          final x = p.x - spec.$6, y = p.y - spec.$7;
          final sx = ax + (x * c + y * s) / scale,
              sy = ay + (-x * s + y * c) / scale;
          if (sx >= 0 && sy >= 0 && sx < crop.width && sy < crop.height) {
            p.set(
              crop.getPixelInterpolate(
                sx,
                sy,
                interpolation: img.Interpolation.linear,
              ),
            );
          }
        }
      } else {
        img.compositeImage(
          frame,
          crop,
          dstX: dx,
          dstY: dy,
          blend: img.BlendMode.direct,
        );
      }
      var pixels = 0;
      for (final p in frame) {
        if (p.a > 0) {
          pixels++;
        } else {
          p.setRgba(0, 0, 0, 0);
        }
      }
      final content = alphaBounds(frame, threshold: 40);
      final full = alphaBounds(frame);
      final info = <String, Object>{
        'sourceRect': [r.x, r.y, r.width, r.height],
        'offset': [dx, dy],
        'sourceAnchor': [ax, ay],
        'contentBounds': [content.x, content.y, content.width, content.height],
        'fullBounds': [full.x, full.y, full.width, full.height],
        'pixelCount': pixels,
        if (region.label != null) 'primaryPixelCount': ownPrimary,
        if (name == 'flag' || name == 'rubik') 'registration': [scale, angle],
        if (name == 'flag')
          'poleTip': [spec.$6 + referencePole!.x, spec.$7 + referencePole.y],
      };
      frames.add(info);
      final png = img.encodePng(frame);
      File('${output.path}/${name}_$i.png').writeAsBytesSync(png);
      generated.add('${name}_$i.png');
    }
    manifest[name] = {
      'sourceFingerprint': fingerprint(sourceBytes),
      'sheetSize': [sheet.width, sheet.height],
      'grid': [spec.$2, spec.$3],
      'canvas': [spec.$4, spec.$5],
      'anchor': [spec.$6, spec.$7],
      'frames': frames,
    };
    stdout.writeln(
      '$name: ${frames.length} complete frames, canvas ${spec.$4}x${spec.$5}, first=${frames.first}',
    );
  }
  File('${output.path}/manifest.json')
      .writeAsStringSync(const JsonEncoder.withIndent('  ').convert(manifest));
  // Remove only superseded generated frames, never the authored source sheets.
  for (final file in output.listSync().whereType<File>()) {
    final name = file.uri.pathSegments.last;
    if (RegExp(r'^(flag|bartender|games|tv|rubik)_\d+\.png$').hasMatch(name) &&
        !generated.contains(name)) {
      file.deleteSync();
    }
  }
}
