import 'package:flutter/material.dart';

/// One decoded PNG is cached per authored frame by Flutter's image cache.
class LobbySprite extends StatefulWidget {
  const LobbySprite({
    super.key,
    required this.name,
    required this.count,
    required this.period,
    this.frame,
    this.sequence,
    this.frameOffset = 0,
  });
  final String name;
  final int count;
  final Duration period;
  final int? frame;
  final List<int>? sequence;
  final int frameOffset;
  @override
  State<LobbySprite> createState() => _LobbySpriteState();
}

class _LobbySpriteState extends State<LobbySprite>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late final AnimationController _clock = AnimationController(
    vsync: this,
    duration: widget.period,
  );
  bool _resumed = true;
  int _frame = 0;
  @override
  void initState() {
    super.initState();
    _clock.addListener(() {
      final count = widget.sequence?.length ?? widget.count;
      final next = (_clock.value * count).floor().clamp(0, count - 1);
      if (next != _frame) setState(() => _frame = next);
    });
    WidgetsBinding.instance.addObserver(this);
    final state = WidgetsBinding.instance.lifecycleState;
    _resumed = state == null || state == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _sync();
  }

  @override
  void didUpdateWidget(covariant LobbySprite oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.period != widget.period) _clock.duration = widget.period;
    _sync();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _sync();
  }

  void _sync() {
    if (widget.count > 1 &&
        widget.frame == null &&
        _resumed &&
        TickerMode.valuesOf(context).enabled &&
        !MediaQuery.disableAnimationsOf(context)) {
      if (!_clock.isAnimating) _clock.repeat();
    } else {
      _clock.stop();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _clock.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final count = widget.sequence?.length ?? widget.count;
    final step = (_frame + widget.frameOffset) % count;
    final frame = widget.frame ?? widget.sequence?[step] ?? step;
    return Image.asset(
      'assets/images/lobby/frames/${widget.name}_$frame.png',
      fit: BoxFit.contain,
      gaplessPlayback: true,
      excludeFromSemantics: true,
    );
  }
}
