import 'dart:async';

import 'package:cuber/cuber.dart' as cuber;

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/rubik/controllers/cube_input_controller.dart';
import 'package:nhom_bar/games/rubik/models/cube_state.dart';
import 'package:nhom_bar/games/rubik/models/rubik_face.dart';
import 'package:nhom_bar/games/rubik/models/rubik_move.dart';
import 'package:nhom_bar/games/rubik/services/cube_validation_service.dart';
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
}
