import '../models/rubik_face.dart';
import '../models/rubik_move.dart';

extension RubikMoveDescription on RubikMove {
  String get faceLabel => face.vietnameseName;
  String get instruction => switch (turn) {
    RubikTurn.clockwise => 'Xoay 90° theo chiều kim đồng hồ',
    RubikTurn.counterClockwise => 'Xoay 90° ngược chiều kim đồng hồ',
    RubikTurn.half => 'Xoay 180° (chiều nào cũng được)',
  };
  String get description => '$faceLabel – ${instruction.toLowerCase()}';
}

extension RubikFaceDescription on RubikFace {
  String get vietnameseName => switch (this) {
    RubikFace.up => 'Mặt trên',
    RubikFace.down => 'Mặt dưới',
    RubikFace.right => 'Mặt phải',
    RubikFace.left => 'Mặt trái',
    RubikFace.front => 'Mặt trước',
    RubikFace.back => 'Mặt sau',
  };
}

String describeMove(String notation) => RubikMove.parse(notation).description;
