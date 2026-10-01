import 'package:flutter/foundation.dart';

import '../models/cube_state.dart';
import '../models/rubik_face.dart';
import '../models/rubik_move.dart';
import '../services/cube_validation_service.dart';
import '../services/cube_input_diagnostics.dart';
import '../services/rubik_solver_service.dart';

class CubeInputController extends ChangeNotifier {
  CubeInputController({CubeSolver? solver})
    : _solver = solver ?? const RubikSolverService();

  final CubeSolver _solver;
  CubeState _state = CubeState.empty();
  CubeState get state => _state;
  bool _busy = false;
  bool get busy => _busy;
  bool _disposed = false;
  String? error;
  CubeValidationResult get validation =>
      const CubeValidationService().validate(_state);

  void setSticker(RubikFace face, int index, RubikColor? color) {
    if (_busy) return;
    if (index == 4 || _state.stickers(face)[index] == color) return;
    if (color != null && _state.count(color) >= 9) {
      error = 'Màu này đã đủ 9 ô. Hãy xóa hoặc đổi một ô cùng màu trước.';
      notifyListeners();
      return;
    }
    _state = _state.withSticker(face, index, color);
    error = null;
    notifyListeners();
  }

  /// Both manual input and a future CubeScanner feed this same state.
  void load(CubeState state) {
    if (_busy) return;
    _state = state;
    error = null;
    notifyListeners();
  }

  void reset() => load(CubeState.empty());

  Future<List<RubikMove>?> solve() async {
    if (_busy || _disposed) return null;
    logCubeInput(_state);
    final result = validation;
    if (!result.isValid) {
      error = result.errors.join('\n');
      notifyListeners();
      return null;
    }
    _busy = true;
    error = null;
    notifyListeners();
    try {
      return await _solver.solve(_state);
    } catch (_) {
      error = 'Chưa tìm được lời giải. Hãy thử lại.';
      return null;
    } finally {
      _busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
