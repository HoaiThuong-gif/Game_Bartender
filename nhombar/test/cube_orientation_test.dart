import 'package:cuber/cuber.dart' as cuber;
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/controllers/cube_input_controller.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/services/cube_validation_service.dart';
import 'package:nhom_bar/games/rubik/services/cube_input_diagnostics.dart';

void main() {
  const validator = CubeValidationService();
  test('solved has exact URFDLB definition, isOk and isSolved', () {
    final definition = CubeState.solved().toFaceletDefinition();
    expect(
      definition,
      'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB',
    );
    expect(cuber.Cube.from(definition).isOk, isTrue);
    expect(cuber.Cube.from(definition).isSolved, isTrue);
  });

  test('all 18 moves and mixed sequences round trip through manual state', () {
    var mixed = cuber.Cube.solved;
    for (final move in cuber.Move.values) {
      mixed = mixed.move(move);
      for (final cube in [cuber.Cube.solved.move(move), mixed]) {
        final state = CubeState.fromFaceletDefinition(cube.definition);
        expect(state.toFaceletDefinition(), cube.definition);
        expect(validator.validate(state).isValid, isTrue);
      }
    }
  });

  test('independent manual R fixture matches cuber and rotated U fails', () {
    // Row-major grids as physically seen with the documented top centers.
    final rows = [
      'UUFUUFUUF',
      'RRRRRRRRR',
      'FFDFFDFFD',
      'DDBDDBDDB',
      'LLLLLLLLL',
      'UBBUBBUBB',
    ];
    final state = CubeState.fromFaceletDefinition(rows.join());
    expect(
      state.toFaceletDefinition(),
      cuber.Cube.solved.move(cuber.Move.right).definition,
    );
    expect(validator.validate(state).isValid, isTrue);
    final faces = {
      for (final face in RubikFace.values) face: state.stickers(face),
    };
    final up = state.stickers(RubikFace.up);
    faces[RubikFace.up] = [
      for (final i in [6, 3, 0, 7, 4, 1, 8, 5, 2]) up[i],
    ];
    expect(
      validator.validate(CubeState(faces)).problem,
      CubeInputProblem.impossible,
    );
  });

  test('separate incomplete, counts, centers and physically impossible', () {
    expect(
      validator.validate(CubeState.empty()).problem,
      CubeInputProblem.incomplete,
    );
    final solved = CubeState.solved();
    expect(
      validator
          .validate(solved.withSticker(RubikFace.up, 0, RubikColor.red))
          .problem,
      CubeInputProblem.colorCount,
    );
    final flipped = solved
        .withSticker(RubikFace.up, 7, RubikColor.green)
        .withSticker(RubikFace.front, 1, RubikColor.white);
    for (final color in RubikColor.values) {
      expect(flipped.count(color), 9);
    }
    expect(validator.validate(flipped).problem, CubeInputProblem.impossible);
    final centers = {
      for (final face in RubikFace.values)
        face: List<RubikColor?>.of(solved.stickers(face)),
    };
    centers[RubikFace.up]![4] = RubikColor.red;
    centers[RubikFace.right]![4] = RubikColor.white;
    expect(
      validator.validate(CubeState(centers)).problem,
      CubeInputProblem.center,
    );
  });

  test('controller caps each color at nine without destroying old sticker', () {
    final controller = CubeInputController();
    for (final i in [0, 1, 2, 3, 5, 6, 7, 8]) {
      controller.setSticker(RubikFace.up, i, RubikColor.white);
    }
    controller.setSticker(RubikFace.right, 0, RubikColor.white);
    expect(controller.state.stickers(RubikFace.right)[0], isNull);
    expect(controller.state.count(RubikColor.white), 9);
    expect(controller.error, isNotNull);
    controller.setSticker(RubikFace.up, 0, null);
    controller.setSticker(RubikFace.right, 0, RubikColor.white);
    expect(controller.state.stickers(RubikFace.right)[0], RubikColor.white);
    controller.dispose();
  });

  test('debug report includes arrays, definition, counts and cuber result', () {
    final lines = <String>[];
    final original = debugPrint;
    debugPrint = (String? message, {int? wrapWidth}) {
      lines.add(message ?? '');
    };
    addTearDown(() => debugPrint = original);
    logCubeInput(CubeState.solved());
    expect(lines.join('\n'), contains('definition (54): UUUUUUUUU'));
    expect(lines.join('\n'), contains('U (top=B): [white'));
    expect(lines.join('\n'), contains('U=9'));
    expect(lines.join('\n'), contains('isOk=true; isSolved=true'));
  });
}
