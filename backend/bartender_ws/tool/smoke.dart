// ignore_for_file: avoid_print
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:web_socket_channel/io.dart';

void main(List<String> args) async {
  var baseUrl = args.isNotEmpty ? args[0].trim() : 'http://localhost:8080';
  if (baseUrl.endsWith('/')) {
    baseUrl = baseUrl.substring(0, baseUrl.length - 1);
  }

  final wsBaseUrl = baseUrl.startsWith('https://')
      ? baseUrl.replaceFirst('https://', 'wss://')
      : baseUrl.replaceFirst('http://', 'ws://');

  print('=== BẮT ĐẦU KIỂM TRA KHÓI (SMOKE TEST) CHO BARTENDER SERVER ===');
  print('Địa chỉ máy chủ: $baseUrl\n');

  try {
    // 1. Kiểm tra /health
    stdout.write('1. Kiểm tra kết nối máy chủ (/health)... ');
    final healthRes = await http.get(Uri.parse('$baseUrl/health'));
    if (healthRes.statusCode != 200) {
      print('[FAIL] Mã HTTP: ${healthRes.statusCode}');
      exit(1);
    }
    final healthData = jsonDecode(healthRes.body) as Map<String, dynamic>;
    if (healthData['status'] != 'ok') {
      print('[FAIL] Dữ liệu trả về không đúng: ${healthRes.body}');
      exit(1);
    }
    print('[OK] (Trạng thái: ok, số phòng hiện tại: ${healthData['rooms']})');

    // 2. Tạo phòng
    stdout.write('2. Tạo phòng mới (Host: "Người chơi 1")... ');
    final createRes = await http.post(
      Uri.parse('$baseUrl/rooms'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'playerName': 'Người chơi 1'}),
    );
    if (createRes.statusCode != 201) {
      print('[FAIL] Mã HTTP: ${createRes.statusCode}, body: ${createRes.body}');
      exit(1);
    }
    final createData = jsonDecode(createRes.body) as Map<String, dynamic>;
    final code = (createData['room'] as Map<String, dynamic>)['code'] as String;
    final hostToken = createData['playerToken'] as String;
    final hostId = createData['playerId'] as String;
    print('[OK] (Mã phòng: #$code, Host ID: $hostId)');

    // 3. Người chơi 2 tham gia phòng
    stdout.write('3. Người chơi 2 ("Người chơi 2") tham gia phòng #$code... ');
    final joinRes = await http.post(
      Uri.parse('$baseUrl/rooms/$code/join'),
      headers: {'content-type': 'application/json'},
      body: jsonEncode({'playerName': 'Người chơi 2'}),
    );
    if (joinRes.statusCode != 200) {
      print('[FAIL] Mã HTTP: ${joinRes.statusCode}, body: ${joinRes.body}');
      exit(1);
    }
    final joinData = jsonDecode(joinRes.body) as Map<String, dynamic>;
    final guestToken = joinData['playerToken'] as String;
    final guestId = joinData['playerId'] as String;
    print('[OK] (Guest ID: $guestId, tổng người chơi: 2)');

    // 4. Kết nối WebSocket
    stdout.write('4. Mở kết nối WebSocket thời gian thực cho cả 2 người chơi... ');
    final hostWs = IOWebSocketChannel.connect(
      Uri.parse('$wsBaseUrl/rooms/$code/ws?token=$hostToken'),
    );
    final guestWs = IOWebSocketChannel.connect(
      Uri.parse('$wsBaseUrl/rooms/$code/ws?token=$guestToken'),
    );

    final hostSnapshots = StreamController<Map<String, dynamic>>.broadcast();
    final guestSnapshots = StreamController<Map<String, dynamic>>.broadcast();

    final sub1 = hostWs.stream.listen((msg) {
      final data = jsonDecode(msg as String) as Map<String, dynamic>;
      if (data['type'] == 'snapshot') {
        hostSnapshots.add(data['room'] as Map<String, dynamic>);
      }
    });

    final sub2 = guestWs.stream.listen((msg) {
      final data = jsonDecode(msg as String) as Map<String, dynamic>;
      if (data['type'] == 'snapshot') {
        guestSnapshots.add(data['room'] as Map<String, dynamic>);
      }
    });

    final initialSnap = await hostSnapshots.stream.first.timeout(
      const Duration(seconds: 5),
      onTimeout: () => throw TimeoutException('Quá thời gian nhận snapshot WebSocket.'),
    );
    if (initialSnap['status'] != 'lobby') {
      print('[FAIL] Trạng thái phòng không phải lobby: ${initialSnap['status']}');
      exit(1);
    }
    print('[OK] (Đã nhận snapshot ban đầu)');

    // 5. Bắt đầu trận đấu
    stdout.write('5. Chủ phòng bắt đầu trận đấu (/start)... ');
    final startRes = await http.post(
      Uri.parse('$baseUrl/rooms/$code/start'),
      headers: {'authorization': 'Bearer $hostToken'},
    );
    if (startRes.statusCode != 204) {
      print('[FAIL] Mã HTTP: ${startRes.statusCode}, body: ${startRes.body}');
      exit(1);
    }

    final playingSnap = await hostSnapshots.stream.firstWhere(
      (s) => s['status'] == 'playing',
    ).timeout(const Duration(seconds: 5));
    print('[OK] (Trận đấu đang diễn ra: Round ${playingSnap['currentRound']['number']})');

    // 6. Chuyền vật phẩm giữa 2 người chơi
    stdout.write('6. Host chuyền 1 nguyên liệu sang Guest (ring 0 -> 1)... ');
    final hostItems = playingSnap['inbox']['0'] as List;
    if (hostItems.isEmpty) {
      print('[FAIL] Khay đồ của host rỗng');
      exit(1);
    }
    final itemToSend = hostItems.first as Map<String, dynamic>;

    final sendRes = await http.post(
      Uri.parse('$baseUrl/rooms/$code/items/send'),
      headers: {
        'authorization': 'Bearer $hostToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({
        'itemId': itemToSend['id'],
        'toRingIndex': 1,
      }),
    );
    if (sendRes.statusCode != 204) {
      print('[FAIL] Mã HTTP: ${sendRes.statusCode}, body: ${sendRes.body}');
      exit(1);
    }

    await guestSnapshots.stream.firstWhere((s) {
      final guestInbox = s['inbox']['1'] as List;
      return guestInbox.any((it) => it['id'] == itemToSend['id']);
    }).timeout(const Duration(seconds: 5));
    print('[OK] (Guest đã nhận được nguyên liệu ${itemToSend['itemId']})');

    // 7. Bỏ thùng rác
    stdout.write('7. Guest bỏ vật phẩm vào thùng rác (/trash)... ');
    final trashRes = await http.post(
      Uri.parse('$baseUrl/rooms/$code/items/trash'),
      headers: {
        'authorization': 'Bearer $guestToken',
        'content-type': 'application/json',
      },
      body: jsonEncode({'itemId': itemToSend['id']}),
    );
    if (trashRes.statusCode != 204) {
      print('[FAIL] Mã HTTP: ${trashRes.statusCode}, body: ${trashRes.body}');
      exit(1);
    }
    print('[OK] (Đã dọn dẹp vật phẩm)');

    // 8. Rời phòng và kết thúc trận
    stdout.write('8. Guest rời phòng -> Trận kết thúc sớm do < 2 người... ');
    final leaveRes = await http.post(
      Uri.parse('$baseUrl/rooms/$code/leave'),
      headers: {'authorization': 'Bearer $guestToken'},
    );
    if (leaveRes.statusCode != 204) {
      print('[FAIL] Mã HTTP: ${leaveRes.statusCode}, body: ${leaveRes.body}');
      exit(1);
    }

    final endedSnap = await hostSnapshots.stream.firstWhere(
      (s) => s['status'] == 'ended',
    ).timeout(const Duration(seconds: 5));

    final results = endedSnap['results'] as Map<String, dynamic>?;
    if (results == null) {
      print('[FAIL] Không nhận được results cuối trận');
      exit(1);
    }
    print('[OK] (Trận kết thúc: status = ended, survival = ${results['totalSurvivalSeconds']}s)');

    // Dọn dẹp
    await sub1.cancel();
    await sub2.cancel();
    await hostWs.sink.close();
    await guestWs.sink.close();
    await hostSnapshots.close();
    await guestSnapshots.close();

    print('\n================================================================');
    print('🎉 TẤT CẢ CÁC BƯỚC KIỂM TRA KHÓI (SMOKE TEST) ĐÃ VƯỢT QUA 100%!');
    print('Máy chủ hoạt động hoàn toàn chính xác theo hợp đồng API.md.');
    print('================================================================');
    exit(0);
  } catch (e, stack) {
    print('\n[FAIL] Ngoại lệ không mong muốn trong quá trình kiểm tra: $e');
    print(stack);
    exit(1);
  }
}
