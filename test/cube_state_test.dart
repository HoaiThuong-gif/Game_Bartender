import 'dart:async';

import 'package:cuber/cuber.dart' as cuber;

import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/controllers/cube_input_controller.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/models/rubik_move.dart';
import 'package:nhom_bar/games/rubik/services/cube_validation_service.dart';
import 'package:nhom_bar/games/rubik/services/cube_input_diagnostics.dart';
import 'package:nhom_bar/games/rubik/services/rubik_solver_service.dart';

class RecordingSolver implements CubeSolver {
  int calls = 0;
  final completion = Completer<List<RubikMove>>();
  @override
  Future<List<RubikMove>> solve(CubeState state) {
    calls++;
    return completion.future;
  }
}

void main() {
  const validator = CubeValidationService();

  test('adapter solves a real turn using the shared orientation', () async {
    final scrambled = cuber.Cube.solved.move(cuber.Move.right);
    final definition = scrambled.definition;
    final state = CubeState({
      for (var f = 0; f < 6; f++)
        RubikFace.values[f]: List.generate(
          9,
          (i) => RubikFace.values
              .firstWhere((face) => face.code == definition[f * 9 + i])
              .centerColor,
        ),
    });
    expect(validator.validate(state).isValid, isTrue);
    final moves = await const RubikSolverService().solve(state);
    expect(moves, isNotEmpty);
    var result = scrambled;
    for (final move in moves) {
      result = result.move(
        cuber.Move.values.firstWhere(
          (value) => value.toString() == move.toString(),
        ),
      );
    }
    expect(result.isSolved, isTrue);
  });

  test('six immutable faces; only centers filled; reset shape is valid', () {
    final state = CubeState.empty();
    expect(state.enteredCount, 6);
    for (final face in RubikFace.values) {
      expect(state.stickers(face), hasLength(9));
      expect(state.stickers(face)[4], face.centerColor);
      expect(
        () => state.withSticker(face, 4, RubikColor.blue),
        throwsArgumentError,
      );
      expect(
        () => state.stickers(face)[0] = RubikColor.red,
        throwsUnsupportedError,
      );
    }
    expect(() => CubeState({}), throwsArgumentError);
    final updated = state.withSticker(RubikFace.up, 0, RubikColor.red);
    expect(state.stickers(RubikFace.up)[0], isNull);
    expect(updated.stickers(RubikFace.up)[0], RubikColor.red);
    expect(validator.validate(state).isValid, isFalse);
  });

  test('constructor copies external scanner data and validates centers', () {
    final faces = {
      for (final face in RubikFace.values)
        face: List<RubikColor?>.filled(9, face.centerColor),
    };
    final state = CubeState(faces);
    faces[RubikFace.up]![4] = RubikColor.red;
    faces[RubikFace.right]![4] = RubikColor.white;
    expect(validator.validate(state).isValid, isTrue);
    expect(validator.validate(CubeState(faces)).isValid, isFalse);
  });

  test('solved encoding, counts, flipped edge and twisted corner', () {
    final state = CubeState.solved();
    expect(
      state.toFaceletDefinition(),
      'UUUUUUUUURRRRRRRRRFFFFFFFFFDDDDDDDDDLLLLLLLLLBBBBBBBBB',
    );
    expect(validator.validate(state).isValid, isTrue);
    expect(
      validator
          .validate(state.withSticker(RubikFace.up, 0, RubikColor.red))
          .isValid,
      isFalse,
    );
    final flipped = state
        .withSticker(RubikFace.up, 7, RubikColor.green)
        .withSticker(RubikFace.front, 1, RubikColor.white);
    expect(validator.validate(flipped).isValid, isFalse);
    final twisted = state
        .withSticker(RubikFace.up, 8, RubikColor.red)
        .withSticker(RubikFace.right, 0, RubikColor.green)
        .withSticker(RubikFace.front, 2, RubikColor.white);
    expect(validator.validate(twisted).isValid, isFalse);
  });

  test('invalid input never reaches solver; reset restores centers', () async {
    final solver = RecordingSolver();
    final controller = CubeInputController(solver: solver);
    expect(await controller.solve(), isNull);
    expect(solver.calls, 0);
    controller.setSticker(RubikFace.up, 0, RubikColor.red);
    controller.reset();
    expect(controller.state.enteredCount, 6);
    controller.dispose();
  });

  test('one solve at a time; safe disposal during async solve', () async {
    final solver = RecordingSolver();
    final controller = CubeInputController(solver: solver);
    controller.load(CubeState.solved());
    final pending = controller.solve();
    expect(controller.busy, isTrue);
    expect(await controller.solve(), isNull);
    expect(solver.calls, 1);
    controller.dispose();
    solver.completion.complete([]);
    expect(await pending, isEmpty);
  });

  test(
    'existing adapter accepts solved cube and rejects invalid input',
    () async {
      const solver = RubikSolverService();
      expect(await solver.solve(CubeState.solved()), isEmpty);
      await expectLater(solver.solve(CubeState.empty()), throwsArgumentError);
    },
  );

  test('typed moves round trip standard notation', () {
    for (final face in RubikFace.values) {
      for (final suffix in ['', "'", '2']) {
        final notation = '${face.code}$suffix';
        expect(RubikMove.parse(notation).toString(), notation);
      }
    }
    expect(() => RubikMove.parse('invalid'), throwsFormatException);
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
