import 'package:flutter/material.dart';

import '../../games/artifact/screens/artifact_screen.dart';
import 'lobby_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      LobbyScreen(arcadeBuilder: (_) => const ArtifactScreen());
}
