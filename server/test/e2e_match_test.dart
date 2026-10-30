import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';

import '../src/app_router.dart';
import '../src/room_service.dart';

void main() {
  group('E2E Multiplayer Match over HTTP & WebSocket', () {
    late HttpServer server;
    late RoomService roomService;
    late String baseUrl;
    late String wsBaseUrl;

    setUp(() async {
      roomService = RoomService(enableTimers: false);
      final handler = createAppHandler(roomService);
      server = await io.serve(handler, InternetAddress.loopbackIPv4, 0);
      baseUrl = 'http://localhost:${server.port}';
      wsBaseUrl = 'ws://localhost:${server.port}';
    });

    tearDown(() async {
      roomService.dispose();
      await server.close(force: true);
    });

    test('2 simulated players complete full match cycle', () async {
      // 1. Host creates room
      final createRes = await http.post(
        Uri.parse('$baseUrl/rooms'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'playerName': 'Player 1'}),
      );
      expect(createRes.statusCode, 201);
      final createData = jsonDecode(createRes.body) as Map<String, dynamic>;
      final code = (createData['room'] as Map<String, dynamic>)['code'] as String;
      final hostToken = createData['playerToken'] as String;
      expect(createData['playerId'], 'p_0');

      // 2. Guest joins room
      final joinRes = await http.post(
        Uri.parse('$baseUrl/rooms/$code/join'),
        headers: {'content-type': 'application/json'},
        body: jsonEncode({'playerName': 'Player 2'}),
      );
      expect(joinRes.statusCode, 200);
      final joinData = jsonDecode(joinRes.body) as Map<String, dynamic>;
      final guestToken = joinData['playerToken'] as String;
      expect(joinData['playerId'], 'p_1');

      // 3. Connect WebSockets
      final hostChannel = IOWebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/rooms/$code/ws?token=$hostToken'),
      );
      final guestChannel = IOWebSocketChannel.connect(
        Uri.parse('$wsBaseUrl/rooms/$code/ws?token=$guestToken'),
      );

      final hostSnapshots = StreamController<Map<String, dynamic>>.broadcast();
      final guestSnapshots = StreamController<Map<String, dynamic>>.broadcast();

      final sub1 = hostChannel.stream.listen((msg) {
        final parsed = jsonDecode(msg as String) as Map<String, dynamic>;
        if (parsed['type'] == 'snapshot') {
          hostSnapshots.add(parsed['room'] as Map<String, dynamic>);
        }
      });

      final sub2 = guestChannel.stream.listen((msg) {
        final parsed = jsonDecode(msg as String) as Map<String, dynamic>;
        if (parsed['type'] == 'snapshot') {
          guestSnapshots.add(parsed['room'] as Map<String, dynamic>);
        }
      });

      // Receive initial lobby snapshots
      final hostInitial = await hostSnapshots.stream.first;
      expect(hostInitial['status'], 'lobby');
      expect((hostInitial['players'] as Map).length, 2);

      // 4. Host starts match
      final startRes = await http.post(
        Uri.parse('$baseUrl/rooms/$code/start'),
        headers: {'authorization': 'Bearer $hostToken'},
      );
      expect(startRes.statusCode, 204);

      // Both receive playing snapshot
      final playingSnap = await hostSnapshots.stream.firstWhere(
        (s) => s['status'] == 'playing',
      );
      expect(playingSnap['currentRound'], isNotNull);
      expect(playingSnap['currentRound']['number'], 1);
      expect(playingSnap['inbox']['0'], isNotEmpty);
      expect(playingSnap['inbox']['1'], isNotEmpty);

      // 5. Host sends an item to guest (0 -> 1)
      final hostItem = (playingSnap['inbox']['0'] as List).first as Map<String, dynamic>;
      final sendRes = await http.post(
        Uri.parse('$baseUrl/rooms/$code/items/send'),
        headers: {
          'authorization': 'Bearer $hostToken',
          'content-type': 'application/json',
        },
        body: jsonEncode({
          'itemId': hostItem['id'],
          'toRingIndex': 1,
        }),
      );
      expect(sendRes.statusCode, 204);

      // Guest observes item in their inbox
      final sendSnap = await guestSnapshots.stream.firstWhere((s) {
        final guestInbox = s['inbox']['1'] as List;
        return guestInbox.any((it) => it['id'] == hostItem['id']);
      });
      expect(sendSnap['inbox']['1'], isNotEmpty);

      // 6. Guest trashes an item
      final trashItem = (sendSnap['inbox']['1'] as List).first as Map<String, dynamic>;
      final trashRes = await http.post(
        Uri.parse('$baseUrl/rooms/$code/items/trash'),
        headers: {
          'authorization': 'Bearer $guestToken',
          'content-type': 'application/json',
        },
        body: jsonEncode({'itemId': trashItem['id']}),
      );
      expect(trashRes.statusCode, 204);

      // 7. GET room check
      final getRes = await http.get(
        Uri.parse('$baseUrl/rooms/$code'),
        headers: {'authorization': 'Bearer $hostToken'},
      );
      expect(getRes.statusCode, 200);
      final roomData = jsonDecode(getRes.body)['room'] as Map<String, dynamic>;
      expect(roomData['code'], code);
      expect(roomData['status'], 'playing');

      // 8. Player 2 leaves -> ends match (< 2 connected)
      final leaveRes = await http.post(
        Uri.parse('$baseUrl/rooms/$code/leave'),
        headers: {'authorization': 'Bearer $guestToken'},
      );
      expect(leaveRes.statusCode, 204);

      // Host receives ended snapshot with results
      final endedSnap = await hostSnapshots.stream.firstWhere(
        (s) => s['status'] == 'ended',
      );
      expect(endedSnap['results'], isNotNull);
      expect(endedSnap['results']['ranking'], isNotEmpty);

      // Cleanup
      await sub1.cancel();
      await sub2.cancel();
      await hostChannel.sink.close();
      await guestChannel.sink.close();
      await hostSnapshots.close();
      await guestSnapshots.close();
    });
  });
}
