import 'dart:async';

import 'package:flutter/foundation.dart';

import '../models/rubik_room.dart';
import '../services/rubik_challenge_service.dart';

class RubikChallengeController extends ChangeNotifier {
  RubikChallengeController(this.repository, this.code) {
    _subscription = repository
        .watch(code)
        .listen(
          _update,
          onError: (Object e) {
            error = e.toString();
            notifyListeners();
          },
        );
    _ticker = Timer.periodic(const Duration(milliseconds: 50), (_) {
      if (_disposed) return;
      notifyListeners();
      final current = room;
      if (current != null &&
          current.startAt != null &&
          repository.serverNow >= current.startAt! &&
          [
            ChallengeStatus.countdown,
            ChallengeStatus.playing,
          ].contains(current.status) &&
          repository.serverNow - _lastTick >= 5000 &&
          !_ticking) {
        _lastTick = repository.serverNow;
        _ticking = true;
        unawaited(
          repository
              .send(code, current.round, 'tick')
              .catchError((Object _) {})
              .whenComplete(() => _ticking = false),
        );
      }
    });
  }
  final RubikChallengeRepository repository;
  final String code;
  RubikRoom? room;
  String? error;
  bool busy = false, finishPending = false, solved = false, prepared = false;
  bool _disposed = false, _ticking = false;
  int _lastTick = 0;
  int? _loadedRound;
  late final StreamSubscription<RubikRoom?> _subscription;
  late final Timer _ticker;
  ChallengePlayer? get me => room?.players[repository.uid];
  bool get playing =>
      room?.startAt != null &&
      repository.serverNow >= room!.startAt! &&
      [
        ChallengeStatus.countdown,
        ChallengeStatus.playing,
      ].contains(room!.status);
  int get elapsed => room?.startAt == null
      ? 0
      : (repository.serverNow - room!.startAt!).clamp(0, 300000);
  int get countdown => room?.startAt == null
      ? 0
      : ((room!.startAt! - repository.serverNow) / 1000).ceil().clamp(0, 5);
  void _update(RubikRoom? value) {
    if (_disposed) return;
    if (value?.round != room?.round) {
      prepared = false;
      solved = false;
      finishPending = false;
      _loadedRound = null;
    }
    room = value;
    if (me?.finished == true) finishPending = false;
    notifyListeners();
  }

  Future<void> action(String action) async {
    if (busy || room == null) return;
    if (action == 'finish' &&
        (!playing ||
            !solved ||
            !prepared ||
            me?.finished == true ||
            finishPending)) {
      return;
    }
    busy = true;
    error = null;
    if (action == 'finish') finishPending = true;
    notifyListeners();
    try {
      await repository.send(code, room!.round, action);
    } catch (e) {
      error = e.toString();
      if (action == 'finish') finishPending = false;
    } finally {
      busy = false;
      if (!_disposed) notifyListeners();
      if (!_disposed &&
          action == 'ready' &&
          prepared &&
          room?.status == ChallengeStatus.ready &&
          _loadedRound != room?.round) {
        unawaited(this.action('loaded'));
      }
    }
  }

  void cubePrepared() {
    if (_disposed) return;
    prepared = true;
    _loadedRound = busy ? null : room?.round;
    if (room?.status == ChallengeStatus.ready) unawaited(action('loaded'));
    notifyListeners();
  }

  void cubeSolved(bool value) {
    if (_disposed) return;
    solved = value;
    notifyListeners();
  }

  Future<void> leave() async {
    if (room != null) await repository.send(code, room!.round, 'leave');
  }

  @override
  void dispose() {
    _disposed = true;
    _ticker.cancel();
    unawaited(_subscription.cancel());
    super.dispose();
  }
}
