import 'dart:isolate';

import 'package:cuber/cuber.dart';

import '../models/cube_state.dart';
import '../models/rubik_move.dart';
import 'cube_validation_service.dart';

abstract interface class CubeSolver {
  Future<List<RubikMove>> solve(CubeState state);
}

/// Keeps the existing cuber integration, off the Android UI isolate.
class RubikSolverService implements CubeSolver {
  const RubikSolverService();

  @override
  Future<List<RubikMove>> solve(CubeState state) async {
    final validation = const CubeValidationService().validate(state);
    if (!validation.isValid) {
      throw ArgumentError(validation.errors.join('\n'));
    }
    final definition = state.toFaceletDefinition();
    return Isolate.run(() {
      final cube = Cube.from(definition);
      if (cube.isSolved) return <RubikMove>[];
      final solution = cube.solve(
        maxDepth: 25,
        timeout: const Duration(seconds: 10),
      );
      if (solution == null) {
        throw StateError('Không tìm được lời giải trong thời gian cho phép.');
      }
      return solution.algorithm
          .map((move) => RubikMove.parse(move.toString()))
          .toList();
    });
  }
}
