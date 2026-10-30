import '../models/cube_state.dart';
import '../models/rubik_face.dart';

/// Scan progress uses the same immutable CubeState as manual input.
class RubikScanController {
  CubeState state = CubeState.empty();
  final Set<RubikFace> confirmed = {};

  void confirm(RubikFace face, List<RubikColor?> colors) {
    if (colors.length != 9 || colors.any((color) => color == null)) {
      throw ArgumentError('Hãy chọn đủ 9 màu trước khi xác nhận.');
    }
    if (colors[4] != face.centerColor) {
      throw ArgumentError(
        'Màu tâm không đúng mặt đang quét. Hãy chụp lại hoặc sửa màu tâm.',
      );
    }
    state = CubeState({
      for (final f in RubikFace.values)
        f: f == face ? colors : state.stickers(f),
    });
    confirmed.add(face);
  }
}
