import 'package:cuber/cuber.dart';
import 'package:flutter/foundation.dart';

import '../models/cube_state.dart';

/// Development-only report, generated at the explicit check/solve action.
void logCubeInput(CubeState state) {
  if (!kDebugMode) return;
  debugPrint(
    '[Rubik input] Rows as seen by user, top face specified per face:',
  );
  for (final face in CubeState.definitionOrder) {
    debugPrint(
      '${face.code} (top=${face.topFace.code}): '
      '${state.stickers(face).map((color) => color?.name ?? "?").toList()}',
    );
  }
  final definition = state.toFaceletDefinition(allowIncomplete: true);
  debugPrint('definition (${definition.length}): $definition');
  debugPrint(
    'counts: ${CubeState.definitionOrder.map((face) => '${face.code}=${state.count(face.centerColor)}').join(', ')}; '
    'unknown=${54 - state.enteredCount}',
  );
  if (definition.contains('?')) {
    debugPrint('Cube.from: skipped (incomplete); isOk/isSolved: unavailable');
    return;
  }
  try {
    final cube = Cube.from(definition);
    debugPrint(
      'Cube.from: success; isOk=${cube.isOk}; '
      'isSolved=${cube.isSolved}; status=${cube.verify().name}; '
      'roundTrip=${cube.definition == definition}',
    );
  } catch (error) {
    debugPrint('Cube.from: failed: $error; isOk/isSolved: unavailable');
  }
}
