import 'package:flutter/material.dart';

class AnimatedFlag extends StatefulWidget {
  const AnimatedFlag({
    super.key,
    required this.asset,
    required this.anchorAlignment,
  });
  final String asset;
  final Alignment anchorAlignment;
  @override
  State<AnimatedFlag> createState() => _AnimatedFlagState();
}

class _AnimatedFlagState extends State<AnimatedFlag>
    with SingleTickerProviderStateMixin {
  late final _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 2400),
  );
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (MediaQuery.disableAnimationsOf(context)) {
      _controller.stop();
      _controller.value = 0.5;
    } else {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => IgnorePointer(
    child: RepaintBoundary(
      child: AnimatedBuilder(
        animation: _controller,
        child: Image(
          image: AssetImage(widget.asset),
          fit: BoxFit.fill,
          excludeFromSemantics: true,
        ),
        builder: (context, child) => Transform.rotate(
          angle: (_controller.value - 0.5) * 0.018,
          alignment: widget.anchorAlignment,
          child: child,
        ),
      ),
    ),
  );
}
