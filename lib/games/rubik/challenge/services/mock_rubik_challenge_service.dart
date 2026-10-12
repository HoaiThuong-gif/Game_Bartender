import 'dart:async';
import 'dart:math';

import '../models/rubik_room.dart';
import 'rubik_challenge_service.dart';

/// Explicit single-device demo. No Firebase access and no real wallet credits.
class MockRubikChallengeRepository implements RubikChallengeRepository {
  final _events = StreamController<RubikRoom?>.broadcast();
  Map<String, dynamic>? _data;
  final List<Timer> _timers = [];
  @override
  String get uid => 'demo-you';
  @override
  bool get demo => true;
  @override
  int get serverNow => DateTime.now().millisecondsSinceEpoch;
  void _emit() =>
      _events.add(_data == null ? null : RubikRoom('DEMO22', _data!));
  Map<String, dynamic> _player(String name) => {
    'name': name,
    'ready': false,
    'loaded': false,
    'finished': false,
    'dnf': false,
    'rematch': false,
    'left': false,
  };
  @override
  Future<String> create(String name) async {
    _data = {
      'status': 'waiting',
      'round': 1,
      'creationId': 'demo',
      'players': {uid: _player(name)},
    };
    _timers.add(
      Timer(const Duration(seconds: 1), () {
        if (_data == null) return;
        (_data!['players'] as Map)['demo-rival'] = _player('Đối thủ thử nghiệm')
          ..['ready'] = true;
        _data!['status'] = 'ready';
        _emit();
      }),
    );
    return 'DEMO22';
  }

  @override
  Future<void> join(String code, String name) async {
    await create(name);
  }

  @override
  Stream<RubikRoom?> watch(String code) async* {
    yield _data == null ? null : RubikRoom('DEMO22', _data!);
    yield* _events.stream;
  }

  void _finishRival(int round) {
    if (_data == null ||
        _data!['round'] != round ||
        _data!['status'] == 'finished') {
      return;
    }
    final p = (_data!['players'] as Map)['demo-rival'] as Map;
    p['finished'] = true;
    p['finishMs'] = serverNow - (_data!['startAt'] as int);
    _settle();
    _emit();
  }

  void _settle() {
    final players = _data!['players'] as Map;
    if (!players.values.every(
      (p) => p['finished'] == true || p['dnf'] == true,
    )) {
      return;
    }
    final a = players[uid] as Map, b = players['demo-rival'] as Map;
    final winner = a['dnf'] == true
        ? (b['dnf'] == true ? 'none' : 'demo-rival')
        : b['dnf'] == true
        ? uid
        : a['finishMs'] == b['finishMs']
        ? 'draw'
        : (a['finishMs'] as int) < (b['finishMs'] as int)
        ? uid
        : 'demo-rival';
    _data!['status'] = 'finished';
    _data!['winnerId'] = winner;
    _data!['rewards'] = {
      for (final id in players.keys)
        id: players[id]['dnf'] == true
            ? 0
            : winner == 'draw'
            ? 25
            : winner == id
            ? 50
            : 10,
    };
  }

  @override
  Future<void> send(String code, int round, String action) async {
    if (_data == null || _data!['round'] != round) return;
    final players = _data!['players'] as Map, me = players[uid] as Map;
    switch (action) {
      case 'ready':
        me['ready'] = true;
        final random = Random();
        final moves = <String>[];
        const faces = 'RLUDFB';
        var last = -1;
        for (var i = 0; i < 20; i++) {
          var face = random.nextInt(6);
          while (face ~/ 2 == last) {
            face = random.nextInt(6);
          }
          last = face ~/ 2;
          moves.add('${faces[face]}${['', "'", '2'][random.nextInt(3)]}');
        }
        _data!['scramble'] = moves;
      case 'loaded':
        if (_data!['status'] != 'ready') return;
        _data!['status'] = 'countdown';
        _data!['startAt'] = serverNow + 5000;
        _timers.add(
          Timer(const Duration(seconds: 5), () {
            if (_data == null || _data!['round'] != round) return;
            _data!['status'] = 'playing';
            _emit();
          }),
        );
        _timers.add(
          Timer(const Duration(seconds: 25), () => _finishRival(round)),
        );
      case 'finish':
        if (_data!['status'] != 'playing' || me['finished'] == true) return;
        me['finished'] = true;
        me['finishMs'] = serverNow - (_data!['startAt'] as int);
        _settle();
      case 'tick':
        if (_data!['startAt'] != null &&
            serverNow >= (_data!['startAt'] as int) + 300000 &&
            _data!['status'] != 'finished') {
          for (final p in players.values) {
            if (p['finished'] != true) p['dnf'] = true;
          }
          _settle();
        }
      case 'rematch':
        if (_data!['status'] != 'finished') return;
        _data!['round'] = round + 1;
        _data!['status'] = 'ready';
        players[uid] = _player(me['name'] as String);
        players['demo-rival'] = _player('Đối thủ thử nghiệm')..['ready'] = true;
        _data!.remove('scramble');
        _data!.remove('startAt');
        _data!.remove('winnerId');
        _data!.remove('rewards');
      case 'leave':
        _data = null;
    }
    _emit();
  }

  @override
  Future<void> presence(String code, bool online) async {}
  @override
  Future<Map<String, int>> rewardReceipts() async => {};
  @override
  Future<void> dispose() async {
    for (final timer in _timers) {
      timer.cancel();
    }
    await _events.close();
  }
}
