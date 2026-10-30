import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';
import 'package:nhom_bar/games/bartender/services/api_room_repository.dart';
import 'package:nhom_bar/games/bartender/services/room_repository.dart';
import 'package:stream_channel/stream_channel.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

class _FakeWebSocketSink implements WebSocketSink {
  final StreamSink<dynamic> _inner;
  _FakeWebSocketSink(this._inner);

  @override
  void add(dynamic data) => _inner.add(data);
  @override
  void addError(Object error, [StackTrace? stackTrace]) =>
      _inner.addError(error, stackTrace);
  @override
  Future addStream(Stream<dynamic> stream) => _inner.addStream(stream);
  @override
  Future close([int? closeCode, String? closeReason]) => _inner.close();
  @override
  Future get done => _inner.done;
}

class FakeWebSocketChannel extends StreamChannelMixin
    implements WebSocketChannel {
  final Stream<dynamic> _stream;
  final _FakeWebSocketSink _sink;
  @override
  final int? closeCode;

  FakeWebSocketChannel(
    Stream<dynamic> stream,
    StreamSink<dynamic> sink, {
    this.closeCode,
  })  : _stream = stream,
        _sink = _FakeWebSocketSink(sink);

  @override
  Stream get stream => _stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  String? get closeReason => null;

  @override
  String? get protocol => null;

  @override
  Future<void> get ready => Future.value();
}

void main() {
  group('ApiRoomRepository', () {
    late StreamController<dynamic> fakeWsServerToClient;
    late StreamController<dynamic> fakeWsClientToServer;

    setUp(() {
      fakeWsServerToClient = StreamController<dynamic>.broadcast();
      fakeWsClientToServer = StreamController<dynamic>.broadcast();
    });

    tearDown(() {
      fakeWsServerToClient.close();
      fakeWsClientToServer.close();
    });

    WebSocketChannel fakeWsFactory(Uri uri) {
      return FakeWebSocketChannel(
        fakeWsServerToClient.stream,
        fakeWsClientToServer.sink,
      );
    }

    test('createRoom sends POST /rooms and connects WebSocket', () async {
      final mockHttp = MockClient((request) async {
        expect(request.method, 'POST');
        expect(request.url.path, '/rooms');
        final body = jsonDecode(request.body) as Map<String, dynamic>;
        expect(body['playerName'], 'Alex');

        return http.Response(
          jsonEncode({
            'playerId': 'p_0',
            'playerToken': 'tok_123',
            'room': {
              'code': '8888',
              'status': 'lobby',
              'serverNowMs': 1760000000000,
              'players': {
                'p_0': {
                  'id': 'p_0',
                  'name': 'Alex',
                  'ringIndex': 0,
                  'connected': true,
                  'completedOrders': 0,
                }
              },
            }
          }),
          201,
        );
      });

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: fakeWsFactory,
      );

      final room = await repo.createRoom(hostPlayerName: 'Alex');
      expect(room.code, '8888');
      expect(repo.localPlayerId, 'p_0');
      expect(repo.playerToken, 'tok_123');

      // Test WebSocket snapshot parsing
      final completer = Completer<Room>();
      final sub = repo.watchRoom('8888').listen((r) {
        if (r.status == RoomStatus.playing) completer.complete(r);
      });

      fakeWsServerToClient.add(jsonEncode({
        'type': 'snapshot',
        'room': {
          'code': '8888',
          'status': 'playing',
          'serverNowMs': 1760000001000,
          'players': {
            'p_0': {
              'id': 'p_0',
              'name': 'Alex',
              'ringIndex': 0,
              'connected': true,
              'completedOrders': 0,
            }
          },
          'currentRound': {
            'number': 1,
            'ordersPerPlayer': 3,
            'stationAssignment': {'0': 'blender'},
            'progress': {'0': 0},
            'playerOrders': {'p_0': []},
          }
        }
      }));

      final received = await completer.future.timeout(const Duration(seconds: 1));
      expect(received.status, RoomStatus.playing);
      expect(received.currentRound?.number, 1);

      await sub.cancel();
      repo.dispose();
    });

    test('error response mapping maps contract error codes to Vietnamese messages', () {
      expect(
        ApiRoomRepository.mapApiError('UNAUTHORIZED', 'Default'),
        contains('Không có quyền truy cập'),
      );
      expect(
        ApiRoomRepository.mapApiError('ROOM_NOT_FOUND', 'Room not found'),
        contains('không tồn tại'),
      );
      expect(
        ApiRoomRepository.mapApiError('ROOM_FULL', 'Full'),
        contains('đã đủ 4 người chơi'),
      );
      expect(
        ApiRoomRepository.mapApiError('NOT_ENOUGH_PLAYERS', 'Need 2'),
        contains('ít nhất 2 người'),
      );
      expect(
        ApiRoomRepository.mapApiError('INVALID_MOVE', 'Not adjacent'),
        contains('không hợp lệ'),
      );
      expect(
        ApiRoomRepository.mapApiError('ORDER_MISMATCH', 'Wrong recipe'),
        contains('không khớp với đơn'),
      );
    });

    test('processItemAtStation sends request and returns processed item', () async {
      final mockHttp = MockClient((request) async {
        if (request.url.path == '/rooms') {
          return http.Response(
            jsonEncode({
              'playerId': 'p_0',
              'playerToken': 'tok_host',
              'room': {
                'code': '1111',
                'status': 'lobby',
                'players': {},
              }
            }),
            201,
          );
        }

        if (request.url.path == '/rooms/1111/items/process') {
          expect(request.headers['authorization'], 'Bearer tok_host');
          final body = jsonDecode(request.body) as Map<String, dynamic>;
          expect(body['itemId'], 'item_orange');
          expect(body['station'], 'juicer');

          return http.Response(
            jsonEncode({
              'item': {
                'id': 'item_orange',
                'type': 'product',
                'itemId': 'orange_juice',
                'fromRingIndex': 0,
              }
            }),
            200,
          );
        }

        return http.Response('Not Found', 404);
      });

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: fakeWsFactory,
      );

      await repo.createRoom(hostPlayerName: 'Host');
      final processed = await repo.processItemAtStation(
        code: '1111',
        ringIndex: 0,
        itemId: 'item_orange',
        station: StationType.juicer,
      );

      expect(processed.id, 'item_orange');
      expect(processed.type, GameItemType.product);
      expect(processed.itemId, 'orange_juice');
      repo.dispose();
    });

    test('drop and restore connection recovers stream with full snapshot and emits correct state sequence', () async {
      final ws1ServerToClient = StreamController<dynamic>.broadcast();
      final ws1ClientToServer = StreamController<dynamic>.broadcast();

      final ws2ServerToClient = StreamController<dynamic>.broadcast();
      final ws2ClientToServer = StreamController<dynamic>.broadcast();

      var connectCount = 0;
      WebSocketChannel testWsFactory(Uri uri) {
        connectCount++;
        if (connectCount == 1) {
          return FakeWebSocketChannel(
            ws1ServerToClient.stream,
            ws1ClientToServer.sink,
          );
        } else {
          return FakeWebSocketChannel(
            ws2ServerToClient.stream,
            ws2ClientToServer.sink,
          );
        }
      }

      var getRoomCalled = 0;
      final mockHttp = MockClient((request) async {
        if (request.url.path == '/rooms' && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'playerId': 'p_0',
              'playerToken': 'tok_reconnect',
              'room': {
                'code': '7777',
                'status': 'lobby',
                'serverNowMs': 1760000000000,
                'players': {
                  'p_0': {
                    'id': 'p_0',
                    'name': 'Bob',
                    'ringIndex': 0,
                    'connected': true,
                    'completedOrders': 0,
                  }
                },
              }
            }),
            201,
          );
        }

        if (request.url.path == '/rooms/7777' && request.method == 'GET') {
          getRoomCalled++;
          expect(request.headers['authorization'], 'Bearer tok_reconnect');
          return http.Response(
            jsonEncode({
              'room': {
                'code': '7777',
                'status': 'playing',
                'serverNowMs': 1760000005000,
                'players': {
                  'p_0': {
                    'id': 'p_0',
                    'name': 'Bob',
                    'ringIndex': 0,
                    'connected': true,
                    'completedOrders': 1,
                  }
                },
                'currentRound': {
                  'number': 1,
                  'ordersPerPlayer': 3,
                  'stationAssignment': {'0': 'juicer'},
                  'progress': {'0': 1},
                  'playerOrders': {'p_0': []},
                }
              }
            }),
            200,
          );
        }

        return http.Response('Not Found', 404);
      });

      final connectionStates = <RoomConnectionState>[];
      final receivedRooms = <Room>[];

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: testWsFactory,
        delayFn: (d) async {}, // Delay chạy ngay tức thì trong test
      );

      final stateSub = repo.watchConnectionState().listen(connectionStates.add);
      final initialRoom = await repo.createRoom(hostPlayerName: 'Bob');
      final roomSub = repo.watchRoom('7777').listen(receivedRooms.add);

      expect(repo.connectionState, RoomConnectionState.connected);
      expect(initialRoom.status, RoomStatus.lobby);

      // Mô phỏng socket 1 bị đóng đột ngột (drop connection)
      await ws1ServerToClient.close();

      // Đợi microtask hoàn thành việc reconnect
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(connectCount, 2, reason: 'Phải kết nối lại socket lần 2');
      expect(getRoomCalled, 1, reason: 'Sau khi nối lại socket phải gọi GET /rooms/7777 một lần');
      expect(repo.connectionState, RoomConnectionState.connected);
      expect(connectionStates, contains(RoomConnectionState.reconnecting));

      // Kiểm tra snapshot từ GET /rooms/7777 đã thay thế local state
      expect(receivedRooms.isNotEmpty, isTrue);
      expect(receivedRooms.last.status, RoomStatus.playing);
      expect(receivedRooms.last.currentRound?.number, 1);

      // Thử phát tiếp snapshot qua socket 2 để chứng minh stream tiếp tục hoạt động
      ws2ServerToClient.add(jsonEncode({
        'type': 'snapshot',
        'room': {
          'code': '7777',
          'status': 'ended',
          'serverNowMs': 1760000010000,
          'players': {
            'p_0': {
              'id': 'p_0',
              'name': 'Bob',
              'ringIndex': 0,
              'connected': true,
              'completedOrders': 2,
            }
          },
        }
      }));

      await Future<void>.delayed(const Duration(milliseconds: 50));
      expect(receivedRooms.last.status, RoomStatus.ended);

      await stateSub.cancel();
      await roomSub.cancel();
      repo.dispose();
      await ws1ClientToServer.close();
      await ws2ServerToClient.close();
      await ws2ClientToServer.close();
    });

    test('reconnect stops immediately and marks lost if server answers UNAUTHORIZED on GET', () async {
      final ws1ServerToClient = StreamController<dynamic>.broadcast();
      final ws1ClientToServer = StreamController<dynamic>.broadcast();
      final ws2ServerToClient = StreamController<dynamic>.broadcast();
      final ws2ClientToServer = StreamController<dynamic>.broadcast();

      var connectCount = 0;
      WebSocketChannel testWsFactory(Uri uri) {
        connectCount++;
        if (connectCount == 1) {
          return FakeWebSocketChannel(
            ws1ServerToClient.stream,
            ws1ClientToServer.sink,
          );
        } else {
          return FakeWebSocketChannel(
            ws2ServerToClient.stream,
            ws2ClientToServer.sink,
          );
        }
      }

      final mockHttp = MockClient((request) async {
        if (request.url.path == '/rooms' && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'playerId': 'p_0',
              'playerToken': 'tok_bad',
              'room': {
                'code': '3333',
                'status': 'lobby',
                'players': {},
              }
            }),
            201,
          );
        }

        if (request.url.path == '/rooms/3333' && request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'UNAUTHORIZED',
                'message': 'Token không hợp lệ.',
              }
            }),
            401,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return http.Response('Not Found', 404);
      });

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: testWsFactory,
        delayFn: (d) async {},
      );

      final connectionStates = <RoomConnectionState>[];
      final stateSub = repo.watchConnectionState().listen(connectionStates.add);

      Object? streamError;
      final roomSub = repo.watchRoom('3333').listen((_) {}, onError: (err) {
        streamError = err;
      });

      await repo.createRoom(hostPlayerName: 'Alice');

      // Drop socket
      await ws1ServerToClient.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.connectionState, RoomConnectionState.lost);
      expect(connectionStates.last, RoomConnectionState.lost);
      expect(streamError, isNotNull);
      expect(streamError.toString(), contains('Không có quyền truy cập'));

      await stateSub.cancel();
      await roomSub.cancel();
      repo.dispose();
      await ws1ClientToServer.close();
      await ws2ServerToClient.close();
      await ws2ClientToServer.close();
    });

    test('reconnect stops immediately and marks lost if server answers ROOM_NOT_FOUND on GET', () async {
      final ws1ServerToClient = StreamController<dynamic>.broadcast();
      final ws1ClientToServer = StreamController<dynamic>.broadcast();
      final ws2ServerToClient = StreamController<dynamic>.broadcast();
      final ws2ClientToServer = StreamController<dynamic>.broadcast();

      var connectCount = 0;
      WebSocketChannel testWsFactory(Uri uri) {
        connectCount++;
        if (connectCount == 1) {
          return FakeWebSocketChannel(
            ws1ServerToClient.stream,
            ws1ClientToServer.sink,
          );
        } else {
          return FakeWebSocketChannel(
            ws2ServerToClient.stream,
            ws2ClientToServer.sink,
          );
        }
      }

      final mockHttp = MockClient((request) async {
        if (request.url.path == '/rooms' && request.method == 'POST') {
          return http.Response(
            jsonEncode({
              'playerId': 'p_0',
              'playerToken': 'tok_deleted_room',
              'room': {
                'code': '4444',
                'status': 'lobby',
                'players': {},
              }
            }),
            201,
          );
        }

        if (request.url.path == '/rooms/4444' && request.method == 'GET') {
          return http.Response(
            jsonEncode({
              'error': {
                'code': 'ROOM_NOT_FOUND',
                'message': 'Phòng đã bị xóa.',
              }
            }),
            404,
            headers: {'content-type': 'application/json; charset=utf-8'},
          );
        }

        return http.Response('Not Found', 404);
      });

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: testWsFactory,
        delayFn: (d) async {},
      );

      final connectionStates = <RoomConnectionState>[];
      final stateSub = repo.watchConnectionState().listen(connectionStates.add);

      Object? streamError;
      final roomSub = repo.watchRoom('4444').listen((_) {}, onError: (err) {
        streamError = err;
      });

      await repo.createRoom(hostPlayerName: 'Carol');

      // Drop socket
      await ws1ServerToClient.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.connectionState, RoomConnectionState.lost);
      expect(streamError, isNotNull);
      expect(streamError.toString(), contains('không tồn tại'));

      await stateSub.cancel();
      await roomSub.cancel();
      repo.dispose();
      await ws1ClientToServer.close();
      await ws2ServerToClient.close();
      await ws2ClientToServer.close();
    });

    test('exponential backoff tracks delays and transitions to lost upon reaching maxReconnectDuration', () async {
      final ws1ServerToClient = StreamController<dynamic>.broadcast();
      final ws1ClientToServer = StreamController<dynamic>.broadcast();

      WebSocketChannel testWsFactory(Uri uri) {
        // Sau lần 1, các lần sau đều ném lỗi
        if (!ws1ServerToClient.isClosed) {
          return FakeWebSocketChannel(
            ws1ServerToClient.stream,
            ws1ClientToServer.sink,
          );
        }
        throw StateError('Connection refused');
      }

      final mockHttp = MockClient((request) async {
        return http.Response(
          jsonEncode({
            'playerId': 'p_0',
            'playerToken': 'tok_timeout',
            'room': {
              'code': '5555',
              'status': 'playing',
              'players': {},
            }
          }),
          201,
        );
      });

      final capturedDelays = <Duration>[];
      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: testWsFactory,
        maxReconnectDuration: const Duration(seconds: 7),
        delayFn: (d) async {
          capturedDelays.add(d);
        },
      );

      await repo.createRoom(hostPlayerName: 'TimeoutTest');

      // Drop socket
      await ws1ServerToClient.close();
      await Future<void>.delayed(const Duration(milliseconds: 50));

      expect(repo.connectionState, RoomConnectionState.lost);
      // Backoff chu kỳ: 1s, 2s, 4s (tổng = 7s >= 7s maxReconnectDuration)
      expect(capturedDelays, [
        const Duration(seconds: 1),
        const Duration(seconds: 2),
        const Duration(seconds: 4),
      ]);

      repo.dispose();
      await ws1ClientToServer.close();
    });
  });
}
