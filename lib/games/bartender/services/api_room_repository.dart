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
class ApiRoomRepository implements RoomRepository {
  ApiRoomRepository({
    String? baseUrl,
    http.Client? httpClient,
    this.wsFactory,
  })  : _baseUrl = _cleanBaseUrl(baseUrl ?? BartenderConfig.apiBaseUrl),
        _httpClient = httpClient ?? http.Client();

  final String _baseUrl;
  final http.Client _httpClient;
  final WebSocketChannel Function(Uri uri)? wsFactory;

  String _localPlayerId = '';
  String? _playerToken;
  Room? _currentRoom;

  StreamController<Room>? _roomStreamController;
  WebSocketChannel? _wsChannel;
  StreamSubscription<dynamic>? _wsSubscription;
  bool _isDisposed = false;

  @override
  String get localPlayerId => _localPlayerId;

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
    final channel = factory != null ? factory(uri) : WebSocketChannel.connect(uri);
    _wsChannel = channel;

    _wsSubscription = channel.stream.listen(
      (data) {
        try {
          final map = jsonDecode(data as String) as Map<String, dynamic>;
          if (map['type'] == 'snapshot' && map['room'] != null) {
            final now = DateTime.now().millisecondsSinceEpoch;
            final room = Room.fromJson(map['room'] as Map<String, dynamic>, localNowMs: now);
            _emit(room);
          } else if (map['type'] == 'ping') {
            channel.sink.add(jsonEncode({'type': 'pong'}));
          }
        } catch (_) {
          // Bỏ qua tin nhắn không parse được
        }
      },
      onError: (err) {
        // Socket lỗi
      },
      onDone: () {
        // Socket đóng
      },
    );
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
    final room = Room.fromJson(data['room'] as Map<String, dynamic>, localNowMs: now);

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
    final room = Room.fromJson(data['room'] as Map<String, dynamic>, localNowMs: now);

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
    if (_playerToken == null) return;
    final uri = Uri.parse('$_baseUrl/rooms/$code/leave');
    await _httpClient.post(
      uri,
      headers: {'authorization': 'Bearer $_playerToken'},
    );

    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    _wsChannel = null;
    _playerToken = null;
    _currentRoom = null;
  }

  @override
  Future<void> startMatch({required String code}) async {
    if (_playerToken == null) {
      throw StateError('Chưa xác thực để bắt đầu trận đấu.');
    }
    final uri = Uri.parse('$_baseUrl/rooms/$code/start');
    final res = await _httpClient.post(
      uri,
      headers: {'authorization': 'Bearer $_playerToken'},
    );

    if (res.statusCode != 204) {
      _handleErrorResponse(res);
    }
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
      body: jsonEncode({
        'itemId': item.id,
        'toRingIndex': toRingIndex,
      }),
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
      body: jsonEncode({
        'itemId': itemId,
        'station': station.name,
      }),
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
      body: jsonEncode({
        'orderId': orderId,
        'itemId': productId,
      }),
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
    _wsSubscription?.cancel();
    _wsChannel?.sink.close();
    _roomStreamController?.close();
    _httpClient.close();
  }
}
