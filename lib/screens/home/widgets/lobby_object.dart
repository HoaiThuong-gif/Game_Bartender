import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

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
    this.anchorAlignment = Alignment.bottomCenter,
  });
  final String asset;
  final String label;
  final VoidCallback onTap;
  final Alignment anchorAlignment;
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
      child: AnimatedScale(
        alignment: widget.anchorAlignment,
        scale: _pressed ? 0.96 : 1,
        duration: const Duration(milliseconds: 90),
        child: _ObjectHitRegion(
          mask: snapshot.data,
          child: GestureDetector(
            excludeFromSemantics: true,
            onTapDown: (_) => setState(() => _pressed = true),
            onTapCancel: () => setState(() => _pressed = false),
            onTapUp: (_) => setState(() => _pressed = false),
            onTap: widget.onTap,
            child: Image.asset(
              widget.asset,
              fit: BoxFit.fill,
              excludeFromSemantics: true,
            ),
          ),
        ),
      ),
    ),
  );
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
