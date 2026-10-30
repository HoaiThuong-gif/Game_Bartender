import '../../../../core/api/api_client.dart';
import '../models/rubik_room.dart';
import 'rubik_challenge_service.dart';

class ApiRubikChallengeRepository implements RubikChallengeRepository {
  ApiRubikChallengeRepository({ApiClient? client})
    : _api = client ?? ApiClient();
  final ApiClient _api;
  String? _room;
  bool _disposed = false;
  @override
  String get uid => _api.uid;
  @override
  bool get demo => false;
  @override
  int get serverNow =>
      DateTime.now().millisecondsSinceEpoch + _api.serverOffsetMs;
  String _path(String code) => '/rubik/rooms/$code';
  @override
  Future<String> create(String name) async {
    await _api.session(name);
    final data = await _api.request('POST', '/rubik/rooms');
    return _room = data['code'] as String;
  }

  @override
  Future<void> join(String code, String name) async {
    await _api.session(name);
    await _api.request('POST', '${_path(code)}/join');
    _room = code;
  }

  @override
  Stream<RubikRoom?> watch(String code) => _api
      .watch(_path(code))
      .map(
        (data) => data['room'] == null
            ? null
            : RubikRoom(code, challengeMap(data['room'])),
      );
  @override
  Future<void> send(String code, int round, String action) async {
    await _api.request('POST', '${_path(code)}/commands', {
      'round': round,
      'action': action,
    });
  }

  @override
  Future<void> presence(String code, bool online) async {
    await _api.request('POST', '${_path(code)}/presence', {'online': online});
  }

  @override
  Future<void> dispose() async {
    if (_disposed) return;
    _disposed = true;
    try {
      if (_room != null) await presence(_room!, false);
    } catch (_) {
      /* Server heartbeat expires after 30 seconds. */
    } finally {
      _api.close();
    }
  }
}
