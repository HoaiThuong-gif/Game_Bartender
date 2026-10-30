import 'dart:async';

import '../../../core/api/api_client.dart';
import '../models/game_item.dart';
import '../models/match_result.dart';
import '../models/match_timer.dart';
import '../models/order.dart';
import '../models/player.dart';
import '../models/room.dart';
import '../models/round.dart';
import '../models/station.dart';
import 'room_repository.dart';

Map<String, dynamic> _map(Object? value) =>
    value is Map ? Map<String, dynamic>.from(value) : {};

class ApiRoomRepository implements RoomRepository {
  ApiRoomRepository({ApiClient? client}) : _api = client ?? ApiClient();
  final ApiClient _api;
  String? _code;
  Room? _latest;
  final _connectionChanges = StreamController<RoomConnectionState>.broadcast();
  RoomConnectionState _connection = RoomConnectionState.reconnecting;
  int _failures = 0;
  @override
  RoomConnectionState get connectionState => _connection;
  @override
  Stream<RoomConnectionState> watchConnectionState() =>
      _connectionChanges.stream;

  void _setConnection(RoomConnectionState state) {
    if (_connection == state || _connectionChanges.isClosed) return;
    _connection = state;
    _connectionChanges.add(state);
  }

  @override
  String get localPlayerId => _api.uid;
  String _path(String code) => '/bartender/rooms/$code';

  Room _decode(Map<String, dynamic> response) {
    _failures = 0;
    _setConnection(RoomConnectionState.connected);
    final data = _map(response['room']);
    if (data.isEmpty) throw StateError('Phòng không còn tồn tại.');
    final players = _map(data['players']).map((id, value) {
      final p = _map(value);
      return MapEntry(
        id,
        Player(
          id: id,
          name: p['name'] as String,
          ringIndex: p['ringIndex'] as int,
          connected: p['connected'] as bool,
          completedOrders: p['completedOrders'] as int,
          readyInLobby: p['readyInLobby'] as bool? ?? true,
        ),
      );
    });
    final timer = _map(data['timer']),
        round = _map(data['round']),
        results = _map(data['results']);
    final room = Room(
      code: response['code'] as String,
      status: RoomStatus.values.byName(data['status'] as String),
      players: players,
      inbox: _map(data['inbox']).map(
        (ring, box) => MapEntry(
          int.parse(ring),
          _map(box).entries.map((e) => _item(e.key, _map(e.value))).toList(),
        ),
      ),
      timer: timer.isEmpty
          ? null
          : MatchTimer(
              endTime: timer['endTime'] as int,
              startedAt: timer['startedAt'] as int,
              serverOffsetMs: _api.serverOffsetMs,
              isPreparing: timer['preparing'] == true,
              readyPlayerIds: _map(timer['readyPlayers']).entries
                  .where((entry) => entry.value == true)
                  .map((entry) => entry.key)
                  .toSet(),
            ),
      currentRound: round.isEmpty
          ? null
          : Round(
              number: round['number'] as int,
              ordersPerPlayer: round['ordersPerPlayer'] as int,
              stationAssignment: _map(round['stationAssignment']).map(
                (ring, station) => MapEntry(
                  int.parse(ring),
                  station == null
                      ? null
                      : StationType.values.byName(station as String),
                ),
              ),
              playerOrders: _map(data['orders']).map(
                (id, orders) => MapEntry(
                  id,
                  _map(orders).entries.map((e) {
                    final o = _map(e.value);
                    return Order(
                      id: e.key,
                      recipeId: o['recipeId'] as String,
                      status: OrderStatus.values.byName(o['status'] as String),
                    );
                  }).toList(),
                ),
              ),
            ),
      results: results.isEmpty
          ? null
          : MatchResult(
              totalSurvivalSeconds: results['totalSurvivalSeconds'] as int,
              totalTeamOrders: results['totalTeamOrders'] as int,
              ranking: (results['ranking'] as List)
                  .map((p) => players[_map(p)['playerId']]!)
                  .toList(),
            ),
    );
    _latest = room;
    return room;
  }

  GameItem _item(String id, Map<String, dynamic> data) => GameItem(
    id: id,
    type: GameItemType.values.byName(data['type'] as String),
    itemId: data['itemId'] as String,
    fromRingIndex: data['fromRingIndex'] as int,
  );

  Future<Map<String, dynamic>> _command(
    String code,
    String action, [
    Map<String, dynamic>? body,
  ]) => _api.request('POST', '${_path(code)}/$action', body);

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    await _api.session(hostPlayerName);
    final response = await _api.request('POST', '/bartender/rooms');
    _code = response['code'] as String;
    return _decode(response);
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    await _api.session(playerName);
    final response = await _command(code, 'join');
    _code = code;
    return _decode(response);
  }

  @override
  Stream<Room> watchRoom(String code) => _api
      .watch(_path(code))
      .map(_decode)
      .handleError((Object error, StackTrace stack) {
        _failures++;
        _setConnection(
          _failures >= 5
              ? RoomConnectionState.lost
              : RoomConnectionState.reconnecting,
        );
        Error.throwWithStackTrace(error, stack);
      });

  @override
  Future<void> returnToLobby({
    required String code,
    required String playerId,
  }) async {
    _decode(await _command(code, 'return'));
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    await _command(code, 'leave');
    _code = null;
  }

  @override
  Future<void> startMatch({
    required String code,
    bool waitForScene = false,
  }) async {
    await _command(code, 'start', {'waitForScene': waitForScene});
  }

  @override
  Future<void> markSceneReady({
    required String code,
    required String playerId,
    required int preparationId,
  }) async {
    await _command(code, 'prepared', {'preparationId': preparationId});
  }

  @override
  Future<void> endMatch(String code) async {
    await _command(code, 'end');
  }

  @override
  Future<void> sendItem({
    required String code,
    required int fromRingIndex,
    required int toRingIndex,
    required GameItem item,
  }) async {
    await _command(code, 'send', {
      'itemId': item.id,
      'toRingIndex': toRingIndex,
    });
  }

  @override
  Future<void> trashItem({
    required String code,
    required int ringIndex,
    required String itemId,
  }) async {
    await _command(code, 'trash', {'itemId': itemId});
  }

  @override
  Future<GameItem> processItemAtStation({
    required String code,
    required int ringIndex,
    required String itemId,
    required StationType station,
  }) async {
    final room = _decode(
      await _command(code, 'process', {
        'itemId': itemId,
        'station': station.name,
      }),
    );
    return room.itemsAtRing(ringIndex).firstWhere((item) => item.id == itemId);
  }

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    // Legacy controller passes the product type; HTTP sends the actual inbox key.
    final ring = _latest?.players[localPlayerId]?.ringIndex;
    final items = _latest?.itemsAtRing(ring ?? -1) ?? [];
    final item = items
        .where((i) => i.id == productId || i.itemId == productId)
        .firstOrNull;
    if (item == null) throw StateError('Sản phẩm không còn trong khay.');
    await _command(code, 'submit', {'orderId': orderId, 'productId': item.id});
  }

  @override
  void dispose() {
    _connectionChanges.close();
    final code = _code;
    if (code == null) {
      _api.close();
      return;
    }
    _command(
      code,
      'leave',
    ).catchError((Object _) => <String, dynamic>{}).whenComplete(_api.close);
  }
}
