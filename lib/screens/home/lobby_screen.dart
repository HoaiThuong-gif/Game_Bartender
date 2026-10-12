import 'package:flutter/material.dart';

import '../../games/bartender/screens/bartender_screen.dart';
import '../../games/rubik/screens/rubik_screen.dart';
import 'lobby_layout.dart';
import 'lobby_cats.dart';
import 'widgets/animated_flag.dart';
import 'widgets/lobby_object.dart';
import 'widgets/lobby_cat_layer.dart';

class LobbyScreen extends StatelessWidget {
  const LobbyScreen({
    super.key,
    this.onBartenderTap,
    this.onArcadeTap,
    this.catPopulation,
  });

  final VoidCallback? onBartenderTap;
  final VoidCallback? onArcadeTap;
  final CatPopulation? catPopulation;

  void _comingSoon(BuildContext context, String game) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$game đang được phát triển.')));
  }

  Widget _place(LobbyPlacement placement, Widget child) =>
      Positioned.fromRect(rect: placement.imageRect, child: child);

  Widget _game(LobbyPlacement placement, String label, VoidCallback onTap) =>
      _place(
        placement,
        LobbyObject(
          asset: placement.asset,
          label: label,
          anchorAlignment: placement.imageAnchorAlignment,
          onTap: onTap,
        ),
      );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: ClipRect(
      child: SizedBox.expand(
        // One cover transform for every layer. Never move individual objects
        // to fit a viewport: that would move their feet off their scene surface.
        child: FittedBox(
          fit: BoxFit.cover,
          child: SizedBox(
            width: LobbyLayout.designSize.width,
            height: LobbyLayout.designSize.height,
            child: LobbyCatHost(
              population: catPopulation,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  const Positioned.fill(
                    child: Image(
                      image: AssetImage(LobbyLayout.backgroundAsset),
                      fit: BoxFit.cover,
                      excludeFromSemantics: true,
                    ),
                  ),
                  const Positioned.fill(
                    child: LobbyCatLayer(depth: CatDepth.behindGames),
                  ),
                  _game(
                    LobbyLayout.arcade,
                    'Máy arcade',
                    onArcadeTap ?? () => _comingSoon(context, 'Arcade'),
                  ),
                  _game(
                    LobbyLayout.bartender,
                    'Quầy Bartender',
                    onBartenderTap ??
                        () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => const BartenderScreen(),
                          ),
                        ),
                  ),
                  const Positioned.fill(
                    child: LobbyCatLayer(depth: CatDepth.afterBartender),
                  ),
                  _game(
                    LobbyLayout.rubik,
                    'Chơi Rubik',
                    () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const RubikScreen(),
                      ),
                    ),
                  ),
                  _place(
                    LobbyLayout.flag,
                    AnimatedFlag(
                      asset: LobbyLayout.flag.asset,
                      anchorAlignment: LobbyLayout.flag.imageAnchorAlignment,
                    ),
                  ),
                  const Positioned.fill(
                    child: LobbyCatLayer(depth: CatDepth.foreground),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );
}
