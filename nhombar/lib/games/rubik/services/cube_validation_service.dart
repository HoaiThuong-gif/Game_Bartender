import 'package:cuber/cuber.dart';

import '../models/cube_state.dart';
import '../models/rubik_face.dart';

enum CubeInputProblem { incomplete, colorCount, center, impossible }

class CubeValidationResult {
  CubeValidationResult(List<String> errors, {this.problem})
    : errors = List.unmodifiable(errors);
  final List<String> errors;
  final CubeInputProblem? problem;
  bool get isValid => errors.isEmpty;
}

class CubeValidationService {
  const CubeValidationService();

  CubeValidationResult validate(CubeState state) {
    final errors = <String>[];
    if (state.enteredCount != 54) {
      return CubeValidationResult([
        'Còn ${54 - state.enteredCount} ô chưa nhập. Hãy điền đủ 6 mặt.',
      ], problem: CubeInputProblem.incomplete);
    }
    for (final face in RubikFace.values) {
      if (state.stickers(face)[4] != face.centerColor) {
        errors.add('Ô giữa mặt ${face.code} không đúng màu cố định.');
      }
    }
    if (errors.isNotEmpty) {
      return CubeValidationResult(errors, problem: CubeInputProblem.center);
    }
    if (RubikColor.values.any((color) => state.count(color) != 9)) {
      return CubeValidationResult([
        'Số lượng màu chưa đúng: mỗi màu cần đúng 9 ô. Kiểm tra bộ đếm dưới bảng màu.',
      ], problem: CubeInputProblem.colorCount);
    }
    // Reuse cuber to also reject impossible cubies and orientation/parity errors.
    if (errors.isEmpty) {
      try {
        final definition = state.toFaceletDefinition();
        final cube = Cube.from(definition);
        if (!cube.isOk || cube.definition != definition) {
          errors.add(
            'Đã đủ 9 ô mỗi màu, nhưng vị trí/hướng các viên không thể tạo thành Rubik hợp lệ. '
            'Kiểm tra lại màu tâm phía trên khi nhập từng mặt; có thể một mặt bị nhập xoay hoặc ngược.',
          );
        }
      } catch (_) {
        errors.add(
          'Không thể tạo Rubik từ các ô đã nhập. Hãy kiểm tra lại vị trí màu và chiều từng mặt.',
        );
      }
    }
    return CubeValidationResult(
      errors,
      problem: errors.isEmpty ? null : CubeInputProblem.impossible,
    );
  }
}
