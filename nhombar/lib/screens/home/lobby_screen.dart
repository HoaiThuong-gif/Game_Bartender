import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import '../../games/bartender/screens/bartender_screen.dart';
import '../../games/rubik/screens/rubik_screen.dart';
import '../../games/spatial/spatial_screen.dart';
import 'lobby_layout.dart';
import 'lobby_furnishings.dart';
import 'lobby_cats.dart';
import 'widgets/lobby_panorama.dart';
import 'widgets/lobby_object.dart';
import 'widgets/lobby_cat_layer.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    super.key,
    this.onBartenderTap,
    this.onArcadeTap,
    this.arcadeBuilder,
    this.catPopulation,
    this.onAccountTap,
  });

  final VoidCallback? onBartenderTap;
  final VoidCallback? onArcadeTap;
  final WidgetBuilder? arcadeBuilder;
  final CatPopulation? catPopulation;
  final VoidCallback? onAccountTap;

  @override
  State<LobbyScreen> createState() => _LobbyScreenState();
}

class _LobbyScreenState extends State<LobbyScreen> {
  final _view = LobbyViewController();
  final _shown = {for (final game in LobbyGame.values) game: true};
  final _shownFurniture = {
    for (final layer in LobbyFurnishings.layers) layer.id: true,
  };
  bool _showCats = true;
  bool _opening = false;
  @override
  void dispose() {
    _view.dispose();
    super.dispose();
  }

  Alignment _entryFocal = Alignment.center;
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
    final focal = _entryFocal;
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

  Widget _game(
    LobbyPlacement placement,
    LobbyGame game,
    String label,
    VoidCallback onTap,
  ) => Positioned.fill(
    key: ValueKey(game),
    child: !_shown[game]!
        ? const SizedBox()
        : Builder(
            builder: (sceneContext) => LobbyObject(
              asset: placement.asset,
              placement: placement,
              game: game,
              label: label,
              onTap: () {
                ScaffoldMessenger.of(context)
                  ..hideCurrentSnackBar()
                  ..showSnackBar(
                    SnackBar(
                      content: Text(label),
                      duration: const Duration(seconds: 2),
                    ),
                  );
                final camera = LobbyCamera.of(sceneContext);
                final matrix = camera.plane(
                  Offset(placement.x, placement.y),
                  Size.zero,
                  Offset.zero,
                );
                if (matrix != null) {
                  final w = matrix.entry(3, 3);
                  _entryFocal = Alignment(
                    (2 * matrix.entry(0, 3) / w / camera.viewport.width - 1)
                        .clamp(-1.0, 1.0),
                    (2 * matrix.entry(1, 3) / w / camera.viewport.height - 1)
                        .clamp(-1.0, 1.0),
                  );
                }
                _enter(sceneContext, game, onTap);
              },
            ),
          ),
  );

  Iterable<(int, Widget)> _furniture() sync* {
    final layers = LobbyFurnishings.layers.toList()
      ..sort((a, b) => a.depth.compareTo(b.depth));
    for (final layer in layers) {
      if (!_shownFurniture[layer.id]!) continue;
      yield (
        layer.depth,
        Positioned.fill(
          key: ValueKey(layer.id),
          child: LobbyObject(
            asset: layer.placement.asset,
            placement: layer.placement,
            label: layer.label,
            onTap: null,
          ),
        ),
      );
    }
  }

  Iterable<Widget> _scene() {
    final layers = <(int, Widget)>[
      ..._furniture(),
      (
        17,
        _game(
          LobbyLayout.tv,
          LobbyGame.television,
          'Chơi AR / VR',
          () => Navigator.of(context).push(
            _route(LobbyGame.television, const SpatialScreen(expedition: true)),
          ),
        ),
      ),
      (
        18,
        _game(
          LobbyLayout.arcade,
          LobbyGame.arcade,
          'Quét vật thể 3D',
          widget.onArcadeTap ??
              () {
                final builder = widget.arcadeBuilder;
                Navigator.of(context).push(
                  _route(
                    LobbyGame.arcade,
                    builder?.call(context) ?? const SpatialScreen(),
                  ),
                );
              },
        ),
      ),
      (
        33,
        _game(
          LobbyLayout.bartender,
          LobbyGame.bartender,
          'Quầy Bartender',
          widget.onBartenderTap ??
              () => Navigator.of(context)
                  .push(_route(LobbyGame.bartender, const BartenderScreen())),
        ),
      ),
      (
        38,
        _game(
          LobbyLayout.rubik,
          LobbyGame.rubik,
          'Chơi Rubik',
          () =>
              Navigator.of(context)
                  .push(_route(LobbyGame.rubik, const RubikScreen())),
        ),
      ),
      if (_showCats)
        for (final depth in LobbyCats.spawns.map((s) => s.paintDepth).toSet())
          (
            depth,
            Positioned.fill(
              key: ValueKey('cats-at-depth-$depth'),
              child: LobbyCatLayer(paintDepth: depth),
            ),
          ),
    ]..sort((a, b) => a.$1.compareTo(b.$1));
    return layers.map((layer) => layer.$2);
  }

  void _inspect() {
    const names = {
      LobbyGame.arcade: 'Tranh / 3D',
      LobbyGame.television: 'TV / AR VR',
      LobbyGame.bartender: 'Khay / Bartender',
      LobbyGame.rubik: 'Rubik',
    };
    const placements = {
      LobbyGame.arcade: LobbyLayout.arcade,
      LobbyGame.television: LobbyLayout.tv,
      LobbyGame.bartender: LobbyLayout.bartender,
      LobbyGame.rubik: LobbyLayout.rubik,
    };
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (sheetContext) => StatefulBuilder(
        builder: (context, refresh) => SafeArea(
          child: SizedBox(
            height: MediaQuery.sizeOf(context).height * .82,
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.all(12),
                  child: Text(
                    'Layers',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Text(_view.imageInfo, style: const TextStyle(fontSize: 11)),
                Text(_view.gpuInfo, style: const TextStyle(fontSize: 11)),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    for (final enabled in [false, true])
                      TextButton.icon(
                        icon: Icon(
                          enabled ? Icons.visibility : Icons.visibility_off,
                        ),
                        label: Text(enabled ? 'Bat tat ca' : 'Phong trong'),
                        onPressed: () {
                          setState(() {
                            for (final id in _shownFurniture.keys) {
                              _shownFurniture[id] = enabled;
                            }
                            for (final game in _shown.keys) {
                              _shown[game] = enabled;
                            }
                            _showCats = enabled;
                          });
                          refresh(() {});
                        },
                      ),
                  ],
                ),
                Expanded(
                  child: ListView(
                    children: [
                      for (final entry in names.entries)
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(entry.value),
                                value: _shown[entry.key]!,
                                onChanged: (value) {
                                  setState(() => _shown[entry.key] = value);
                                  refresh(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.center_focus_strong),
                              onPressed: () {
                                _view.lookAt(
                                  placements[entry.key]!.bounds.center,
                                );
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ],
                        ),
                      for (final layer in LobbyFurnishings.layers)
                        Row(
                          children: [
                            Expanded(
                              child: SwitchListTile(
                                title: Text(layer.label),
                                value: _shownFurniture[layer.id]!,
                                onChanged: (value) {
                                  setState(
                                    () => _shownFurniture[layer.id] = value,
                                  );
                                  refresh(() {});
                                },
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.center_focus_strong),
                              onPressed: () {
                                _view.lookAt(layer.placement.bounds.center);
                                Navigator.pop(sheetContext);
                              },
                            ),
                          ],
                        ),
                      SwitchListTile(
                        title: const Text('Nam, Cam, Cho'),
                        value: _showCats,
                        onChanged: (value) {
                          setState(() => _showCats = value);
                          refresh(() {});
                        },
                      ),
                      for (final slot in [4, 7, 5])
                        ListTile(
                          title: Text(LobbyCats.spawns[slot].name),
                          trailing: const Icon(Icons.pets),
                          onTap: () {
                            final spawn = LobbyCats.spawns[slot];
                            _view.lookAt(Offset(spawn.x, spawn.y - 25));
                            Navigator.pop(sheetContext);
                          },
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: TickerMode(
      enabled: _active,
      child: LobbyCatHost(
        active: _active,
        population: widget.catPopulation,
        child: LobbyPanorama(
          controller: _view,
          children: [
            ..._scene(),
            if (widget.onAccountTap != null)
              Positioned(
                top: 0,
                left: 8,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    tooltip: 'Hồ sơ của tôi',
                    icon: const Icon(Icons.account_circle),
                    onPressed: widget.onAccountTap,
                  ),
                ),
              ),
            if (kDebugMode)
              Positioned(
                top: 0,
                right: 8,
                child: SafeArea(
                  child: IconButton.filledTonal(
                    tooltip: 'Layers',
                    icon: const Icon(Icons.layers_outlined),
                    onPressed: _inspect,
                  ),
                ),
              ),
          ],
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
