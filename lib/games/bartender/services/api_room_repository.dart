import 'dart:async';
import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/web_socket_channel.dart';

import '../bartender_config.dart';
import '../models/game_item.dart';
import '../models/player.dart';
import '../models/room.dart';
import '../models/station.dart';
import 'room_repository.dart';

/// Bản triển khai [RoomRepository] giao tiếp với backend server tự host
/// qua HTTP REST API và WebSocket snapshots theo hợp đồng API.md.
enum _ReconnectOutcome { success, permanentFailure, retryableFailure }

class ApiRoomRepository implements RoomRepository {
  ApiRoomRepository({
    String? baseUrl,
    http.Client? httpClient,
    this.wsFactory,
    Future<void> Function(Duration duration)? delayFn,
    this.maxReconnectDuration = const Duration(seconds: 30),
  }) : _baseUrl = _cleanBaseUrl(baseUrl ?? BartenderConfig.apiBaseUrl),
       _httpClient = httpClient ?? http.Client(),
       _delayFn = delayFn ?? Future.delayed;

  final String _baseUrl;
  final http.Client _httpClient;
  final WebSocketChannel Function(Uri uri)? wsFactory;
  final Future<void> Function(Duration duration) _delayFn;
  final Duration maxReconnectDuration;

  String _localPlayerId = '';
  String? _playerToken;
  Room? _currentRoom;

  StreamController<Room>? _roomStreamController;
  StreamController<RoomConnectionState>? _connectionStateController;
  RoomConnectionState _connectionState = RoomConnectionState.connected;

  WebSocketChannel? _wsChannel;
  StreamSubscription<dynamic>? _wsSubscription;
  bool _isDisposed = false;
  bool _isReconnecting = false;
  bool _isLeaving = false;

  @override
  String get localPlayerId => _localPlayerId;

  @override
  RoomConnectionState get connectionState => _connectionState;

  @override
  Stream<RoomConnectionState> watchConnectionState() {
    _connectionStateController ??=
        StreamController<RoomConnectionState>.broadcast();
    final current = _connectionState;
    scheduleMicrotask(() {
      if (!_isDisposed &&
          _connectionStateController != null &&
          !_connectionStateController!.isClosed) {
        _connectionStateController!.add(current);
      }
    });
    return _connectionStateController!.stream;
  }

  void _setConnectionState(RoomConnectionState state) {
    if (_connectionState != state) {
      _connectionState = state;
      if (!_isDisposed &&
          _connectionStateController != null &&
          !_connectionStateController!.isClosed) {
        _connectionStateController!.add(state);
      }
    }
  }

  void _emitError(Object error) {
    if (!_isDisposed &&
        _roomStreamController != null &&
        !_roomStreamController!.isClosed) {
      _roomStreamController!.addError(error);
    }
  }

  String? get playerToken => _playerToken;

  static String _cleanBaseUrl(String url) {
    var u = url.trim();
    if (u.endsWith('/')) {
      u = u.substring(0, u.length - 1);
    }
    return u;
  }

  String get _wsBaseUrl {
    if (_baseUrl.startsWith('https://')) {
      return _baseUrl.replaceFirst('https://', 'wss://');
    }
    return _baseUrl.replaceFirst('http://', 'ws://');
  }

  StreamController<Room> _getOrCreateController() {
    if (_roomStreamController == null || _roomStreamController!.isClosed) {
      _roomStreamController = StreamController<Room>.broadcast();
    }
    return _roomStreamController!;
  }

  void _emit(Room room) {
    _currentRoom = room;
    if (!_isDisposed &&
        _roomStreamController != null &&
        !_roomStreamController!.isClosed) {
      _roomStreamController!.add(room);
    }
  }

  /// Ánh xạ mã lỗi chuẩn từ API.md sang thông điệp tiếng Việt thân thiện.
  static String mapApiError(String code, String fallback) {
    switch (code) {
      case 'INVALID_REQUEST':
        return 'Yêu cầu không hợp lệ ($fallback).';
      case 'UNAUTHORIZED':
        return 'Không có quyền truy cập hoặc phiên đã hết hạn.';
      case 'ROOM_NOT_FOUND':
        return 'Phòng chơi không tồn tại.';
      case 'ITEM_NOT_FOUND':
        return 'Vật phẩm không còn trong khay đồ.';
      case 'ROOM_FULL':
        return 'Phòng đã đủ 4 người chơi.';
      case 'ROOM_NOT_JOINABLE':
        return 'Phòng đã bắt đầu hoặc đã kết thúc.';
      case 'NOT_ENOUGH_PLAYERS':
        return 'Cần ít nhất 2 người chơi kết nối để bắt đầu.';
      case 'INVALID_STATE':
        return 'Thao tác không được phép ở trạng thái hiện tại.';
      case 'INVALID_MOVE':
        return 'Nước đi không hợp lệ (không liền kề hoặc sai trạm chế biến).';
      case 'ORDER_MISMATCH':
        return 'Món ăn không khớp với đơn hàng hoặc đơn đã nộp.';
      default:
        return fallback.isNotEmpty ? fallback : 'Lỗi kết nối máy chủ.';
    }
  }

  Never _handleErrorResponse(http.Response response) {
    try {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final err = data['error'] as Map<String, dynamic>?;
      if (err != null) {
        final code = err['code'] as String? ?? 'UNKNOWN';
        final msg = err['message'] as String? ?? '';
        throw StateError(mapApiError(code, msg));
      }
    } catch (e) {
      if (e is StateError) rethrow;
    }
    throw StateError('Lỗi máy chủ (${response.statusCode}): ${response.body}');
  }

  void _connectWebSocket(String code, String token) {
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();

    final uri = Uri.parse('$_wsBaseUrl/rooms/$code/ws?token=$token');
    final factory = wsFactory;
    final channel = factory != null
        ? factory(uri)
        : WebSocketChannel.connect(uri);
    _wsChannel = channel;
    _setConnectionState(RoomConnectionState.connected);

    _listenToSocket(channel, code, token);
  }

  void _listenToSocket(WebSocketChannel channel, String code, String token) {
    _wsSubscription = channel.stream.listen(
      (data) {
        try {
          final map = jsonDecode(data as String) as Map<String, dynamic>;
          if (map['type'] == 'snapshot' && map['room'] != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final room = Room.fromJson(
              map['room'] as Map<String, dynamic>,
              localNowMs: now,
            );
            _emit(room);
          } else if (map['type'] == 'ping') {
            channel.sink.add(jsonEncode({'type': 'pong'}));
          }
        } catch (_) {
          // Bỏ qua tin nhắn không parse được
        }
      },
      onError: (err) {
        _handleSocketDisruption(code, token, error: err);
      },
      onDone: () {
        _handleSocketDisruption(code, token, closeCode: channel.closeCode);
      },
    );
  }

  void _handleSocketDisruption(
    String code,
    String token, {
    Object? error,
    int? closeCode,
  }) {
    if (_isDisposed || _isLeaving) return;

    if (_currentRoom?.status == RoomStatus.ended) {
      return;
    }

    if (closeCode == 4401 || closeCode == 4404) {
      _setConnectionState(RoomConnectionState.lost);
      final errorMsg = closeCode == 4401
          ? mapApiError('UNAUTHORIZED', '')
          : mapApiError('ROOM_NOT_FOUND', '');
      _emitError(StateError(errorMsg));
      return;
    }

    if (!_isReconnecting) {
      _startReconnectLoop(code, token);
    }
  }

  Future<void> _startReconnectLoop(String code, String token) async {
    _isReconnecting = true;
    _setConnectionState(RoomConnectionState.reconnecting);

    var currentBackoff = const Duration(seconds: 1);
    const maxBackoff = Duration(seconds: 5);
    var totalElapsed = Duration.zero;

    while (!_isDisposed &&
        !_isLeaving &&
        _currentRoom?.status != RoomStatus.ended) {
      if (totalElapsed >= maxReconnectDuration) {
        _setConnectionState(RoomConnectionState.lost);
        _emitError(
          StateError(
            'Mất kết nối máy chủ sau ${maxReconnectDuration.inSeconds}s thử lại.',
          ),
        );
        _isReconnecting = false;
        return;
      }

      await _delayFn(currentBackoff);
      totalElapsed += currentBackoff;

      final nextSeconds = (currentBackoff.inSeconds * 2).clamp(
        1,
        maxBackoff.inSeconds,
      );
      currentBackoff = Duration(seconds: nextSeconds);

      if (_isDisposed ||
          _isLeaving ||
          _currentRoom?.status == RoomStatus.ended) {
        _isReconnecting = false;
        return;
      }

      final outcome = await _attemptReconnect(code, token);
      if (outcome == _ReconnectOutcome.success) {
        _isReconnecting = false;
        _setConnectionState(RoomConnectionState.connected);
        return;
      } else if (outcome == _ReconnectOutcome.permanentFailure) {
        _isReconnecting = false;
        _setConnectionState(RoomConnectionState.lost);
        return;
      }
      // retryableFailure tiếp tục vòng lặp
    }

    _isReconnecting = false;
  }

  Future<_ReconnectOutcome> _attemptReconnect(String code, String token) async {
    WebSocketChannel? channel;
    try {
      final uri = Uri.parse('$_wsBaseUrl/rooms/$code/ws?token=$token');
      final factory = wsFactory;
      channel = factory != null ? factory(uri) : WebSocketChannel.connect(uri);

      await channel.ready;

      if (channel.closeCode == 4401 || channel.closeCode == 4404) {
        channel.sink.close();
        final errCode = channel.closeCode == 4401
            ? 'UNAUTHORIZED'
            : 'ROOM_NOT_FOUND';
        _emitError(StateError(mapApiError(errCode, '')));
        return _ReconnectOutcome.permanentFailure;
      }

      final getUri = Uri.parse('$_baseUrl/rooms/$code');
      final res = await _httpClient.get(
        getUri,
        headers: {'authorization': 'Bearer $token'},
      );

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body) as Map<String, dynamic>;
        final now = DateTime.now().millisecondsSinceEpoch;
        final room = Room.fromJson(
          data['room'] as Map<String, dynamic>,
          localNowMs: now,
        );

        // Thay thế hoàn toàn local room state
        _emit(room);

        _wsSubscription?.cancel();
        _wsChannel?.sink.close();
        _wsChannel = channel;

        _listenToSocket(channel, code, token);

        return _ReconnectOutcome.success;
      } else if (res.statusCode == 401 || res.statusCode == 404) {
        channel.sink.close();
        String errCode = res.statusCode == 401
            ? 'UNAUTHORIZED'
            : 'ROOM_NOT_FOUND';
        String errMsg = '';
        try {
          final errBody = jsonDecode(res.body) as Map<String, dynamic>;
          final err = errBody['error'] as Map<String, dynamic>?;
          if (err != null) {
            errCode = err['code'] as String? ?? errCode;
            errMsg = err['message'] as String? ?? '';
          }
        } catch (_) {}

        _emitError(StateError(mapApiError(errCode, errMsg)));
        return _ReconnectOutcome.permanentFailure;
      } else {
        channel.sink.close();
        return _ReconnectOutcome.retryableFailure;
      }
    } catch (_) {
      channel?.sink.close();
      return _ReconnectOutcome.retryableFailure;
    }
  }

  @override
  Future<Room> createRoom({
    required String hostPlayerName,
    int totalPlayers = 3,
  }) async {
    final uri = Uri.parse('$_baseUrl/rooms');
    final res = await _httpClient.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'playerName': hostPlayerName}),
    );

    if (res.statusCode != 201) {
      _handleErrorResponse(res);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final playerId = data['playerId'] as String;
    final token = data['playerToken'] as String;
    final now = DateTime.now().millisecondsSinceEpoch;
    final room = Room.fromJson(
      data['room'] as Map<String, dynamic>,
      localNowMs: now,
    );

    _localPlayerId = playerId;
    _playerToken = token;
    _emit(room);

    _connectWebSocket(room.code, token);
    return room;
  }

  @override
  Future<Room> joinRoom({
    required String code,
    required String playerName,
  }) async {
    final uri = Uri.parse('$_baseUrl/rooms/$code/join');
    final res = await _httpClient.post(
      uri,
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'playerName': playerName}),
    );

    if (res.statusCode != 200) {
      _handleErrorResponse(res);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    final playerId = data['playerId'] as String;
    final token = data['playerToken'] as String;
    final now = DateTime.now().millisecondsSinceEpoch;
    final room = Room.fromJson(
      data['room'] as Map<String, dynamic>,
      localNowMs: now,
    );

    _localPlayerId = playerId;
    _playerToken = token;
    _emit(room);

    _connectWebSocket(room.code, token);
    return room;
  }

  @override
  Stream<Room> watchRoom(String code) {
    final ctrl = _getOrCreateController();
    if (_currentRoom != null && _currentRoom!.code == code) {
      scheduleMicrotask(() {
        if (!_isDisposed && !ctrl.isClosed && _currentRoom != null) {
          ctrl.add(_currentRoom!);
        }
      });
    }
    return ctrl.stream;
  }

  @override
  Future<void> leaveRoom({
    required String code,
    required String playerId,
  }) async {
    _isLeaving = true;
    if (_playerToken == null) return;
    final uri = Uri.parse('$_baseUrl/rooms/$code/leave');
    try {
      await _httpClient.post(
        uri,
        headers: {'authorization': 'Bearer $_playerToken'},
      );
    } finally {
      _wsSubscription?.cancel();
      _wsChannel?.sink.close();
      _wsChannel = null;
      _playerToken = null;
      _currentRoom = null;
      _isLeaving = false;
      _setConnectionState(RoomConnectionState.connected);
    }
  }

  @override
  Future<void> startMatch({
    required String code,
    bool waitForScene = false,
  }) async {
    if (_playerToken == null) {
      throw StateError('Chưa xác thực để bắt đầu trận đấu.');
    }
    final uri = Uri.parse('$_baseUrl/rooms/$code/start');
    final res = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $_playerToken',
        if (waitForScene) 'content-type': 'application/json',
      },
      body: waitForScene ? jsonEncode({'waitForScene': true}) : null,
    );

    if (res.statusCode != 204) {
      _handleErrorResponse(res);
    }
  }

  @override
  Future<void> markSceneReady({
    required String code,
    required String playerId,
    required int preparationId,
  }) async {
    if (_playerToken == null) throw StateError('Chưa xác thực.');
    final response = await _httpClient.post(
      Uri.parse('$_baseUrl/rooms/$code/scene-ready'),
      headers: {
        'authorization': 'Bearer $_playerToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'preparationId': preparationId}),
    );
    if (response.statusCode != 204) _handleErrorResponse(response);
  }

  @override
  Future<void> sendItem({
    required String code,
    required int fromRingIndex,
    required int toRingIndex,
    required GameItem item,
  }) async {
    if (_playerToken == null) throw StateError('Chưa xác thực.');
    final uri = Uri.parse('$_baseUrl/rooms/$code/items/send');
    final res = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $_playerToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'itemId': item.id, 'toRingIndex': toRingIndex}),
    );

    if (res.statusCode != 204) {
      _handleErrorResponse(res);
    }
  }

  @override
  Future<void> trashItem({
    required String code,
    required int ringIndex,
    required String itemId,
  }) async {
    if (_playerToken == null) throw StateError('Chưa xác thực.');
    final uri = Uri.parse('$_baseUrl/rooms/$code/items/trash');
    final res = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $_playerToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'itemId': itemId}),
    );

    if (res.statusCode != 204) {
      _handleErrorResponse(res);
    }
  }

  @override
  Future<GameItem> processItemAtStation({
    required String code,
    required int ringIndex,
    required String itemId,
    required StationType station,
  }) async {
    if (_playerToken == null) throw StateError('Chưa xác thực.');
    final uri = Uri.parse('$_baseUrl/rooms/$code/items/process');
    final res = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $_playerToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'itemId': itemId, 'station': station.name}),
    );

    if (res.statusCode != 200) {
      _handleErrorResponse(res);
    }

    final data = jsonDecode(res.body) as Map<String, dynamic>;
    return GameItem.fromJson(data['item'] as Map<String, dynamic>);
  }

  @override
  Future<void> submitOrder({
    required String code,
    required String playerId,
    required String orderId,
    required String productId,
  }) async {
    if (_playerToken == null) throw StateError('Chưa xác thực.');
    final uri = Uri.parse('$_baseUrl/rooms/$code/orders/submit');
    final res = await _httpClient.post(
      uri,
      headers: {
        'authorization': 'Bearer $_playerToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'orderId': orderId, 'itemId': productId}),
    );

    if (res.statusCode != 204) {
      _handleErrorResponse(res);
    }
  }

  @override
  Future<void> returnToLobby({
    required String code,
    required String playerId,
  }) async {
    // Với backend server, khi người chơi bấm quay lại phòng,
    // cập nhật trạng thái readyInLobby local
    if (_currentRoom != null) {
      final p = _currentRoom!.players[playerId];
      if (p != null) {
        final updated = Map<String, Player>.of(_currentRoom!.players)
          ..[playerId] = p.copyWith(readyInLobby: true);
        _emit(_currentRoom!.copyWith(players: updated));
      }
    }
  }

  @override
  Future<void> endMatch(String code) async {
    // Server tự quản lý việc kết thúc trận khi hết giờ hoặc thiếu người.
  }

  @override
  void dispose() {
    _isDisposed = true;
    _isLeaving = true;
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    _roomStreamController?.close();
    _connectionStateController?.close();
    _httpClient.close();
  }
}
