import 'dart:async';
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:nhom_bar/games/bartender/models/game_item.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/models/station.dart';
import 'package:nhom_bar/games/bartender/services/api_room_repository.dart';
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

  FakeWebSocketChannel(Stream<dynamic> stream, StreamSink<dynamic> sink)
      : _stream = stream,
        _sink = _FakeWebSocketSink(sink);

  @override
  Stream get stream => _stream;

  @override
  WebSocketSink get sink => _sink;

  @override
  int? get closeCode => null;

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
                  'readyInLobby': true,
                }
              },
              'timer': null,
              'currentRound': null,
              'inbox': {},
              'results': null,
            }
          }),
          201,
          headers: {'content-type': 'application/json'},
        );
      });

      final repo = ApiRoomRepository(
        baseUrl: 'http://localhost:8080',
        httpClient: mockHttp,
        wsFactory: fakeWsFactory,
      );

      final room = await repo.createRoom(hostPlayerName: 'Alex');
      expect(room.code, '8888');
      expect(room.status, RoomStatus.lobby);
      expect(repo.localPlayerId, 'p_0');
      expect(repo.playerToken, 'tok_123');

      // WebSocket receives a snapshot from server
      final watchExpectation = expectLater(
        repo.watchRoom('8888'),
        emitsThrough(predicate<Room>((r) => r.status == RoomStatus.playing)),
      );

      fakeWsServerToClient.add(jsonEncode({
        'type': 'snapshot',
        'room': {
          'code': '8888',
          'status': 'playing',
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
          'timer': {'startedAt': 1760000000000, 'endTime': 1760000060000},
          'currentRound': {
            'number': 1,
            'ordersPerPlayer': 3,
            'stationAssignment': {'0': 'juicer'},
            'progress': {'0': 0},
            'playerOrders': {},
          },
          'inbox': {},
          'results': null,
        }
      }));

      await watchExpectation;
      repo.dispose();
    });

    test('error response mapping maps contract error codes to Vietnamese messages', () async {
      expect(
        ApiRoomRepository.mapApiError('ROOM_NOT_FOUND', 'Room not found'),
        'Phòng chơi không tồn tại.',
      );
      expect(
        ApiRoomRepository.mapApiError('ROOM_FULL', 'Full'),
        'Phòng đã đủ 4 người chơi.',
      );
      expect(
        ApiRoomRepository.mapApiError('NOT_ENOUGH_PLAYERS', 'Need 2'),
        'Cần ít nhất 2 người chơi kết nối để bắt đầu.',
      );
      expect(
        ApiRoomRepository.mapApiError('INVALID_MOVE', 'Not adjacent'),
        'Nước đi không hợp lệ (không liền kề hoặc sai trạm chế biến).',
      );
      expect(
        ApiRoomRepository.mapApiError('ORDER_MISMATCH', 'Wrong recipe'),
        'Món ăn không khớp với đơn hàng hoặc đơn đã nộp.',
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
  });
}
