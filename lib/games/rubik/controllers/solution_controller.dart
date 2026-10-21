import 'package:flutter/foundation.dart';

import '../models/cube_state.dart';
import '../models/rubik_move.dart';
import '../services/cube_move_service.dart';

class SolutionController extends ChangeNotifier {
  SolutionController({
    required CubeState initialState,
    required List<RubikMove> moves,
    this.animator,
  }) : _state = initialState,
       moves = List.unmodifiable(moves);
  final List<RubikMove> moves;
  final CubeMoveAnimator? animator;
  CubeState _state;
  CubeState get state => _state;
  int _completed = 0;
  int get completed => _completed;
  bool busy = false;
  bool _disposed = false;
  String? error;
  RubikMove? lastUndo;
  bool get isComplete => completed == moves.length;
  RubikMove? get currentMove => isComplete ? null : moves[completed];

  Future<void> next() async {
    if (busy || isComplete || _disposed) return;
    await _transition(moves[completed], 1);
  }

  Future<void> previous() async {
    if (busy || completed == 0 || _disposed) return;
    await _transition(moves[completed - 1].inverse, -1);
  }

  Future<void> _transition(RubikMove move, int direction) async {
    busy = true;
    error = null;
    notifyListeners();
    try {
      final after = const CubeMoveService().apply(_state, move);
      if (animator != null) {
        await animator!.animate(before: _state, move: move, after: after);
      }
      if (_disposed) return;
      _state = after;
      _completed += direction;
      lastUndo = direction < 0 ? move : null;
    } catch (_) {
      error = 'Chưa chuyển được bước. Hãy thử lại.';
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
    }
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }
}
