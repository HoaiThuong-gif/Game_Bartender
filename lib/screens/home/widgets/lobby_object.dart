import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../lobby_cats.dart';
import 'lobby_sprite.dart';

/// Each asset's small alpha mask is decoded once, rather than every frame.
final _masks = <String, _AlphaMask>{};

class _AlphaMask {
  const _AlphaMask(this.bytes, this.width, this.height);
  final Uint8List bytes;
  final int width;
  final int height;

  static Future<_AlphaMask> load(String asset) async {
    final cached = _masks[asset];
    if (cached != null) return cached;
    final data = await rootBundle.load(asset);
    final codec = await ui.instantiateImageCodec(
      data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      targetWidth: 192,
    );
    try {
      final frame = await codec.getNextFrame();
      try {
        final pixels = await frame.image.toByteData(
          format: ui.ImageByteFormat.rawRgba,
        );
        final mask = _AlphaMask(
          pixels!.buffer.asUint8List(),
          frame.image.width,
          frame.image.height,
        );
        _masks[asset] = mask;
        return mask;
      } finally {
        frame.image.dispose();
      }
    } finally {
      codec.dispose();
    }
  }

  bool contains(Offset position, Size size) {
    if (size.isEmpty || !(Offset.zero & size).contains(position)) return false;
    final x = (position.dx / size.width * width).floor();
    final y = (position.dy / size.height * height).floor();
    return bytes[(y * width + x) * 4 + 3] > 40;
  }
}

class LobbyObject extends StatefulWidget {
  const LobbyObject({
    super.key,
    required this.asset,
    required this.label,
    required this.onTap,
    this.game,
  });
  final String asset;
  final String label;
  final VoidCallback onTap;
  final LobbyGame? game;
  @override
  State<LobbyObject> createState() => _LobbyObjectState();
}

class _LobbyObjectState extends State<LobbyObject> {
  bool _pressed = false;
  late Future<_AlphaMask> _mask;

  @override
  void initState() {
    super.initState();
    _mask = _AlphaMask.load(widget.asset);
  }

  @override
  void reassemble() {
    super.reassemble();
    _masks.clear();
    rootBundle.evict(widget.asset);
    _mask = _AlphaMask.load(widget.asset);
  }

  @override
  void didUpdateWidget(covariant LobbyObject oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.asset != oldWidget.asset) {
      _mask = _AlphaMask.load(widget.asset);
    }
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<_AlphaMask>(
    future: _mask,
    builder: (context, snapshot) => Semantics(
      label: widget.label,
      button: true,
      onTap: widget.onTap,
      child: RepaintBoundary(
        child: _ObjectHitRegion(
          mask: snapshot.data,
          child: GestureDetector(
            excludeFromSemantics: true,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: _animatedImage(
              context,
              LobbySprite(
                name: switch (widget.game) {
                  LobbyGame.bartender => 'bartender',
                  LobbyGame.arcade => 'games',
                  LobbyGame.television => 'tv',
                  _ => 'rubik',
                },
                count: switch (widget.game) {
                  LobbyGame.arcade => 3,
                  LobbyGame.television => 4,
                  LobbyGame.rubik => 1,
                  _ => 12,
                },
                period: Duration(
                  milliseconds: widget.game == LobbyGame.bartender
                      ? 96000
                      : widget.game == LobbyGame.rubik
                      ? 5500
                      : 36000,
                ),
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Widget _animatedImage(BuildContext context, Widget image) {
    final atmosphere = LobbyEnvironment.maybeOf(context)?.atmosphere;
    final reduced = MediaQuery.disableAnimationsOf(context);
    if (atmosphere == null || widget.game == null) return image;
    return AnimatedBuilder(
      animation: atmosphere.repaint,
      child: image,
      builder: (context, child) {
        final selected = atmosphere.game == widget.game && !reduced;
        final t = selected ? atmosphere.animation.value : 0.0;
        final strength = selected
            ? atmosphere.entering
                  ? Curves.easeOut.transform(t)
                  : t < .18
                  ? Curves.easeOut.transform(t / .18)
                  : t < .72
                  ? 1.0
                  : 1 - Curves.easeInOut.transform((t - .72) / .28)
            : 0.0;
        final entry = selected && atmosphere.entering;
        final press = _pressed && !reduced ? 1.0 : 0.0;
        Widget result = CustomPaint(
          foregroundPainter: _CourtyardDetail(
            game: widget.game!,
            strength: math.max(strength, press * .35),
            progress: t,
            entering: entry,
            televisionScene: atmosphere.televisionScene,
            previousTelevisionScene: atmosphere.previousTelevisionScene,
            changingChannel: selected && !entry,
          ),
          child: child,
        );
        return result;
      },
    );
  }
}

/// Source-image coordinates keep light inside the existing glass/screens.
class _CourtyardDetail extends CustomPainter {
  const _CourtyardDetail({
    required this.game,
    required this.strength,
    required this.progress,
    required this.entering,
    required this.televisionScene,
    required this.previousTelevisionScene,
    required this.changingChannel,
  });
  final LobbyGame game;
  final double strength;
  final double progress;
  final bool entering;
  final int televisionScene;
  final int previousTelevisionScene;
  final bool changingChannel;

  @override
  void paint(Canvas canvas, Size size) {
    if (strength <= 0) return;
    canvas.save();
    canvas.scale(size.width, size.height);
    final paint = Paint()
      ..color = const Color(0xFFFFE6B1)
          .withValues(alpha: strength * (entering ? .48 : .22));
    switch (game) {
      case LobbyGame.arcade:
        final screen = Path()
          ..moveTo(.292, .344)
          ..lineTo(.499, .296)
          ..lineTo(.466, .518)
          ..lineTo(.248, .528)
          ..close();
        canvas.clipPath(screen);
        canvas.drawPath(screen, paint);
        final sweep = Rect.fromLTWH(.22 + progress * .3, .29, .035, .25);
        canvas.drawRect(
          sweep,
          Paint()
            ..shader = LinearGradient(
              colors: [
                const Color(0x00FFF0CC),
                const Color(0xFFFFF0CC).withValues(alpha: strength * .35),
                const Color(0x00FFF0CC),
              ],
            ).createShader(sweep),
        );
        // A small glint on the coin already painted in the source art.
        canvas.drawOval(
          const Rect.fromLTWH(.394, .417, .013, .023),
          Paint()
            ..color = const Color(0xFFFFE7A6).withValues(alpha: strength * .6),
        );
      case LobbyGame.television:
        const glass = Rect.fromLTWH(.17, .465, .47, .405);
        canvas.clipRRect(
          RRect.fromRectAndRadius(glass, const Radius.circular(.055)),
        );
        canvas.drawRect(glass, paint);
        final reflection = Rect.fromLTWH(.19 + progress * .06, .49, .36, .32);
        canvas.drawOval(
          reflection,
          Paint()
            ..shader = RadialGradient(
              colors: [
                const Color(0xFFE9DFB9).withValues(alpha: strength * .2),
                const Color(0x00E9DFB9),
              ],
            ).createShader(reflection),
        );
      case LobbyGame.bartender:
        const jar = Rect.fromLTWH(.56, .487, .052, .078);
        canvas.clipRect(jar);
        canvas.drawLine(
          Offset(.566 + progress * .036, .497),
          Offset(.566 + progress * .036, .551),
          Paint()
            ..color = const Color(0xFFFFEDC9).withValues(alpha: strength * .7)
            ..strokeWidth = .004
            ..strokeCap = StrokeCap.round,
        );
        for (var i = 0; i < 3; i++) {
          canvas.drawCircle(
            Offset(.573 + i * .012, .56 - progress * .065 + i * .008),
            .0045,
            Paint()
              ..color = const Color(0xFFFFE8B3)
                  .withValues(alpha: strength * .85),
          );
        }
      case LobbyGame.rubik:
        break;
    }
    canvas.restore();
  }

  @override
  bool shouldRepaint(_CourtyardDetail oldDelegate) =>
      game != oldDelegate.game ||
      strength != oldDelegate.strength ||
      progress != oldDelegate.progress ||
      entering != oldDelegate.entering ||
      televisionScene != oldDelegate.televisionScene ||
      previousTelevisionScene != oldDelegate.previousTelevisionScene ||
      changingChannel != oldDelegate.changingChannel;
}

class _ObjectHitRegion extends SingleChildRenderObjectWidget {
  const _ObjectHitRegion({required this.mask, required super.child});
  final _AlphaMask? mask;
  @override
  RenderObject createRenderObject(BuildContext context) => _AlphaHitBox(mask);
  @override
  void updateRenderObject(BuildContext context, _AlphaHitBox renderObject) {
    renderObject.mask = mask;
  }
}

class _AlphaHitBox extends RenderProxyBox {
  _AlphaHitBox(this.mask);
  _AlphaMask? mask;
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!(mask?.contains(position, size) ?? false)) return false;
    return super.hitTest(result, position: position);
  }
}
