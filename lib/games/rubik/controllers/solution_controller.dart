import 'dart:async';
import 'package:flutter/foundation.dart';

import '../models/cube_state.dart';
import '../models/rubik_move.dart';
import '../services/cube_move_service.dart';

class SolutionController extends ChangeNotifier {
  SolutionController({
    required CubeState initialState,
    required List<RubikMove> moves,
    this.animator,
  }) : _initialState = initialState,
       _state = initialState,
       moves = List.unmodifiable(moves);
  final List<RubikMove> moves;
  final CubeMoveAnimator? animator;
  final CubeState _initialState;
  CubeState _state;
  CubeState get state => _state;
  int _completed = 0;
  int get completed => _completed;
  /// Next move to perform; null when every move has already been applied.
  int? get currentMoveIndex => isComplete ? null : completed;
  Timer? _timer;
  bool _isPlaying = false;
  bool get isPlaying => _isPlaying;
  double _playbackSpeed = 1;
  double get playbackSpeed => _playbackSpeed;
  bool busy = false;
  bool _disposed = false;
  String? error;
  RubikMove? lastUndo;
  bool get isComplete => completed == moves.length;
  RubikMove? get currentMove => isComplete ? null : moves[completed];

  Future<void> next() async {
    pause();
    if (busy || isComplete || _disposed) return;
    await _transition(moves[completed], 1);
  }

  Future<void> previous() async {
    pause();
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
      _isPlaying = false;
      error = 'Chưa chuyển được bước. Hãy thử lại.';
    } finally {
      busy = false;
      if (isComplete) _isPlaying = false;
      if (!_disposed) notifyListeners();
    }
  }

  void play() {
    if (_disposed || busy || isComplete || _isPlaying) return;
    _isPlaying = true;
    _schedule();
    notifyListeners();
  }

  void pause() {
    _timer?.cancel();
    _timer = null;
    if (!_isPlaying) return;
    _isPlaying = false;
    if (!_disposed) notifyListeners();
  }

  void setSpeed(double speed) {
    if (_disposed || !const [0.5, 1.0, 2.0].contains(speed) || speed == _playbackSpeed) return;
    _playbackSpeed = speed;
    if (_isPlaying && !busy) _schedule();
    notifyListeners();
  }

  void _schedule() {
    _timer?.cancel();
    if (!_isPlaying || _disposed || isComplete) return;
    // One pending timer, never a periodic tick or a second render loop.
    _timer = Timer(Duration(milliseconds: (1200 / _playbackSpeed).round()), () async {
      _timer = null;
      if (!_isPlaying || _disposed || busy) return;
      await _transition(moves[completed], 1);
      if (_isPlaying && !_disposed) _schedule();
    });
  }

  /// Target is the number of applied moves. Selecting row i shows state
  /// BEFORE move i, so the highlighted instruction is the next action.
  void seek(int target) {
    if (_disposed || busy) return;
    RangeError.checkValueInInterval(target, 0, moves.length);
    pause();
    try {
      var state = _initialState;
      for (var i = 0; i < target; i++) {
        state = const CubeMoveService().apply(state, moves[i]);
      }
      _state = state;
      _completed = target;
      lastUndo = null;
      error = null;
    } catch (_) {
      error = 'Chưa chuyển được bước. Hãy thử lại.';
    }
    notifyListeners();
  }

  void first() => seek(0);
  void last() => seek(moves.length);

  @override
  void dispose() {
    _disposed = true;
    _timer?.cancel();
    super.dispose();
  }
}
