import 'rubik_face.dart';

/// Immutable 3x3 state. Null means a sticker has not been entered yet.
/// Each face is row-major, viewed from outside the cube (center = index 4).
class CubeState {
  static const definitionOrder = [
    RubikFace.up,
    RubikFace.right,
    RubikFace.front,
    RubikFace.down,
    RubikFace.left,
    RubikFace.back,
  ];
  CubeState(Map<RubikFace, List<RubikColor?>> faces)
    : _faces = Map.unmodifiable({
        for (final entry in faces.entries)
          entry.key: List<RubikColor?>.unmodifiable(entry.value),
      }) {
    if (_faces.length != 6 ||
        RubikFace.values.any((face) => _faces[face]?.length != 9)) {
      throw ArgumentError('A cube must have six faces of nine stickers.');
    }
  }

  factory CubeState.empty() => CubeState({
    for (final face in RubikFace.values)
      face: List.generate(9, (i) => i == 4 ? face.centerColor : null),
  });

  factory CubeState.solved() => CubeState({
    for (final face in RubikFace.values) face: List.filled(9, face.centerColor),
  });

  final Map<RubikFace, List<RubikColor?>> _faces;
  List<RubikColor?> stickers(RubikFace face) => _faces[face]!;
  int get enteredCount =>
      _faces.values.expand((face) => face).whereType<RubikColor>().length;
  int count(RubikColor color) => _faces.values
      .expand((face) => face)
      .where((value) => value == color)
      .length;

  CubeState withSticker(RubikFace face, int index, RubikColor? color) {
    RangeError.checkValidIndex(index, stickers(face));
    if (index == 4) throw ArgumentError('Center stickers are fixed.');
    final updated = List<RubikColor?>.of(stickers(face));
    updated[index] = color;
    return CubeState({..._faces, face: updated});
  }

  /// The single UI -> cuber conversion. UI rows match cuber's facelet net
  /// only when the cube is held with face.topFace above the facing center.
  /// No per-face rotation/mirroring is needed under that explicit convention.
  /// '?' is permitted ONLY for diagnostics, never for the solver.
  String toFaceletDefinition({bool allowIncomplete = false}) =>
      definitionOrder.expand(stickers).map((color) {
        if (color == null) {
          if (allowIncomplete) return '?';
          throw StateError('Cube input is incomplete.');
        }
        return RubikFace.values
            .firstWhere((face) => face.centerColor == color)
            .code;
      }).join();

  /// Import a cuber definition using the same face order and orientation.
  factory CubeState.fromFaceletDefinition(String definition) {
    if (!RegExp(r'^[URFDLB]{54}$').hasMatch(definition)) {
      throw FormatException('Expected 54 URFDLB facelets', definition);
    }
    return CubeState({
      for (var f = 0; f < definitionOrder.length; f++)
        definitionOrder[f]: List.generate(
          9,
          (i) => definitionOrder
              .firstWhere((face) => face.code == definition[f * 9 + i])
              .centerColor,
        ),
    });
  }
}
