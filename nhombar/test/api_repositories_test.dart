import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/core/api/api_client.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/services/api_room_repository.dart';
import 'package:nhom_bar/games/rubik/challenge/models/rubik_room.dart';
import 'package:nhom_bar/games/rubik/challenge/services/api_rubik_challenge_service.dart';

void main() {
  late Process backend;
  late String baseUrl;
  setUpAll(() async {
    backend = await Process.start('node', [
      '-e',
      'const {createServer}=require("./src/server");'
          'const {Store}=require("./src/store");'
          'const s=createServer({store:new Store()});'
          's.listen(0,"127.0.0.1",()=>console.log(s.address().port));',
    ], workingDirectory: Directory('../backend').absolute.path);
    backend.stderr.drain<void>();
    final port = await backend.stdout
        .transform(utf8.decoder)
        .transform(const LineSplitter())
        .first
        .timeout(const Duration(seconds: 15));
    baseUrl = 'http://127.0.0.1:$port/api/v1';
  });
  tearDownAll(() async {
    backend.kill();
    await backend.exitCode;
  });

  test(
    'real HTTP Bartender adapters decode rooms, timer, round and results',
    () async {
      final a = ApiRoomRepository(client: ApiClient(baseUrl: baseUrl));
      final b = ApiRoomRepository(client: ApiClient(baseUrl: baseUrl));
      addTearDown(a.dispose);
      addTearDown(b.dispose);
      final created = await a.createRoom(hostPlayerName: 'A');
      expect(created.status, RoomStatus.lobby);
      expect(created.players.keys, contains(a.localPlayerId));
      final joined = await b.joinRoom(code: created.code, playerName: 'B');
      expect(joined.players.length, 2);
      await a.startMatch(code: created.code);
      final playing = await a.watchRoom(created.code).first;
      expect(playing.status, RoomStatus.playing);
      expect(playing.currentRound!.playerOrders[a.localPlayerId]!.length, 3);
      expect(playing.timer!.endTime - playing.timer!.startedAt, 60000);
      expect(playing.itemsAtRing(0), isNotEmpty);
      await b.leaveRoom(code: created.code, playerId: b.localPlayerId);
      final ended = await a.watchRoom(created.code).first;
      expect(ended.status, RoomStatus.ended);
      expect(ended.results!.ranking.length, 2);
    },
  );

  test('real HTTP Rubik adapters share room, scramble and countdown', () async {
    final a = ApiRubikChallengeRepository(client: ApiClient(baseUrl: baseUrl));
    final b = ApiRubikChallengeRepository(client: ApiClient(baseUrl: baseUrl));
    addTearDown(a.dispose);
    addTearDown(b.dispose);
    final code = await a.create('A');
    await b.join(code, 'B');
    expect(
      (await a.watch(code).first)!.players.keys,
      containsAll([a.uid, b.uid]),
    );
    await a.send(code, 1, 'ready');
    await b.send(code, 1, 'ready');
    expect((await b.watch(code).first)!.scramble.length, 20);
    await a.send(code, 1, 'loaded');
    await b.send(code, 1, 'loaded');
    final room = (await a.watch(code).first)!;
    expect(room.status, ChallengeStatus.countdown);
    expect(room.startAt, greaterThan(a.serverNow));
    expect(room.creationId, isNotEmpty);
  });
}
