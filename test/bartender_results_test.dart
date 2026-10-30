import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:nhom_bar/games/bartender/controllers/bartender_controller.dart';
import 'package:nhom_bar/games/bartender/models/match_result.dart';
import 'package:nhom_bar/games/bartender/models/player.dart';
import 'package:nhom_bar/games/bartender/models/room.dart';
import 'package:nhom_bar/games/bartender/screens/bartender_results_screen.dart';
import 'package:nhom_bar/games/bartender/services/fake_room_repository.dart';

void main() {
  group('BartenderResultsScreen Widget Tests', () {
    testWidgets('hiển thị trạng thái đang tải kết quả khi results == null',
        (tester) async {
      final repo = FakeRoomRepository();
      final ctrl = BartenderController(repository: repo);
      addTearDown(ctrl.dispose);

      await ctrl.createRoom(playerName: 'Player1', totalPlayers: 2);
      await tester.pump(const Duration(seconds: 4));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BartenderResultsScreen(controller: ctrl),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Ban đầu room status là lobby, results null
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.textContaining('Đang tải kết quả'), findsOneWidget);
      expect(find.byKey(const Key('back-to-lobby-button')), findsOneWidget);

      // Bấm nút quay về lobby
      await tester.tap(find.byKey(const Key('back-to-lobby-button')));
      await tester.pump(const Duration(seconds: 4));

      expect(ctrl.room, isNull);
    });

    testWidgets(
        'hiển thị đúng dữ liệu results theo API.md (xếp hạng, số đơn, tổng đơn, thời gian sống sót)',
        (tester) async {
      final repo = FakeRoomRepository();
      final ctrl = BartenderController(repository: repo);
      addTearDown(ctrl.dispose);

      await ctrl.createRoom(playerName: 'Alice', totalPlayers: 3);
      await tester.pump(const Duration(seconds: 4));

      final p1 = Player(
        id: ctrl.myPlayerId!,
        name: 'Alice',
        ringIndex: 0,
        connected: true,
        completedOrders: 5,
      );
      final p2 = const Player(
        id: 'bot_1',
        name: 'Bob',
        ringIndex: 1,
        connected: true,
        completedOrders: 3,
      );
      final p3 = const Player(
        id: 'bot_2',
        name: 'Charlie',
        ringIndex: 2,
        connected: true,
        completedOrders: 1,
      );

      final matchResult = MatchResult.fromPlayers(
        players: [p1, p2, p3],
        survivalSeconds: 85,
      );

      // Set room ended với results
      repo.emitRoomForTest(
        ctrl.room!.copyWith(
          status: RoomStatus.ended,
          players: {p1.id: p1, p2.id: p2, p3.id: p3},
          results: matchResult,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BartenderResultsScreen(controller: ctrl),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      // Kiểm tra tiêu đề
      expect(find.text('🎉 HẾT GIỜ! 🎉'), findsOneWidget);

      // Kiểm tra thời gian sống sót: 85s
      expect(find.text('85s'), findsOneWidget);

      // Kiểm tra tổng đơn cả đội: 5 + 3 + 1 = 9 đơn
      expect(find.text('9'), findsOneWidget);

      // Kiểm tra tên người chơi và thứ hạng
      expect(find.text('Alice'), findsOneWidget);
      expect(find.text('(Bạn)'), findsOneWidget);
      expect(find.text('Bob'), findsOneWidget);
      expect(find.text('Charlie'), findsOneWidget);

      // Kiểm tra số đơn từng người
      expect(find.text('5 đơn'), findsOneWidget);
      expect(find.text('3 đơn'), findsOneWidget);
      expect(find.text('1 đơn'), findsOneWidget);

      // Thông báo thua game
      expect(find.text('BẠN ĐÃ THUA GAME 😢'), findsOneWidget);

      // Nút thoát và quay lại phòng
      expect(find.text('THOÁT'), findsOneWidget);
      expect(find.text('QUAY LẠI PHÒNG'), findsOneWidget);
      expect(find.byKey(const Key('back-to-lobby-button')), findsOneWidget);
      expect(find.byKey(const Key('play-again-button')), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
    });

    testWidgets(
        'hiển thị thông báo khi trận kết thúc vì còn dưới 2 người connected',
        (tester) async {
      final repo = FakeRoomRepository();
      final ctrl = BartenderController(repository: repo);
      addTearDown(ctrl.dispose);

      await ctrl.createRoom(playerName: 'Alice', totalPlayers: 2);
      await tester.pump(const Duration(seconds: 4));

      final p1 = Player(
        id: ctrl.myPlayerId!,
        name: 'Alice',
        ringIndex: 0,
        connected: true,
        completedOrders: 2,
      );
      final p2 = const Player(
        id: 'bot_1',
        name: 'Bob',
        ringIndex: 1,
        connected: false, // Disconnected!
        completedOrders: 1,
      );

      final matchResult = MatchResult.fromPlayers(
        players: [p1, p2],
        survivalSeconds: 30,
      );

      repo.emitRoomForTest(
        ctrl.room!.copyWith(
          status: RoomStatus.ended,
          players: {p1.id: p1, p2.id: p2},
          results: matchResult,
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BartenderResultsScreen(controller: ctrl),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));

      expect(
        find.textContaining('Trận kết thúc sớm vì còn dưới 2 người chơi'),
        findsOneWidget,
      );

      await tester.pump(const Duration(seconds: 4));
    });

    for (final size in [const Size(360, 640), const Size(390, 844)]) {
      testWidgets('không làm tràn bố cục ở kích thước $size', (tester) async {
        await tester.binding.setSurfaceSize(size);
        addTearDown(() => tester.binding.setSurfaceSize(null));

        final repo = FakeRoomRepository();
        final ctrl = BartenderController(repository: repo);
        addTearDown(ctrl.dispose);

        await ctrl.createRoom(playerName: 'Player1', totalPlayers: 4);
        await tester.pump(const Duration(seconds: 4));

        final players = List.generate(
          4,
          (i) => Player(
            id: 'p$i',
            name: 'Player $i',
            ringIndex: i,
            connected: i < 3,
            completedOrders: i * 2,
          ),
        );

        final result = MatchResult.fromPlayers(
          players: players,
          survivalSeconds: 75,
        );

        repo.emitRoomForTest(
          ctrl.room!.copyWith(
            status: RoomStatus.ended,
            players: {for (final p in players) p.id: p},
            results: result,
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: BartenderResultsScreen(controller: ctrl),
            ),
          ),
        );
        await tester.pump(const Duration(milliseconds: 100));

        expect(tester.takeException(), isNull);

        await tester.pump(const Duration(seconds: 4));
      });
    }

    testWidgets(
        'người chơi bị loại khỏi phòng (D14): controller hiện thông báo và về lobby',
        (tester) async {
      final repo = FakeRoomRepository();
      final ctrl = BartenderController(repository: repo);
      addTearDown(ctrl.dispose);

      await ctrl.createRoom(playerName: 'Alice', totalPlayers: 2);
      await tester.pump(const Duration(seconds: 4));

      // Giả lập cập nhật phòng từ repository mà không còn myId (bị loại)
      final otherPlayer = const Player(
        id: 'other_p',
        name: 'Bob',
        ringIndex: 0,
        connected: true,
      );
      repo.emitRoomForTest(
        ctrl.room!.copyWith(
          players: {otherPlayer.id: otherPlayer},
        ),
      );
      await tester.pump(const Duration(seconds: 4));

      // Controller phải dọn dẹp room và đặt errorMessage
      expect(ctrl.room, isNull);
      expect(ctrl.errorMessage, 'Bạn đã bị loại khỏi phòng do mất kết nối.');
    });

    testWidgets('bấm nút QUAY LẠI PHÒNG gọi returnToLobby', (tester) async {
      final repo = FakeRoomRepository();
      final ctrl = BartenderController(repository: repo);
      addTearDown(ctrl.dispose);

      await ctrl.createRoom(playerName: 'Alice', totalPlayers: 2);
      final p1 = Player(id: ctrl.myPlayerId!, name: 'Alice', ringIndex: 0);
      final result = MatchResult.fromPlayers(players: [p1], survivalSeconds: 60);

      repo.emitRoomForTest(ctrl.room!.copyWith(
        status: RoomStatus.ended,
        players: {p1.id: p1},
        results: result,
      ));
      await tester.pump(const Duration(milliseconds: 100));

      await tester.pumpWidget(MaterialApp(home: Scaffold(body: BartenderResultsScreen(controller: ctrl))));
      await tester.pump(const Duration(milliseconds: 100));

      expect(ctrl.isViewingResults, isTrue);
      await tester.tap(find.text('QUAY LẠI PHÒNG'));
      await tester.pump();

      expect(ctrl.isViewingResults, isFalse);
      await tester.pump(const Duration(seconds: 4));
    });
  });
}
