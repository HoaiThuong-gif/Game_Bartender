import 'rubik_face.dart';

enum RubikTurn { clockwise, half, counterClockwise }

/// Clockwise is defined while looking directly at the face from outside.
class RubikMove {
  const RubikMove(this.face, this.turn);
  final RubikFace face;
  final RubikTurn turn;

  RubikMove get inverse => RubikMove(face, switch (turn) {
    RubikTurn.clockwise => RubikTurn.counterClockwise,
    RubikTurn.counterClockwise => RubikTurn.clockwise,
    RubikTurn.half => RubikTurn.half,
  });

  factory RubikMove.parse(String notation) {
    final match = RegExp(r"^([URFDLB])(2|')?$").firstMatch(notation);
    if (match == null) throw FormatException('Unsupported move', notation);
    return RubikMove(
      RubikFace.values.firstWhere((face) => face.code == match[1]),
      switch (match[2]) {
        '2' => RubikTurn.half,
        "'" => RubikTurn.counterClockwise,
        _ => RubikTurn.clockwise,
      },
    );
  }

  @override
  String toString() =>
      '${face.code}${switch (turn) {
        RubikTurn.clockwise => '',
        RubikTurn.half => '2',
        RubikTurn.counterClockwise => "'",
      }}';
}
