import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../games/bartender/screens/bartender_screen.dart';
import '../../games/rubik/screens/rubik_screen.dart';
import '../../games/spatial/spatial_screen.dart';
import '../../photo_scan/photo_scan_screen.dart';
import '../../settings/settings_screen.dart';
import '../../account/account_validation.dart';
import 'lobby_layout.dart';
import 'lobby_furnishings.dart';
import 'lobby_cats.dart';
import 'widgets/lobby_panorama.dart';
import 'widgets/lobby_object.dart';
import 'widgets/lobby_cat_layer.dart';
import 'widgets/lobby_account_menu.dart';

class LobbyScreen extends StatefulWidget {
  const LobbyScreen({
    super.key,
    this.onBartenderTap,
    this.onArcadeTap,
    this.arcadeBuilder,
    this.catPopulation,
    this.onAccountTap,
    this.playerName = 'Người chơi',
    this.avatarUrl,
    this.onLogout,
  });

  final VoidCallback? onBartenderTap;
  final VoidCallback? onArcadeTap;
  final WidgetBuilder? arcadeBuilder;
  final CatPopulation? catPopulation;
  final VoidCallback? onAccountTap;
  final String playerName;
  final String? avatarUrl;
  final Future<void> Function()? onLogout;

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
            label: layer.id == 'camera' ? 'Ảnh thành 3D' : layer.label,
            onTap: layer.id == 'camera' ? _openPhotoScan : null,
          ),
        ),
      );
    }
  }

  Future<void> _openPhotoScan() async {
    if (_opening) return;
    _opening = true;
    setState(() => _active = false);
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        const SnackBar(
          content: Text('Ảnh thành 3D'),
          duration: Duration(seconds: 1),
        ),
      );
    try {
      await Navigator.of(
        context,
      ).push(MaterialPageRoute<void>(builder: (_) => const PhotoScanScreen()));
    } finally {
      if (mounted) {
        setState(() {
          _opening = false;
          _active = true;
        });
      }
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
              () => Navigator.of(context).push(
                _route(
                  LobbyGame.bartender,
                  BartenderScreen(playerName: widget.playerName),
                ),
              ),
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

  Future<void> _inspect() async {
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
    await showModalBottomSheet<void>(
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
                    'Bố cục Lobby',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  alignment: WrapAlignment.center,
                  children: [
                    for (final enabled in [false, true])
                      TextButton.icon(
                        icon: Icon(
                          enabled ? Icons.visibility : Icons.visibility_off,
                        ),
                        label: Text(enabled ? 'Bật tất cả' : 'Phòng trống'),
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

  Future<void> _accountMenu() async {
    if (_opening) return;
    setState(() {
      _opening = true;
      _active = false;
    });
    try {
      final action = await showLobbyAccountMenu(
        context,
        name: widget.playerName,
        photoUrl: widget.avatarUrl,
        canLogout: widget.onLogout != null,
      );
      if (!mounted) return;
      switch (action) {
        case LobbyAccountAction.profile:
          widget.onAccountTap?.call();
          await WidgetsBinding.instance.endOfFrame;
          if (mounted) _away = !(ModalRoute.isCurrentOf(context) ?? true);
        case LobbyAccountAction.settings:
          await Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const SettingsScreen()),
          );
        case LobbyAccountAction.appearance:
          await Navigator.push(
            context,
            MaterialPageRoute<void>(builder: (_) => const AppearanceScreen()),
          );
        case LobbyAccountAction.layout:
          await _inspect();
        case LobbyAccountAction.logout:
          final confirmed = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Đăng xuất?'),
              content: const Text('Bạn có thể đăng nhập lại bất cứ lúc nào.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context, false),
                  child: const Text('Ở lại'),
                ),
                FilledButton(
                  onPressed: () => Navigator.pop(context, true),
                  child: const Text('Đăng xuất'),
                ),
              ],
            ),
          );
          if (confirmed == true) await widget.onLogout?.call();
        case null:
          break;
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text(accountError(error))));
      }
    } finally {
      if (mounted && !_away) {
        setState(() {
          _opening = false;
          _active = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Stack(
      children: [
        Positioned.fill(
          child: TickerMode(
            enabled: _active,
            child: LobbyCatHost(
              active: _active,
              population: widget.catPopulation,
              child: LobbyPanorama(controller: _view, children: [..._scene()]),
            ),
          ),
        ),
        Positioned(
          top: 0,
          left: 12,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: LobbyAccountButton(
                name: widget.playerName,
                photoUrl: widget.avatarUrl,
                onPressed: _accountMenu,
              ),
            ),
          ),
        ),
      ],
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
