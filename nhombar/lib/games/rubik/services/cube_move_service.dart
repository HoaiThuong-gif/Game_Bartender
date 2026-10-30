import 'package:cuber/cuber.dart' as cuber;

import '../models/cube_state.dart';
import '../models/rubik_move.dart';

class CubeMoveService {
  const CubeMoveService();

  CubeState apply(CubeState state, RubikMove move) =>
      CubeState.fromFaceletDefinition(
        cuber.Cube.from(state.toFaceletDefinition())
            .move(cuber.Move.parse(move.toString()))
            .definition,
      );
}

/// Future layer-turn animation contract. Complete only after the visual turn.
/// The guide commits [after] on success; a failed animation must restore [before].
/// Currently the guide uses immediate, accurate state snapshots, not animation.
abstract interface class CubeMoveAnimator {
  Future<void> animate({
    required CubeState before,
    required RubikMove move,
    required CubeState after,
  });
}
