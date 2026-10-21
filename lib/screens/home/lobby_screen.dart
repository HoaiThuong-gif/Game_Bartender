import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'dart:math' as math;

import '../../games/bartender/screens/bartender_screen.dart';
import '../../games/rubik/screens/rubik_screen.dart';
import '../../games/song_cu/screens/song_cu_screen.dart';
import 'lobby_layout.dart';
import 'lobby_cats.dart';
import 'widgets/animated_flag.dart';
import 'widgets/lobby_object.dart';
import 'widgets/lobby_cat_layer.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    super.key,
    this.onBartenderTap,
    this.onArcadeTap,
    this.arcadeBuilder,
    this.catPopulation,
  });

  final VoidCallback? onBartenderTap;
  final VoidCallback? onArcadeTap;
  final WidgetBuilder? arcadeBuilder;
  final CatPopulation? catPopulation;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  bool _opening = false;
  bool _away = false;
  bool _active = true;
  LobbyEnvironment? _environment;

  @override
  void reassemble() {
    // Replacing bundled PNGs during development must refresh decoded images too.
    rootBundle.clear();
    PaintingBinding.instance.imageCache
      ..clear()
      ..clearLiveImages();
    super.reassemble();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final current = ModalRoute.isCurrentOf(context) ?? true;
    if (_away && current) {
      _away = false;
      _opening = false;
      _active = true;
      _environment?.finishEntry();
    }
  }

  Future<void> _enter(
    BuildContext sceneContext,
    LobbyGame game,
    VoidCallback open,
  ) async {
    if (_opening) return;
    _opening = true;
    final environment = LobbyEnvironment.maybeOf(sceneContext);
    _environment = environment;
    try {
      if (environment != null && !await environment.prepareEntry(game)) return;
      if (!mounted) return;
      setState(() => _active = false);
      open();
      await WidgetsBinding.instance.endOfFrame;
      if (!mounted) return;
      _away = !(ModalRoute.isCurrentOf(context) ?? true);
    } finally {
      if (mounted && !_away) {
        environment?.finishEntry();
        setState(() {
          _opening = false;
          _active = true;
        });
      }
    }
  }

  Route<void> _route(LobbyGame game, Widget screen) {
    final reduced = MediaQuery.disableAnimationsOf(context);
    final placement = switch (game) {
      LobbyGame.bartender => LobbyLayout.bartender,
      LobbyGame.rubik => LobbyLayout.rubik,
      LobbyGame.arcade => LobbyLayout.arcade,
      LobbyGame.television => LobbyLayout.tv,
    };
    final viewport = MediaQuery.sizeOf(context);
    final scene = LobbyLayout.designSize;
    final cover = math.max(
      viewport.width / scene.width,
      viewport.height / scene.height,
    );
    final source = placement.visualRect.center;
    final focal = Alignment(
      ((source.dx - scene.width / 2) * cover / viewport.width * 2).clamp(
        -1.0,
        1.0,
      ),
      ((source.dy - scene.height / 2) * cover / viewport.height * 2).clamp(
        -1.0,
        1.0,
      ),
    );
    return PageRouteBuilder<void>(
      transitionDuration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 220),
      reverseTransitionDuration: reduced
          ? Duration.zero
          : const Duration(milliseconds: 180),
      pageBuilder: (_, animation, secondaryAnimation) => screen,
      transitionsBuilder: (_, animation, secondaryAnimation, child) {
        final eased = animation.drive(CurveTween(curve: Curves.easeOutCubic));
        Widget result = FadeTransition(opacity: eased, child: child);
        if (game == LobbyGame.bartender) {
          result = SlideTransition(
            position: Tween<Offset>(
              begin: const Offset(-.035, .025),
              end: Offset.zero,
            ).animate(eased),
            child: result,
          );
          result = ScaleTransition(
            alignment: focal,
            scale: Tween<double>(begin: 1.025, end: 1).animate(eased),
            child: result,
          );
        } else if (game == LobbyGame.rubik) {
          result = ScaleTransition(
            alignment: focal,
            scale: Tween<double>(begin: .94, end: 1).animate(eased),
            child: result,
          );
        } else {
          result = ClipRect(
            clipper: _GameScreenReveal(eased.value, game, focal),
            child: result,
          );
        }
        return result;
      },
    );
  }

  void _comingSoon(BuildContext context, String game) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text('$game đang được phát triển.')));
  }

  Widget _place(LobbyPlacement placement, Widget child) => Positioned.fromRect(
    rect: LobbyLayout.fitObject(
      placement,
      MediaQuery.sizeOf(context),
    ).imageRect,
    child: child,
  );

  Widget _game(
    LobbyPlacement placement,
    LobbyGame game,
    String label,
    VoidCallback onTap,
  ) => _place(
    placement,
    Builder(
      builder: (sceneContext) => LobbyObject(
        asset: placement.asset,
        game: game,
        label: label,
        onTap: () => _enter(sceneContext, game, onTap),
      ),
    ),
  );

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TickerMode(
      enabled: _active,
      child: LobbyCatHost(
        active: _active,
        population: widget.catPopulation,
        child: ClipRect(
          child: SizedBox.expand(
            // Background and actors share one scene transform. The resized stall
            // and its seated cats use the same authored seat contact points.
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: LobbyLayout.designSize.width,
                height: LobbyLayout.designSize.height,
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
                      LobbyLayout.tv,
                      LobbyGame.television,
                      'Tivi thùng bí ẩn',
                      () => Navigator.of(context).push(
                        _route(LobbyGame.television, const SongCuScreen()),
                      ),
                    ),
                    _game(
                      LobbyLayout.arcade,
                      LobbyGame.arcade,
                      'Chơi Giải Mã Cổ Vật',
                      widget.onArcadeTap ??
                          () {
                            final builder = widget.arcadeBuilder;
                            if (builder == null) {
                              _comingSoon(context, 'Arcade');
                            } else {
                              Navigator.of(context).push(
                                _route(LobbyGame.arcade, builder(context)),
                              );
                            }
                          },
                    ),
                    _game(
                      LobbyLayout.bartender,
                      LobbyGame.bartender,
                      'Quầy Bartender',
                      widget.onBartenderTap ??
                          () => Navigator.of(context).push(
                            _route(
                              LobbyGame.bartender,
                              const BartenderScreen(),
                            ),
                          ),
                    ),
                    const Positioned.fill(
                      child: LobbyCatLayer(depth: CatDepth.afterBartender),
                    ),
                    _game(
                      LobbyLayout.rubik,
                      LobbyGame.rubik,
                      'Chơi Rubik',
                      () => Navigator.of(context)
                          .push(_route(LobbyGame.rubik, const RubikScreen())),
                    ),
                    _place(LobbyLayout.flag, const AnimatedFlag()),
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
    ),
  );
}

/// Expands the picture from the cabinet's side or the TV's vertical position.
class _GameScreenReveal extends CustomClipper<Rect> {
  const _GameScreenReveal(this.progress, this.game, this.focal);
  final double progress;
  final LobbyGame game;
  final Alignment focal;
  @override
  Rect getClip(Size size) {
    final width =
        size.width * (game == LobbyGame.arcade ? .72 + .28 * progress : 1);
    final height =
        size.height * (game == LobbyGame.television ? .76 + .24 * progress : 1);
    return Rect.fromLTWH(
      (size.width - width) * (focal.x + 1) / 2,
      (size.height - height) * (focal.y + 1) / 2,
      width,
      height,
    );
  }

  @override
  bool shouldReclip(_GameScreenReveal oldClipper) =>
      progress != oldClipper.progress ||
      game != oldClipper.game ||
      focal != oldClipper.focal;
}
