import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:image/image.dart' as img;
import 'package:nhom_bar/games/rubik/controllers/cube_input_controller.dart';
import 'package:nhom_bar/games/rubik/controllers/rubik_scan_controller.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/screens/rubik_scan_screen.dart';
import 'package:nhom_bar/games/rubik/services/cube_move_service.dart';
import 'package:nhom_bar/games/rubik/services/cube_validation_service.dart';
import 'package:nhom_bar/games/rubik/services/rubik_camera_service.dart';
import 'package:nhom_bar/games/rubik/services/rubik_color_detector.dart';
import 'package:nhom_bar/games/rubik/models/rubik_move.dart';

const rgb = <RubikColor, (int, int, int)>{
  RubikColor.white: (230, 232, 228),
  RubikColor.red: (210, 25, 35),
  RubikColor.orange: (235, 110, 15),
  RubikColor.yellow: (235, 220, 30),
  RubikColor.green: (30, 160, 65),
  RubikColor.blue: (30, 65, 210),
};

Uint8List photo(
  List<RubikColor?> colors, {
  bool noise = false,
  int orientation = 1,
}) {
  final image = img.Image(width: 480, height: 640);
  final side = (480 * scanFrameFraction).floor();
  final left = (480 - side) ~/ 2, top = (640 - side) ~/ 2;
  for (var y = 0; y < side; y++) {
    for (var x = 0; x < side; x++) {
      final index = (y * 3 ~/ side) * 3 + x * 3 ~/ side;
      final value = rgb[colors[index]] ?? (8, 8, 8);
      final highlight = noise && (x + y * 7) % 9 == 0;
      image.setPixelRgb(
        left + x,
        top + y,
        highlight ? 255 : value.$1,
        highlight ? 255 : value.$2,
        highlight ? 255 : value.$3,
      );
    }
  }
  // Store pixels rotated 90 degrees CCW and EXIF orientation 6 to restore them.
  final stored = orientation == 6 ? img.copyRotate(image, angle: -90) : image;
  stored.exif.imageIfd.orientation = orientation;
  return Uint8List.fromList(img.encodeJpg(stored, quality: 95));
}

class FakeCamera implements ScanCamera {
  FakeCamera(this.photos, {this.denied = false});
  final List<Uint8List> photos;
  bool denied;
  int opens = 0, closes = 0;
  @override
  CameraController? get controller => null;
  @override
  double get previewAspect => .75;
  @override
  Future<void> open() async {
    opens++;
    if (denied) throw CameraException('CameraAccessDenied', 'Denied');
  }

  @override
  Future<void> close() async {
    closes++;
  }

  @override
  Future<Uint8List> capture() async => photos.removeAt(0);
}

class SynchronousDetector extends RubikColorDetector {
  const SynchronousDetector();
  @override
  Future<DetectedRubikFace> detect(Uint8List bytes, double aspect) async =>
      RubikColorDetector.detectStill(bytes, aspect);
}

Widget preview(BuildContext context, CubeState state) =>
    const SizedBox.expand();

void main() {
  test(
    'samples row-major regions, tolerates sparse glare and normalizes EXIF',
    () {
      final colors = [
        RubikColor.red,
        RubikColor.orange,
        RubikColor.blue,
        RubikColor.white,
        RubikColor.green,
        RubikColor.yellow,
        RubikColor.blue,
        RubikColor.red,
        RubikColor.white,
      ];
      for (final orientation in [1, 6]) {
        final result = RubikColorDetector.detectStill(
          photo(colors, noise: true, orientation: orientation),
          .75,
        );
        expect(result.colors, colors);
        expect(result.thumbnail, isNotEmpty);
      }
    },
  );

  test(
    'dark and unsupported colors are not silently forced into valid colors',
    () {
      expect(RubikColorDetector.classifyRgb(4, 5, 6), isNull);
      expect(RubikColorDetector.classifyRgb(200, 10, 210), isNull);
      final result = RubikColorDetector.detectStill(
        photo(List.filled(9, null)),
        .75,
      );
      expect(result.colors, everyElement(isNull));
      expect(result.uncertain, hasLength(9));
      expect(
        () => RubikColorDetector.detectStill(Uint8List(4), .75),
        throwsFormatException,
      );
    },
  );

  test('scan state rejects missing and wrong centers; permits correction and validation', () {
    final scan = RubikScanController();
    expect(
      () => scan.confirm(RubikFace.up, List.filled(9, null)),
      throwsArgumentError,
    );
    expect(
      () => scan.confirm(RubikFace.up, List.filled(9, RubikColor.red)),
      throwsArgumentError,
    );
    for (final face in CubeState.definitionOrder) {
      scan.confirm(face, CubeState.solved().stickers(face));
    }
    expect(const CubeValidationService().validate(scan.state).isValid, isTrue);
    final badFace = List<RubikColor?>.of(scan.state.stickers(RubikFace.up));
    badFace[0] = RubikColor.red;
    scan.confirm(RubikFace.up, badFace);
    expect(
      const CubeValidationService().validate(scan.state).problem,
      CubeInputProblem.colorCount,
    );
    scan.confirm(RubikFace.up, CubeState.solved().stickers(RubikFace.up));
    expect(
      scan.state.toFaceletDefinition(),
      CubeState.solved().toFaceletDefinition(),
    );
  });

  test(
    'six detected faces enter shared validation and existing solver',
    () async {
      const moveService = CubeMoveService();
      final scrambled = moveService.apply(
        CubeState.solved(),
        RubikMove.parse('R'),
      );
      final scan = RubikScanController();
      for (final face in CubeState.definitionOrder) {
        final detected = RubikColorDetector.detectStill(
          photo(scrambled.stickers(face)),
          .75,
        );
        scan.confirm(face, detected.colors);
      }
      expect(scan.state.toFaceletDefinition(), scrambled.toFaceletDefinition());
      final input = CubeInputController()..load(scan.state);
      final moves = await input.solve();
      expect(moves, isNotNull);
      var state = scan.state;
      for (final move in moves!) {
        state = moveService.apply(state, move);
      }
      expect(
        state.toFaceletDefinition(),
        CubeState.solved().toFaceletDefinition(),
      );
      input.dispose();
    },
  );

  testWidgets('camera denial can retry; background closes and resume reopens', (
    tester,
  ) async {
    final camera = FakeCamera([], denied: true);
    await tester.pumpWidget(MaterialApp(home: RubikScanScreen(camera: camera)));
    await tester.pumpAndSettle();
    expect(find.textContaining('Chưa có quyền camera'), findsOneWidget);
    camera.denied = false;
    await tester.ensureVisible(find.text('Thử lại'));
    await tester.tap(find.text('Thử lại'));
    await tester.pumpAndSettle();
    expect(
      tester
          .widget<FilledButton>(find.widgetWithText(FilledButton, 'Chụp mặt U'))
          .onPressed,
      isNotNull,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    await tester.pump();
    expect(camera.closes, greaterThan(0));
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(camera.opens, 3);
    await tester.pumpWidget(const SizedBox());
    await tester.pump();
    expect(camera.closes, greaterThan(1));
  });

  testWidgets(
    'capture, retake, correct a cell, confirm six faces and reuse guide',
    (tester) async {
      tester.view.physicalSize = const Size(360, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);
      final wrong = List<RubikColor?>.filled(9, RubikColor.white)
        ..[0] = RubikColor.red;
      final camera = FakeCamera([
        photo(List.filled(9, RubikColor.white)),
        photo(wrong),
        for (final face in CubeState.definitionOrder.skip(1))
          photo(CubeState.solved().stickers(face)),
      ]);
      await tester.pumpWidget(
        MaterialApp(
          home: RubikScanScreen(
            camera: camera,
            detector: const SynchronousDetector(),
            previewBuilder: preview,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chụp mặt U'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Chụp lại'));
      await tester.pumpAndSettle();
      for (final face in CubeState.definitionOrder) {
        await tester.tap(find.text('Chụp mặt ${face.code}'));
        await tester.pumpAndSettle();
        if (face == RubikFace.up) {
          await tester.ensureVisible(
            find.byKey(const ValueKey('scan-sticker-0')),
          );
          await tester.tap(find.byKey(const ValueKey('scan-sticker-0')));
          await tester.pumpAndSettle();
          await tester.tap(find.text('Trắng'));
          await tester.pumpAndSettle();
        }
        await tester.tap(find.text('Xác nhận mặt'));
        await tester.pumpAndSettle();
      }
      expect(find.text('Đã xác nhận 6/6 mặt'), findsOneWidget);
      await tester.runAsync(() async {
        await tester.tap(find.text('Kiểm tra & Giải'));
        await Future<void>.delayed(const Duration(milliseconds: 400));
      });
      await tester.pumpAndSettle();
      expect(find.text('HƯỚNG DẪN GIẢI'), findsOneWidget);
      expect(find.text('Rubik đã được giải!'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}
