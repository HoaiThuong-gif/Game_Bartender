import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../models/room.dart';
import 'bartender_lobby_screen.dart';
import 'bartender_match_screen.dart';
import 'bartender_results_screen.dart';

/// Điểm vào duy nhất (entry point) của tính năng Bartender.
/// Đây là screen mà lobby_screen.dart sẽ navigate tới (ở giai đoạn 7).
///
/// Quản lý vòng đời BartenderController và chuyển đổi giữa 3 màn hình:
/// 1. Lobby → khi chưa bắt đầu hoặc đang chờ phòng
/// 2. Match → khi đang chơi (status == playing)
/// 3. Results → khi trận kết thúc (status == ended)
class BartenderScreen extends StatefulWidget {
  const BartenderScreen({super.key});

  @override
  State<BartenderScreen> createState() => _BartenderScreenState();
}

class _BartenderScreenState extends State<BartenderScreen> {
  late final BartenderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BartenderController();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        // Chuyển màn hình dựa trên trạng thái phòng
        if (_controller.isMatchEnded) {
          return BartenderResultsScreen(controller: _controller);
        }

        if (_controller.isMatchPlaying) {
          return BartenderMatchScreen(controller: _controller);
        }

        // Mặc định: lobby (bao gồm cả trường hợp chưa tạo phòng)
        return BartenderLobbyScreen(controller: _controller);
      },
    );
  }
}
