import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../lobby_cats.dart';
import '../lobby_layout.dart';
import '../nam_cat_assets.dart';
import '../nam_cat_state_controller.dart';
import 'nam_cat_character.dart';

enum _CatStage { idle, leaving, empty, arriving }

/// Schedules population fades and one occasional courtyard detail independently.
class LobbyCatHost extends StatefulWidget {
  const LobbyCatHost({
    super.key,
    required this.child,
    this.seed,
    this.population,
    this.active = true,
  });
  final Widget child;
  final int? seed;
  final CatPopulation? population;
  final bool active;
  @override
  State<LobbyCatHost> createState() => _LobbyCatHostState();
}

class _LobbyCatHostState extends State<LobbyCatHost>
    with TickerProviderStateMixin, WidgetsBindingObserver {
  late final _population =
      widget.population ?? CatPopulation(Random(widget.seed));
  late final _sprites = {
    for (final type in CatType.values) type: NamSpriteSet.load(type: type),
  };
  late final _fade = AnimationController(
    vsync: this,
    duration: LobbyCats.fadeDuration,
    value: 1,
  )..addStatusListener(_statusChanged);
  late final _ambient = AnimationController(vsync: this)
    ..addListener(_ambientFrame)
    ..addStatusListener(_ambientStatus);
  late final _atmosphere = LobbyAtmosphere(_ambient);
  final _random = Random();
  final _remainingGames = <LobbyGame>[];
  Timer? _ambientTimer;
  bool _reduceMotion = false;
  bool _firstAmbient = true;
  bool _wasActive = false;
  bool _reactionIssued = false;
  final _lastCatReaction = <CatType, DateTime>{};
  Timer? _timer;
  VoidCallback? _timerAction;
  Duration? _timerDelay;
  bool _enabled = false;
  bool _resumed = true;
  _CatStage _stage = _CatStage.idle;
  bool get _active => widget.active && _enabled && _resumed;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _resumed = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _enabled = TickerMode.valuesOf(context).enabled;
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    _fade.duration = _reduceMotion ? Duration.zero : LobbyCats.fadeDuration;
    _syncActivity();
  }

  @override
  void didUpdateWidget(covariant LobbyCatHost oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.active != widget.active) _syncActivity();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _syncActivity();
  }

  void _arm(Duration delay, VoidCallback action) {
    _timer?.cancel();
    _timerDelay = delay;
    _timerAction = action;
    if (!_active) return;
    _timer = Timer(delay, () {
      _timer = null;
      _timerAction = null;
      _timerDelay = null;
      if (mounted) action();
    });
  }

  void _syncActivity() {
    if (_active && !_wasActive) _firstAmbient = true;
    _wasActive = _active;
    if (!_active || _reduceMotion) {
      _ambientTimer?.cancel();
      _ambientTimer = null;
      if (!_atmosphere.entering) {
        _ambient.stop();
        _ambient.value = 0;
        if (_atmosphere.game != null) _atmosphere.clear();
      } else {
        _ambient.stop(canceled: false);
        if (_active && _reduceMotion) _ambient.value = 1;
      }
    } else if (_atmosphere.entering) {
      if (_ambient.value < 1) _ambient.forward();
    } else {
      _scheduleAmbient();
    }
    if (!_active) {
      _timer?.cancel();
      _timer = null;
      _fade.stop(canceled: false);
    } else if (_fade.status == AnimationStatus.reverse) {
      _fade.reverse();
    } else if (_fade.status == AnimationStatus.forward) {
      _fade.forward();
    } else if (_timerAction != null) {
      if (!(_timer?.isActive ?? false)) _arm(_timerDelay!, _timerAction!);
    } else if (_population.pending == null) {
      _idle();
    }
  }

  void _scheduleAmbient({bool retry = false}) {
    if (!_active ||
        _reduceMotion ||
        _atmosphere.entering ||
        _ambient.isAnimating ||
        (_ambientTimer?.isActive ?? false)) {
      return;
    }
    final delay = retry
        ? const Duration(milliseconds: 700)
        : _firstAmbient
        ? const Duration(milliseconds: 1200)
        : Duration(milliseconds: 4000 + _random.nextInt(4001));
    _ambientTimer = Timer(delay, () {
      _ambientTimer = null;
      if (!_active || _reduceMotion || _atmosphere.entering) return;
      // Leave population fades and direct petting a quiet interval of their own.
      if (_population.pending != null || _population.busyCats.isNotEmpty) {
        _scheduleAmbient(retry: true);
        return;
      }
      if (_remainingGames.isEmpty) {
        _remainingGames.addAll(LobbyGame.values.toList()..shuffle(_random));
      }
      final game = _firstAmbient ? LobbyGame.bartender : _remainingGames.last;
      _remainingGames.remove(game);
      _firstAmbient = false;
      _ambient.duration = const Duration(milliseconds: 3600);
      _reactionIssued = false;
      // Start reactions after the light/motion becomes visible, not before it.
      _atmosphere.show(game);
      _ambient.forward(from: 0);
    });
  }

  void _ambientFrame() {
    if (!_active ||
        _reduceMotion ||
        _atmosphere.entering ||
        _reactionIssued ||
        _ambient.value < .2 ||
        _atmosphere.game == null) {
      return;
    }
    _reactionIssued = true;
    final cat = _nearbyCat(_atmosphere.game!);
    if (cat != null) {
      _lastCatReaction[cat] = DateTime.now();
      _atmosphere.react(cat);
    }
  }

  CatType? _nearbyCat(LobbyGame game) {
    const expression = CatExpression.observing;
    final object = switch (game) {
      LobbyGame.bartender => LobbyLayout.bartender,
      LobbyGame.rubik => LobbyLayout.rubik,
      LobbyGame.arcade => LobbyLayout.arcade,
      LobbyGame.television => LobbyLayout.tv,
    };
    final point = object.visualRect.center;
    final candidates = _population.visible
        .where(
          (cat) =>
              cat.pose != CatPose.sleeping &&
              NamFrames.supports(cat.pose, expression, cat.type) &&
              DateTime.now().difference(
                    _lastCatReaction[cat.type] ?? DateTime(2000),
                  ) >
                  const Duration(seconds: 18) &&
              !_population.busyCats.contains(cat.type) &&
              !(_population.pending?.involves(cat.type) ?? false),
        )
        .toList();
    double distance(CatCharacter cat) {
      final slot = LobbyCats.spawns[cat.spawnIndex!];
      return (Offset(slot.x, slot.y - slot.sizeFor(cat.pose).height / 2) -
              point +
              slot.viewportShift(MediaQuery.sizeOf(context)))
          .distance;
    }

    candidates.sort((a, b) => distance(a).compareTo(distance(b)));
    return candidates.isNotEmpty && distance(candidates.first) < 520
        ? candidates.first.type
        : null;
  }

  void _ambientStatus(AnimationStatus status) {
    if (status == AnimationStatus.completed && !_atmosphere.entering) {
      _atmosphere.clear();
      _scheduleAmbient();
    }
  }

  Future<bool> _prepareEntry(LobbyGame game) async {
    if (!_active || _atmosphere.entering) return false;
    _ambientTimer?.cancel();
    _ambientTimer = null;
    _ambient.stop();
    _ambient.duration = const Duration(milliseconds: 210);
    _atmosphere.show(game, entry: true);
    if (_reduceMotion) {
      _ambient.value = 1;
      return true;
    }
    try {
      await _ambient.forward(from: 0).orCancel;
      return mounted && _active;
    } on TickerCanceled {
      return false;
    }
  }

  void _finishEntry() {
    _ambient.stop();
    _ambient.value = 0;
    _atmosphere.clear();
    _scheduleAmbient();
  }

  void _idle() => _arm(_population.nextInterval(), () {
    if (_atmosphere.entering) {
      _idle();
      return;
    }
    if (_ambient.isAnimating) {
      _ambient.stop();
      _atmosphere.clear();
    }
    final change = _population.planChange();
    if (change == null) {
      _idle();
      return;
    }
    _stage = _CatStage.leaving;
    _population.begin(change);
    if (change.outgoing == null) {
      _fade.value = 0;
    } else {
      _fade.reverse();
    }
  });
  void _statusChanged(AnimationStatus status) {
    if (_population.pending == null) return;
    if (status == AnimationStatus.dismissed && _stage == _CatStage.leaving) {
      _stage = _CatStage.empty;
      // Keep the old sprite/position intact but invisible during this gap.
      _arm(LobbyCats.emptyDuration, () {
        _stage = _CatStage.arriving;
        _population.commit();
        _fade.forward();
      });
    } else if (status == AnimationStatus.completed &&
        _stage == _CatStage.arriving) {
      _stage = _CatStage.idle;
      _population.finish();
      _idle();
    }
  }

  @override
  void dispose() {
    _ambientTimer?.cancel();
    _ambient.dispose();
    _atmosphere.dispose();
    _timer?.cancel();
    _fade.dispose();
    for (final future in _sprites.values) {
      future.then((sprites) => sprites.dispose(), onError: (Object _) {});
    }
    WidgetsBinding.instance.removeObserver(this);
    if (widget.population == null) _population.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LobbyEnvironment(
      atmosphere: _atmosphere,
      prepareEntry: _prepareEntry,
      finishEntry: _finishEntry,
      child: _CatScope(
        population: _population,
        fade: _fade,
        namSprites: _sprites,
        child: widget.child,
      ),
    );
  }
}

class _CatScope extends InheritedNotifier<CatPopulation> {
  const _CatScope({
    required CatPopulation population,
    required this.fade,
    required this.namSprites,
    required super.child,
  }) : super(notifier: population);
  final Animation<double> fade;
  final Map<CatType, Future<NamSpriteSet>> namSprites;
  static _CatScope of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<_CatScope>()!;
}

/// One depth band; all bands share the same population and scheduler.
class LobbyCatLayer extends StatelessWidget {
  const LobbyCatLayer({super.key, required this.depth});
  final CatDepth depth;
  @override
  Widget build(BuildContext context) {
    final scope = _CatScope.of(context);
    final population = scope.notifier!;
    final cats =
        population.visible
            .where(
              (cat) =>
                  LobbyCats.spawns[cat.spawnIndex!].depthFor(cat.type) == depth,
            )
            .toList()
          ..sort(
            (a, b) => LobbyCats.spawns[a.spawnIndex!].y.compareTo(
              LobbyCats.spawns[b.spawnIndex!].y,
            ),
          );
    return RepaintBoundary(
      child: Stack(
        children: [
          for (final cat in cats)
            Positioned.fromRect(
              key: ValueKey(cat.type),
              rect: LobbyCats.spawns[cat.spawnIndex!]
                  .rectFor(cat.type)
                  .shift(
                    LobbyCats.spawns[cat.spawnIndex!].viewportShift(
                      MediaQuery.sizeOf(context),
                    ),
                  ),
              child: FadeTransition(
                key: ValueKey('cat-population-fade-${cat.type.name}'),
                opacity: population.pending?.involves(cat.type) ?? false
                    ? scope.fade
                    : kAlwaysCompleteAnimation,
                child: IgnorePointer(
                  ignoring: (population.pending?.involves(cat.type) ?? false),
                  child: CatSprite(
                    key: ValueKey(cat.type),
                    cat: cat.sprite,
                    anchor: LobbyCats.spawns[cat.spawnIndex!].anchor,
                    placement: LobbyCats.spawns[cat.spawnIndex!],
                    onNamPoseChanged: (pose) =>
                        population.setPose(cat.type, pose),
                    onNamBusyChanged: (value) =>
                        population.setBusy(cat.type, value),
                    namSprites: scope.namSprites[cat.type],
                    sceneAnchor:
                        Offset(
                          LobbyCats.spawns[cat.spawnIndex!].x,
                          LobbyCats.spawns[cat.spawnIndex!].y,
                        ) +
                        LobbyCats.spawns[cat.spawnIndex!].viewportShift(
                          MediaQuery.sizeOf(context),
                        ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class CatSprite extends StatelessWidget {
  const CatSprite({
    super.key,
    required this.cat,
    this.anchor = const Offset(0.5, LobbyCats.groundAnchor),
    this.placement,
    this.onNamPoseChanged,
    this.onNamBusyChanged,
    this.namSprites,
    this.sceneAnchor,
  });
  final LobbyCat cat;
  final Offset anchor;
  final CatSpawn? placement;
  final ValueChanged<CatPose>? onNamPoseChanged;
  final ValueChanged<bool>? onNamBusyChanged;
  final Future<NamSpriteSet>? namSprites;
  final Offset? sceneAnchor;

  @override
  Widget build(BuildContext context) => NamCatCharacter(
    type: cat.type,
    targetSize: placement?.sizeFor(cat.pose),
    pose: cat.pose,
    anchor: anchor,
    onPoseChanged: onNamPoseChanged,
    onBusyChanged: onNamBusyChanged,
    sprites: namSprites,
    sceneAnchor: sceneAnchor,
  );
}
