import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/screens/home/lobby_cats.dart';
import 'package:nhom_bar/screens/home/nam_cat_assets.dart';
import 'package:nhom_bar/screens/home/nam_cat_state_controller.dart';
import 'package:nhom_bar/screens/home/widgets/nam_cat_character.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  final allSprites = <CatType, NamSpriteSet>{};
  setUpAll(() async {
    for (final type in CatType.values) {
      allSprites[type] = await NamSpriteSet.load(type: type);
    }
  });
  tearDownAll(() {
    for (final set in allSprites.values) {
      set.dispose();
    }
  });

  test(
    'every visible pixel comes directly from its own authored pose PNG',
    () async {
      for (final type in CatType.values) {
        for (final pose in CatPose.values) {
          final data = await rootBundle.load(NamFrames.asset(pose, type));
          final codec = await ui.instantiateImageCodec(
            data.buffer.asUint8List(),
          );
          final image = (await codec.getNextFrame()).image;
          final raw = (await image.toByteData(
            format: ui.ImageByteFormat.rawRgba,
          ))!;
          final original = raw.buffer.asUint8List(
            raw.offsetInBytes,
            raw.lengthInBytes,
          );
          for (final expression in CatExpression.values) {
            if (expression == CatExpression.observing &&
                !NamFrames.supports(pose, expression, type)) {
              continue;
            }
            final frame = allSprites[type]!.frames[(pose, expression)]!;
            var changed = 0;
            for (var y = 0; y < frame.image.height; y++) {
              for (var x = 0; x < frame.image.width; x++) {
                final p = (y * frame.image.width + x) * 4;
                if (frame.pixels[p + 3] == 0) continue;
                final sx = (frame.sourceOrigin.dx + x - frame.bounds.left)
                    .toInt();
                final sy = (frame.sourceOrigin.dy + y - frame.bounds.top)
                    .toInt();
                final source = (sy * image.width + sx) * 4;
                for (var channel = 0; channel < 4; channel++) {
                  if (frame.pixels[p + channel] != original[source + channel]) {
                    changed++;
                  }
                }
              }
            }
            expect(
              changed,
              0,
              reason:
                  '$type $pose $expression must not paint or resample pixels',
            );
          }
          image.dispose();
          codec.dispose();
        }
      }
    },
  );

  test(
    'Cho pounce keeps the original outer rear paw in open and closed frames',
    () {
      for (final (expression, sourcePixel) in [
        (CatExpression.neutral, const Offset(267, 1178)),
        (CatExpression.content, const Offset(510, 1178)),
      ]) {
        final frame =
            allSprites[CatType.tuxedo]!.frames[(CatPose.resting, expression)]!;
        final local = sourcePixel - frame.sourceOrigin + frame.bounds.topLeft;
        expect(
          (Offset.zero &
                  Size(
                    frame.image.width.toDouble(),
                    frame.image.height.toDouble(),
                  ))
              .contains(local),
          isTrue,
        );
        final p = (local.dy.toInt() * frame.image.width + local.dx.toInt()) * 4;
        expect(frame.pixels[p + 3], greaterThan(200));
        expect(frame.pixels[p], greaterThan(160));
        expect(frame.pixels[p + 1], greaterThan(160));
        expect(frame.pixels[p + 2], greaterThan(160));
      }
    },
  );

  testWidgets('three idle clocks vary independently and stop when inactive', (
    tester,
  ) async {
    final states = [
      for (final type in CatType.values)
        CatStateController(
          type == CatType.tuxedo ? CatPose.resting : CatPose.sitting,
          random: Random(type.index + 10),
          hasFrame: (pose, expression) =>
              NamFrames.supports(pose, expression, type),
        ),
    ];
    final events = [<int>[], <int>[], <int>[]];
    var elapsed = 0;
    for (var i = 0; i < states.length; i++) {
      final index = i;
      states[i].addListener(() {
        if (states[index].expression != CatExpression.neutral) {
          events[index].add(elapsed);
        }
      });
    }
    for (elapsed = 0; elapsed < 30000; elapsed += 100) {
      await tester.pump(const Duration(milliseconds: 100));
    }
    for (final event in events) {
      expect(event.length, greaterThan(1));
    }
    expect(events.map((e) => e.first).toSet().length, 3);
    for (final state in states) {
      state.setActive(false);
    }
    final counts = events.map((e) => e.length).toList();
    await tester.pump(const Duration(minutes: 1));
    expect(events.map((e) => e.length).toList(), counts);
    for (final state in states) {
      state.dispose();
    }
    await tester.pump(const Duration(minutes: 1));
  });

  testWidgets(
    'sleep reactions survive repeated touches, long sleep and resume for all cats',
    (tester) async {
      for (final type in CatType.values) {
        final state = CatStateController(
          CatPose.sleeping,
          random: Random(type.index),
          hasFrame: (pose, expression) =>
              NamFrames.supports(pose, expression, type),
        );
        await tester.pump(const Duration(minutes: 1));
        for (var i = 0; i < 5; i++) {
          state.tap(CatRegion.values[i % 3]);
          await tester.pump(const Duration(milliseconds: 300));
          expect(state.pose, CatPose.sleeping);
          expect(state.expression, CatExpression.drowsy);
        }
        await tester.pump(const Duration(seconds: 2));
        expect(state.expression, CatExpression.neutral);
        expect(state.activity, CatActivity.sleep);
        state.tap(CatRegion.head);
        state.setActive(false);
        await tester.pump(const Duration(seconds: 4));
        state.setActive(true);
        expect(state.expression, CatExpression.neutral);
        state.dispose();
      }
    },
  );

  test('atlas crops have no long opaque cut along any source edge', () {
    final suspects = <String>[];
    for (final type in CatType.values) {
      for (final pose in CatPose.values) {
        for (final expression in CatExpression.values) {
          if (expression == CatExpression.observing &&
              !NamFrames.supports(pose, expression, type)) {
            continue;
          }
          final frame = allSprites[type]!.frames[(pose, expression)]!;
          final roi = frame.sourceRegion;
          bool opaque(int sx, int sy) {
            final x =
                sx - frame.sourceOrigin.dx.toInt() + frame.bounds.left.toInt();
            final y =
                sy - frame.sourceOrigin.dy.toInt() + frame.bounds.top.toInt();
            return x >= 0 &&
                x < frame.image.width &&
                y >= 0 &&
                y < frame.image.height &&
                frame.pixels[(y * frame.image.width + x) * 4 + 3] > 200;
          }

          final edges = <String, List<bool>>{
            'left': [
              for (var y = roi.top.toInt(); y < roi.bottom; y++)
                opaque(roi.left.toInt(), y),
            ],
            'right': [
              for (var y = roi.top.toInt(); y < roi.bottom; y++)
                opaque(roi.right.toInt() - 1, y),
            ],
            'top': [
              for (var x = roi.left.toInt(); x < roi.right; x++)
                opaque(x, roi.top.toInt()),
            ],
            'bottom': [
              for (var x = roi.left.toInt(); x < roi.right; x++)
                opaque(x, roi.bottom.toInt() - 1),
            ],
          };
          for (final edge in edges.entries) {
            var longest = 0, run = 0;
            for (final pixel in edge.value) {
              run = pixel ? run + 1 : 0;
              longest = max(longest, run);
            }
            if (longest > 5) {
              suspects.add('$type $pose $expression ${edge.key}: $longest px');
            }
          }
        }
      }
    }
    expect(suspects.isEmpty, isTrue, reason: suspects.join('\n'));
  });
  test('Cho sitting only selects the complete isolated authored figure', () {
    final neutral = allSprites[CatType.tuxedo]!
        .frames[(CatPose.sitting, CatExpression.neutral)]!;
    for (final expression in CatExpression.values) {
      if (expression == CatExpression.observing &&
          !NamFrames.supports(CatPose.sitting, expression, CatType.tuxedo)) {
        continue;
      }
      expect(
        NamFrames.supports(CatPose.sitting, expression, CatType.tuxedo),
        expression == CatExpression.neutral,
      );
      final frame =
          allSprites[CatType.tuxedo]!.frames[(CatPose.sitting, expression)]!;
      expect(frame.sourceOrigin, neutral.sourceOrigin);
      expect(frame.bounds, neutral.bounds);
    }
  });
  testWidgets(
    'Cho resting tap changes only expression and sleeping tap keeps native geometry',
    (tester) async {
      final resting = CatStateController(CatPose.resting);
      resting.tap(CatRegion.head);
      expect(resting.pose, CatPose.resting);
      await tester.pump(const Duration(milliseconds: 700));
      expect(resting.pose, CatPose.resting);
      expect(resting.expression, CatExpression.neutral);
      resting.dispose();
    },
  );

  test(
    'all three cats load four complete poses and four expression slots each',
    () {
      for (final type in CatType.values) {
        expect(
          allSprites[type]!.frames.length,
          16 +
              CatPose.values
                  .where(
                    (pose) =>
                        NamFrames.supports(pose, CatExpression.observing, type),
                  )
                  .length,
        );
        for (final pose in CatPose.values) {
          for (final expression in CatExpression.values) {
            if (expression == CatExpression.observing &&
                !NamFrames.supports(pose, expression, type)) {
              continue;
            }
            final frame = allSprites[type]!.frames[(pose, expression)]!;
            expect(frame.bounds.left, greaterThanOrEqualTo(0));
            expect(frame.bounds.right, lessThanOrEqualTo(frame.image.width));
            expect(frame.pixels[3], 0);
          }
        }
      }
      expect(
        NamFrames.asset(CatPose.sleeping, CatType.orange),
        endsWith('Cam/Cam_nam.png'),
      );
      expect(
        NamFrames.asset(CatPose.resting, CatType.tuxedo),
        endsWith('Cho/Cho_vo.png'),
      );
    },
  );

  test('scheduler protects all three busy characters', () {
    final population = CatPopulation(Random(11));
    for (final type in CatType.values) {
      population.characters[type]!.spawnIndex = type.index;
      population.setBusy(type, true);
    }
    for (var i = 0; i < 200; i++) {
      expect(population.planChange(), isNull);
    }
    population.dispose();
  });

  testWidgets(
    'sleep taps use authored wake sprite without changing pose, then return to sleep',
    (tester) async {
      final state = CatStateController(CatPose.sleeping);
      state.tap(CatRegion.head);
      expect(state.expression, CatExpression.drowsy);
      await tester.pump(const Duration(milliseconds: 2100));
      expect(state.expression, CatExpression.neutral);
      expect(state.pose, CatPose.sleeping);
      state.tap(CatRegion.body);
      state.tap(CatRegion.head);
      expect(state.pose, CatPose.sleeping);
      await tester.pump(const Duration(seconds: 2));
      expect(state.busy, isFalse);
      state.dispose();
    },
  );

  testWidgets(
    'petting recovers through drowsy and stale timers cannot override a new pose',
    (tester) async {
      final state = CatStateController(CatPose.sitting);
      state.startHeadStroke();
      expect(state.expression, CatExpression.drowsy);
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.expression, CatExpression.content);
      state.endHeadStroke();
      expect(state.expression, CatExpression.drowsy);
      state.startHeadStroke();
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.expression, CatExpression.content);
      state.setPose(CatPose.standing);
      state.startHeadStroke();
      await tester.pump(const Duration(milliseconds: 200));
      expect(state.expression, CatExpression.content);
      state.endHeadStroke();
      await tester.pump(const Duration(seconds: 3));
      expect(state.pose, CatPose.standing);
      expect(state.expression, CatExpression.neutral);
      state.tap(CatRegion.tail);
      expect(state.expression, CatExpression.annoyed);
      state.setPose(CatPose.resting);
      state.tap(CatRegion.head);
      await tester.pump(const Duration(milliseconds: 700));
      expect(state.pose, CatPose.resting);
      state.dispose();
    },
  );

  for (final type in CatType.values) {
    for (final pose in [CatPose.sitting, CatPose.standing, CatPose.resting]) {
      for (final characterSize in [120.0, 350.0]) {
        testWidgets(
          'head strokes preserve quality and placement for $type $pose at size $characterSize',
          (tester) async {
            final sprites = allSprites[type]!;
            await tester.pumpWidget(
              MaterialApp(
                home: Center(
                  child: SizedBox(
                    width: characterSize,
                    height: characterSize,
                    child: NamCatCharacter(
                      type: type,
                      pose: pose,
                      anchor: const Offset(.5, .9),
                      sprites: Future.value(sprites),
                    ),
                  ),
                ),
              ),
            );
            await tester.pump();
            final target = find.byKey(
              ValueKey('${NamFrames.name(type).toLowerCase()}-interaction'),
            );
            final rect = tester.getRect(target);
            final frame = sprites.frames[(pose, CatExpression.neutral)]!;
            Offset screen(double x, double y) =>
                rect.topLeft +
                Offset(
                  (frame.bounds.left + frame.bounds.width * x) /
                      frame.image.width *
                      rect.width,
                  (frame.bounds.top + frame.bounds.height * y) /
                      frame.image.height *
                      rect.height,
                );
            ui.Image image() => tester
                .widget<RawImage>(
                  find.descendant(of: target, matching: find.byType(RawImage)),
                )
                .image!;
            final head = screen(.36, pose == CatPose.resting ? .65 : .24);
            if (pose == CatPose.sitting) {
              await tester.tapAt(rect.topLeft + const Offset(1, 1));
              expect(image(), same(frame.image));
              await tester.tapAt(screen(.4, .72));
              await tester.pump();
              expect(
                image(),
                same(
                  sprites
                      .frames[(
                        pose,
                        NamFrames.supports(pose, CatExpression.drowsy, type)
                            ? CatExpression.drowsy
                            : CatExpression.neutral,
                      )]!
                      .image,
                ),
              );
              await tester.pump(const Duration(milliseconds: 700));
              final held = await tester.startGesture(head);
              await tester.pump(const Duration(milliseconds: 700));
              expect(image(), same(frame.image));
              await held.up();
              await tester.pump(const Duration(milliseconds: 300));
            }
            final stroke = await tester.createGesture();
            await stroke.down(head, timeStamp: Duration.zero);
            for (var i = 1; i <= 5; i++) {
              await stroke.moveTo(
                head + Offset(i.isOdd ? rect.width * .14 : 0, 0),
                timeStamp: Duration(milliseconds: i * 150),
              );
              await tester.pump(const Duration(milliseconds: 150));
            }
            expect(
              image(),
              same(
                sprites
                    .frames[(
                      pose,
                      NamFrames.supports(pose, CatExpression.content, type)
                          ? CatExpression.content
                          : NamFrames.supports(pose, CatExpression.drowsy, type)
                          ? CatExpression.drowsy
                          : CatExpression.neutral,
                    )]!
                    .image,
              ),
            );
            final content =
                sprites.frames[(
                  pose,
                  NamFrames.supports(pose, CatExpression.content, type)
                      ? CatExpression.content
                      : NamFrames.supports(pose, CatExpression.drowsy, type)
                      ? CatExpression.drowsy
                      : CatExpression.neutral,
                )]!;
            final contentRect = tester.getRect(target);
            final neutralScale = rect.width / frame.image.width;
            final contentScale = contentRect.width / content.image.width;
            expect(
              content.bounds.height * contentScale,
              closeTo(frame.bounds.height * neutralScale, .01),
            );
            final oldContact = rect.topLeft + frame.contactPoint * neutralScale;
            final newContact =
                contentRect.topLeft + content.contactPoint * contentScale;
            expect(newContact.dx, closeTo(oldContact.dx, .01));
            expect(newContact.dy, closeTo(oldContact.dy, .01));
            expect(
              find.descendant(of: target, matching: find.byType(Transform)),
              findsNothing,
            );
            await stroke.up();
            await tester.pump(const Duration(milliseconds: 400));
            expect(image(), same(frame.image));
            await tester.pumpWidget(const SizedBox());
          },
        );
      }
    }
  }
  test('preview does not mutate Orange/Tuxedo; busy Nam is protected from scheduler', () {
    final population = CatPopulation(Random(10));
    final others = {
      for (final type in [CatType.orange, CatType.tuxedo])
        type: (
          population.characters[type]!.spawnIndex,
          population.characters[type]!.pose,
        ),
    };
    for (final pose in CatPose.values) {
      population.previewNam(pose);
      expect(population.characters[CatType.black]!.pose, pose);
      for (final type in others.keys) {
        expect((
          population.characters[type]!.spawnIndex,
          population.characters[type]!.pose,
        ), others[type]);
      }
    }
    population.namBusy = true;
    for (var i = 0; i < 100; i++) {
      final change = population.planChange();
      expect(change?.involves(CatType.black) ?? false, isFalse);
    }
    population.dispose();
  });
}
