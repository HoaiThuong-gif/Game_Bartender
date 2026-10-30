import 'package:flutter/material.dart';

import '../../../shared/widgets/cozy_loading.dart';

import '../../../settings/app_settings.dart';
import '../../../settings/app_theme.dart';

import '../controllers/bartender_controller.dart';
import '../services/room_repository.dart';
import 'bartender_lobby_screen.dart';
import 'bartender_match_screen.dart';
import 'bartender_results_screen.dart';

/// Entry point: UI/controller use the HTTP repository by default.
class BartenderScreen extends StatefulWidget {
  const BartenderScreen({super.key, this.repository, this.playerName});
  final RoomRepository? repository;
  final String? playerName;

  @override
  State<BartenderScreen> createState() => _BartenderScreenState();
}

class _BartenderScreenState extends State<BartenderScreen> {
  late final BartenderController _controller;

  @override
  void initState() {
    super.initState();
    _controller = BartenderController(repository: widget.repository);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Theme(
    data: AppTheme.build(
      AppSettingsScope.maybeOf(context)?.seedColor ?? const Color(0xFFA95C3B),
      game: true,
    ),
    child: ListenableBuilder(
      listenable: _controller,
      builder: (context, _) {
        final screen = _controller.isViewingResults
            ? BartenderResultsScreen(controller: _controller)
            : _controller.isMatchPlaying
            ? BartenderMatchScreen(controller: _controller)
            : BartenderLobbyScreen(
                controller: _controller,
                playerName: widget.playerName,
              );
        return PopScope<void>(
          canPop: _controller.room == null && !_controller.isBusy,
          onPopInvokedWithResult: (didPop, _) async {
            if (didPop || _controller.isBusy) return;
            await _controller.leaveRoom();
            if (context.mounted && _controller.room == null) {
              Navigator.of(context).pop();
            }
          },
          child: Stack(
            children: [
              screen,
              if (_controller.isBusy)
                const Positioned.fill(
                  child: ColoredBox(
                    color: Color(0xFFFFF8F1),
                    child: CozyLoading(label: 'Đang xử lý…'),
                  ),
                ),
            ],
          ),
        );
      },
    ),
  );
}
