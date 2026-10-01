import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';

import '../lobby_cats.dart';

enum _CatStage { idle, leaving, empty, arriving }

/// Owns one slow timer and one short fade; static scene widgets stay untouched.
class LobbyCatHost extends StatefulWidget {
  const LobbyCatHost({
    super.key,
    required this.child,
    this.seed,
    this.population,
  });
  final Widget child;
  final int? seed;
  final CatPopulation? population;
  @override
  State<LobbyCatHost> createState() => _LobbyCatHostState();
}

class _LobbyCatHostState extends State<LobbyCatHost>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final _population =
      widget.population ?? CatPopulation(Random(widget.seed));
  late final _fade = AnimationController(
    vsync: this,
    duration: LobbyCats.fadeDuration,
    value: 1,
  )..addStatusListener(_statusChanged);
  Timer? _timer;
  VoidCallback? _timerAction;
  Duration? _timerDelay;
  bool _enabled = false;
  bool _resumed = true;
  bool _preloaded = false;
  _CatStage _stage = _CatStage.idle;
  bool get _active => _enabled && _resumed;

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
    _fade.duration = MediaQuery.disableAnimationsOf(context)
        ? Duration.zero
        : LobbyCats.fadeDuration;
    if (!_preloaded) {
      _preloaded = true;
      for (final type in CatType.values) {
        precacheImage(
          AssetImage(LobbyCat(type, CatPose.sitting).asset),
          context,
        );
      }
    }
    _syncActivity();
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

  void _idle() => _arm(_population.nextInterval(), () {
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
    _timer?.cancel();
    _fade.dispose();
    WidgetsBinding.instance.removeObserver(this);
    if (widget.population == null) _population.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      _CatScope(population: _population, fade: _fade, child: widget.child);
}

class _CatScope extends InheritedNotifier<CatPopulation> {
  const _CatScope({
    required CatPopulation population,
    required this.fade,
    required super.child,
  }) : super(notifier: population);
  final Animation<double> fade;
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
            .where((cat) => LobbyCats.spawns[cat.spawnIndex!].depth == depth)
            .toList()
          ..sort(
            (a, b) => LobbyCats.spawns[a.spawnIndex!].y.compareTo(
              LobbyCats.spawns[b.spawnIndex!].y,
            ),
          );
    return IgnorePointer(
      child: RepaintBoundary(
        child: Stack(
          children: [
            for (final cat in cats)
              Positioned.fromRect(
                key: ValueKey(cat.type),
                rect: LobbyCats.spawns[cat.spawnIndex!].rect,
                child: FadeTransition(
                  opacity: population.pending?.involves(cat.type) ?? false
                      ? scope.fade
                      : kAlwaysCompleteAnimation,
                  child: CatSprite(
                    key: ValueKey(cat.type),
                    cat: cat.sprite,
                    anchor: LobbyCats.spawns[cat.spawnIndex!].anchor,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class CatSprite extends StatelessWidget {
  const CatSprite({
    super.key,
    required this.cat,
    this.anchor = const Offset(0.5, LobbyCats.groundAnchor),
  });
  final LobbyCat cat;
  final Offset anchor;
  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.maxWidth;
      final source = cat.sourceRect;
      final rotated = cat.quarterTurns.isOdd;
      final width = rotated ? source.height : source.width;
      final height = rotated ? source.width : source.height;
      final scale = min(size * 0.82 / width, size * 0.8 / height);
      return Stack(
        children: [
          Positioned(
            left: size * anchor.dx - width * scale / 2,
            top: size * anchor.dy - height * scale,
            width: width * scale,
            height: height * scale,
            child: RotatedBox(
              quarterTurns: cat.quarterTurns,
              child: ClipRect(
                child: Stack(
                  children: [
                    Positioned(
                      left: -source.left * scale,
                      top: -source.top * scale,
                      width: LobbyCat.atlasSize * scale,
                      height: LobbyCat.atlasSize * scale,
                      child: Image.asset(
                        cat.asset,
                        fit: BoxFit.fill,
                        excludeFromSemantics: true,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      );
    },
  );
}
