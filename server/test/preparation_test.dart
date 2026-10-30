import 'dart:convert';
import 'dart:async';
import 'dart:io';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:test/test.dart';
import 'package:web_socket_channel/io.dart';
import '../src/room_service.dart';
import '../src/app_router.dart';
import '../src/exceptions.dart';

void main() {
  test(
      'two WebSocket clients receive the same authoritative start after the last ready',
      () async {
    var now = 100000;
    final service = RoomService(enableTimers: false, nowMs: () => now);
    final server = await io.serve(
        createAppHandler(service), InternetAddress.loopbackIPv4, 0);
    addTearDown(() async {
      service.dispose();
      await server.close(force: true);
    });
    final host = service.createRoom(playerName: 'Host');
    final code = host.room.code;
    final peer = service.joinRoom(code: code, playerName: 'Peer');
    final channels = [
      for (final token in [host.playerToken, peer.playerToken])
        IOWebSocketChannel.connect(Uri.parse(
            'ws://localhost:${server.port}/rooms/$code/ws?token=$token'))
    ];
    final streams = [
      for (final channel in channels) StreamIterator(channel.stream)
    ];
    addTearDown(() async {
      for (final stream in streams) {
        await stream.cancel();
      }
      for (final channel in channels) {
        await channel.sink.close();
      }
    });
    Future<Map<String, dynamic>> nextRoom(StreamIterator stream) async {
      expect(
          await stream.moveNext().timeout(const Duration(seconds: 5)), isTrue);
      return jsonDecode(stream.current as String)['room']
          as Map<String, dynamic>;
    }

    for (final stream in streams) {
      expect((await nextRoom(stream))['status'], 'lobby');
    }
    service.startMatch(code: code, token: host.playerToken, waitForScene: true);
    var prep = 0;
    for (final stream in streams) {
      final room = await nextRoom(stream);
      expect(room['timer']['preparing'], isTrue);
      prep = room['timer']['startedAt'] as int;
    }
    service.markSceneReady(
        code: code, token: host.playerToken, preparationId: prep);
    for (final stream in streams) {
      expect((await nextRoom(stream))['timer']['preparing'], isTrue);
    }
    now += 90000;
    service.markSceneReady(
        code: code, token: peer.playerToken, preparationId: prep);
    final one = await nextRoom(streams[0]);
    final two = await nextRoom(streams[1]);
    expect(one['timer'], two['timer']);
    expect(one['serverNowMs'], now);
    expect(two['serverNowMs'], now);
    expect(one['timer']['startedAt'], now + 3000);
    expect(one['timer']['endTime'], now + 63000);
  });

  test('a disconnected slow peer does not block two remaining ready players',
      () {
    var now = 100000;
    final service = RoomService(enableTimers: false, nowMs: () => now);
    addTearDown(service.dispose);
    final host = service.createRoom(playerName: 'Host');
    final code = host.room.code;
    final peer = service.joinRoom(code: code, playerName: 'Ready');
    final slow = service.joinRoom(code: code, playerName: 'Slow');
    service.startMatch(code: code, token: host.playerToken, waitForScene: true);
    final prep =
        service.getRoom(code: code, token: host.playerToken).timer!.startedAt;
    for (final token in [host.playerToken, peer.playerToken]) {
      service.markSceneReady(code: code, token: token, preparationId: prep);
    }
    expect(
        service.getRoom(code: code, token: host.playerToken).timer!.isPreparing,
        isTrue);
    now += 90000;
    service.leaveRoom(code: code, token: slow.playerToken);
    final timer = service.getRoom(code: code, token: host.playerToken).timer!;
    expect(timer.isPreparing, isFalse);
    expect(timer.startedAt, now + 3000);
    expect(timer.endTime, now + 63000);
  });

  test(
      'authenticated ready barrier waits for every peer and guards actions until the shared start',
      () async {
    var now = 100000;
    final service = RoomService(enableTimers: false, nowMs: () => now);
    addTearDown(service.dispose);
    final host = service.createRoom(playerName: 'Host');
    final peer = service.joinRoom(code: host.room.code, playerName: 'Peer');
    final code = host.room.code;
    final app = createAppHandler(service);
    final start = await app(
        Request('POST', Uri.parse('http://localhost/rooms/$code/start'),
            headers: {
              'authorization': 'Bearer ${host.playerToken}',
              'content-type': 'application/json'
            },
            body: jsonEncode({'waitForScene': true})));
    expect(start.statusCode, 204);
    final preparing = service.getRoom(code: code, token: host.playerToken);
    final prep = preparing.timer!.startedAt;
    final item = preparing.inbox[0]!.first;
    service.markSceneReady(
        code: code, token: host.playerToken, preparationId: prep);
    now += 90000;
    expect(
        service
            .getRoom(code: code, token: host.playerToken)
            .timer!
            .remainingMs(nowMs: now),
        60000);
    expect(
        () => service.trashItem(
            code: code, token: host.playerToken, itemId: item.id),
        throwsA(isA<ApiException>()));
    service.markSceneReady(
        code: code, token: peer.playerToken, preparationId: prep - 1);
    expect(
        service.getRoom(code: code, token: host.playerToken).timer!.isPreparing,
        isTrue);
    final forbidden = await app(Request(
        'POST', Uri.parse('http://localhost/rooms/$code/scene-ready'),
        headers: {
          'authorization': 'Bearer invalid',
          'content-type': 'application/json'
        },
        body: jsonEncode({'preparationId': prep})));
    expect(forbidden.statusCode, 401);
    final ready = await app(
        Request('POST', Uri.parse('http://localhost/rooms/$code/scene-ready'),
            headers: {
              'authorization': 'Bearer ${peer.playerToken}',
              'content-type': 'application/json'
            },
            body: jsonEncode({'preparationId': prep})));
    expect(ready.statusCode, 204);
    final clock = service.getRoom(code: code, token: host.playerToken).timer!;
    expect(clock.startedAt, now + 3000);
    expect(clock.endTime, now + 63000);
    expect(
        () => service.trashItem(
            code: code, token: host.playerToken, itemId: item.id),
        throwsA(isA<ApiException>()));
    now += 3000;
    service.trashItem(code: code, token: host.playerToken, itemId: item.id);
    expect(
        service.getRoom(code: code, token: host.playerToken).inbox[0], isEmpty);
    service.markSceneReady(
        code: code, token: peer.playerToken, preparationId: prep);
    expect(service.getRoom(code: code, token: host.playerToken).timer!.endTime,
        clock.endTime);
  });
}
