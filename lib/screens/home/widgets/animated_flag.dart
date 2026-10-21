import 'package:flutter/material.dart';

import 'lobby_sprite.dart';

class AnimatedFlag extends StatelessWidget {
  const AnimatedFlag({super.key});
  @override
  Widget build(BuildContext context) => const IgnorePointer(
    child: RepaintBoundary(
      child: LobbySprite(
        name: 'flag',
        count: 12,
        period: Duration(milliseconds: 1440),
      ),
    ),
  );
}
