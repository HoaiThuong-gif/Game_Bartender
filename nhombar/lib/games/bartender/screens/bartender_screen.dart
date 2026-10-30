import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import 'bartender_lobby_screen.dart';
import 'bartender_match_screen.dart';
import 'bartender_results_screen.dart';

/// Entry point: UI/controller use the HTTP repository by default.
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
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      if (_controller.isMatchEnded) {
        return BartenderResultsScreen(controller: _controller);
      }
      if (_controller.isMatchPlaying) {
        return BartenderMatchScreen(controller: _controller);
      }
      return BartenderLobbyScreen(controller: _controller);
    },
  );
}
