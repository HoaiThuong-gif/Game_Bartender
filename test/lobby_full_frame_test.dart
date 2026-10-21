import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nhom_bar/screens/home/lobby_layout.dart';

import '../tool/lobby_sprite_frames.dart' as extraction;

Map<String, dynamic> manifest() => jsonDecode(
  File('assets/images/lobby/frames/manifest.json').readAsStringSync(),
) as Map<String, dynamic>;
void main() {
  test('complete frames preserve original pixels and contain the whole authored object', () {
    final data = manifest();
    for (final name in ['flag', 'bartender', 'rubik', 'games', 'tv']) {
      final spec = data[name] as Map, frames = spec['frames'] as List;
      expect(
        frames.length,
        {'flag': 12, 'bartender': 12, 'rubik': 1, 'games': 3, 'tv': 4}[name],
      );
      final source = img
          .decodePng(File('assets/images/lobby/$name.png').readAsBytesSync())!
          .convert(numChannels: 4);
      expect(
        spec['sourceFingerprint'],
        extraction.fingerprint(
          File('assets/images/lobby/$name.png').readAsBytesSync(),
        ),
        reason:
            'Run dart run tool/prepare_lobby_sprites.dart after replacing $name.png',
      );
      if (name == 'rubik') extraction.removeRubikBackground(source);
      final sourceObjects = name == 'bartender'
          ? null
          : extraction.components(source, threshold: 40);
      final primaryCounts =
          sourceObjects?.objects
              .where((o) => o.count > 500)
              .map((o) => o.count)
              .toList() ??
          [];
      final exportedPrimary = <int>[];
      for (var index = 0; index < frames.length; index++) {
        final meta = frames[index] as Map,
            r = meta['sourceRect'] as List,
            offset = meta['offset'] as List;
        final image = img.decodePng(
          File('assets/images/lobby/frames/${name}_$index.png')
              .readAsBytesSync(),
        )!;
        expect([image.width, image.height], spec['canvas']);
        final bounds = extraction.alphaBounds(image);
        expect(bounds.x, greaterThan(0));
        expect(bounds.y, greaterThan(0));
        expect(bounds.x + bounds.width, lessThan(image.width));
        expect(bounds.y + bounds.height, lessThan(image.height));
        if (name == 'flag') {
          // Both endpoints of the complete pole are registered, not composited.
          final tip = extraction.poleTip(
            image,
            extraction.alphaBounds(image, threshold: 40),
          );
          final expected = meta['poleTip'] as List;
          expect(tip.x, closeTo(expected[0] as num, 1.5));
          expect(tip.y, closeTo(expected[1] as num, 1.5));
        } else if (name == 'rubik') {
          final scale = (meta['registration'] as List)[0] as num,
              anchor = meta['sourceAnchor'] as List;
          final crop = img.copyCrop(
            source,
            x: r[0] as int,
            y: r[1] as int,
            width: r[2] as int,
            height: r[3] as int,
          );
          var mismatch = 0;
          for (final p in image) {
            if (p.a == 0) continue;
            final original = crop.getPixelInterpolate(
              (anchor[0] as num) + (p.x - 168) / scale,
              (anchor[1] as num) + (p.y - 168) / scale,
              interpolation: img.Interpolation.linear,
            );
            if ((p.r - original.r).abs() > 1 ||
                (p.g - original.g).abs() > 1 ||
                (p.b - original.b).abs() > 1 ||
                // Exporter removes disconnected alpha fringe around the cube.
                (p.a > 40 && (p.a - original.a).abs() > 1)) {
              mismatch++;
            }
          }
          expect(
            mismatch,
            0,
            reason:
                'Rubik uses the complete original view with uniform scaling',
          );
        } else {
          var mismatch = 0, primary = 0;
          for (final p in image) {
            if (p.a == 0) continue;
            final x = (r[0] as int) + p.x - (offset[0] as int),
                y = (r[1] as int) + p.y - (offset[1] as int);
            final original = source.getPixel(x, y);
            if (p.r != original.r ||
                p.g != original.g ||
                p.b != original.b ||
                p.a != original.a) {
              mismatch++;
            }
            if (p.a > 40) primary++;
          }
          expect(
            mismatch,
            0,
            reason: '$name/$index must use its own full drawing',
          );
          if (name == 'bartender') {
            var expected = 0;
            for (var y = r[1] as int; y < (r[1] as int) + (r[3] as int); y++) {
              for (
                var x = r[0] as int;
                x < (r[0] as int) + (r[2] as int);
                x++
              ) {
                if (source.getPixel(x, y).a > 40) expected++;
              }
            }
            expect(
              primary,
              expected,
              reason: 'Roof, menu, both stools and both plants must survive',
            );
          } else {
            expect(primary, meta['primaryPixelCount']);
          }
        }
        if (name != 'bartender') {
          exportedPrimary.add(meta['primaryPixelCount'] as int);
        }
      }
      if (name != 'bartender' && name != 'flag') {
        primaryCounts.sort();
        exportedPrimary.sort();
        expect(exportedPrimary, primaryCounts);
      }
    }
  });
  test(
    'full frames fit phone/tablet viewports and the stall cannot cover the TV',
    () {
      final data = manifest();
      for (final viewport in [
        const Size(390, 844),
        const Size(412, 915),
        const Size(360, 800),
        const Size(900, 1440),
      ]) {
        final scene = LobbyLayout.viewportRect(viewport);
        for (final entry in {
          'bartender': LobbyLayout.bartender,
          'flag': LobbyLayout.flag,
        }.entries) {
          final placed = LobbyLayout.fitObject(entry.value, viewport);
          for (final f in data[entry.key]['frames'] as List) {
            final b = f['fullBounds'] as List;
            final actual = Rect.fromLTWH(
              placed.imageRect.left + (b[0] as num) * placed.imageScale,
              placed.imageRect.top + (b[1] as num) * placed.imageScale,
              (b[2] as num) * placed.imageScale,
              (b[3] as num) * placed.imageScale,
            );
            expect(
              scene.inflate(.01).contains(actual.topLeft),
              true,
              reason: '${entry.key} $viewport',
            );
            expect(
              scene.inflate(.01).contains(actual.bottomRight),
              true,
              reason: '${entry.key} $viewport',
            );
            if (entry.key == 'bartender') {
              expect(
                actual.top,
                greaterThan(LobbyLayout.tv.visualRect.bottom + 4),
              );
            }
          }
        }
      }
    },
  );
}
