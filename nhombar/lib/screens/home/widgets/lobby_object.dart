import 'dart:ui' as ui;
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

import '../lobby_cats.dart';
import '../lobby_layout.dart';
import 'lobby_panorama.dart';

final _program = ui.FragmentProgram.fromAsset('shaders/lobby_panorama.frag');

/// An independently replaceable source-projected PNG, including its exact alpha
/// silhouette. Both rendering and hit testing invert the same panorama camera.
class LobbyObject extends StatefulWidget {
  const LobbyObject({
    super.key,
    required this.asset,
    required this.placement,
    required this.label,
    required this.onTap,
    this.game,
  });
  final String asset, label;
  final LobbyPlacement placement;
  final VoidCallback? onTap;
  final LobbyGame? game;
  @override
  State<LobbyObject> createState() => _LobbyObjectState();
}

class _LobbyObjectState extends State<LobbyObject> {
  ui.Image? _image;
  ui.FragmentShader? _shader;
  Uint8List? _rgba;
  bool _failed = false;
  int _generation = 0;
  bool _pressed = false;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant LobbyObject oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.asset != widget.asset) _load();
  }

  @override
  void reassemble() {
    super.reassemble();
    _load();
  }

  Future<void> _load() async {
    final generation = ++_generation;
    try {
      final program = await _program;
      final data = await rootBundle.load(widget.asset);
      final codec = await ui.instantiateImageCodec(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      late ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
      }
      final bytes = widget.onTap == null
          ? null
          : await image.toByteData(format: ui.ImageByteFormat.rawRgba);
      if (!mounted || generation != _generation) {
        image.dispose();
        return;
      }
      final previous = _image;
      _shader?.dispose();
      setState(() {
        _image = image;
        _rgba = bytes?.buffer.asUint8List(
          bytes.offsetInBytes,
          bytes.lengthInBytes,
        );
        _shader = program.fragmentShader();
        _failed = false;
      });
      previous?.dispose();
    } catch (error) {
      debugPrint('[LobbyLayer] ${widget.asset}: $error');
      if (mounted && generation == _generation) setState(() => _failed = true);
    }
  }

  bool _contains(Offset point) {
    final camera = LobbyCamera.of(context);
    final pixel = camera.pixelAt(point);
    final rect = widget.placement.bounds;
    if (!rect.inflate(widget.placement.hitPadding).contains(pixel)) {
      return false;
    }
    if (_rgba == null || _image == null) return false;
    final uv = _mapUV(
      widget.placement,
      Offset(
        (pixel.dx - rect.left) / rect.width,
        (pixel.dy - rect.top) / rect.height,
      ),
    );
    final x = (uv.dx * _image!.width).floor();
    final y = (uv.dy * _image!.height).floor();
    final radius = widget.placement.hitPadding.ceil();
    for (var dy = -radius; dy <= radius; dy++) {
      for (var dx = -radius; dx <= radius; dx++) {
        final px = x + dx, py = y + dy;
        if (px >= 0 &&
            py >= 0 &&
            px < _image!.width &&
            py < _image!.height &&
            _rgba![(py * _image!.width + px) * 4 + 3] > 100) {
          return true;
        }
      }
    }
    return false;
  }

  @override
  void dispose() {
    _generation++;
    _shader?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final camera = LobbyCamera.of(context);
    if (_failed || _image == null || _shader == null) {
      return const SizedBox.expand();
    }
    final image = RepaintBoundary(
      child: CustomPaint(
        painter: _LayerPainter(
          _shader!,
          _image!,
          camera,
          widget.placement,
          interactive: widget.onTap != null,
          pressed: _pressed,
        ),
      ),
    );
    if (widget.onTap == null) return IgnorePointer(child: image);
    return _ProjectedHitRegion(
      contains: _contains,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapCancel: () => setState(() => _pressed = false),
        onTapUp: (_) => setState(() => _pressed = false),
        onTap: widget.onTap,
        child: image,
      ),
    );
  }
}

class _LayerPainter extends CustomPainter {
  _LayerPainter(
    this.shader,
    this.image,
    this.camera,
    this.placement, {
    this.interactive = false,
    this.pressed = false,
  });
  final bool interactive, pressed;
  final ui.FragmentShader shader;
  final ui.Image image;
  final LobbyCamera camera;
  final LobbyPlacement placement;
  @override
  void paint(Canvas canvas, Size size) {
    final region = placement.bounds;
    final clip = camera.paintBounds(region);
    if (clip.isEmpty) return;
    var h = _homography(placement);
    if (placement.planar) {
      final corners = placement.corners.length == 4
          ? placement.corners
          : [
              region.topLeft,
              region.topRight,
              region.bottomRight,
              region.bottomLeft,
            ];
      final projected = corners.map(camera.project).toList();
      if (projected.any((point) => point == null)) return;
      h = _solveHomography([
        for (final point in projected)
          Offset(point!.dx / size.width, point.dy / size.height),
      ]);
    }
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, camera.yaw)
      ..setFloat(3, camera.pitch)
      ..setFloat(4, math.tan(camera.fov / 2))
      ..setFloat(5, region.left / 1774)
      ..setFloat(6, region.top / 887)
      ..setFloat(7, region.width / 1774)
      ..setFloat(8, region.height / 887)
      ..setFloat(9, 1774)
      ..setFloat(10, 887)
      ..setImageSampler(0, image, filterQuality: FilterQuality.low);
    for (var i = 0; i < 9; i++) {
      shader.setFloat(11 + i, h[i]);
    }
    shader.setFloat(
      20,
      placement.planar
          ? 2
          : placement.warpToCorners
          ? 1
          : 0,
    );
    canvas.save();
    canvas.clipRect(clip);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
    if (pressed) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..shader = shader
          ..colorFilter = const ColorFilter.mode(
            Color(0x446ee7c5),
            BlendMode.srcATop,
          ),
      );
    }
    canvas.restore();
    if (interactive) {
      // A static marker costs no animation ticker or extra image decoding.
      // It follows the very same panorama camera as the object/hit region.
      final marker = camera.project(
        Offset(region.center.dx, region.top + region.height * .22),
      );
      if (marker != null && clip.contains(marker)) {
        canvas.drawCircle(marker, 9, Paint()..color = const Color(0xcc123d35));
        canvas.drawCircle(
          marker,
          6,
          Paint()
            ..color = const Color(0xffa7f3d0)
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2,
        );
        canvas.drawCircle(marker, 2, Paint()..color = Colors.white);
      }
    }
  }

  @override
  bool shouldRepaint(_LayerPainter oldDelegate) =>
      oldDelegate.camera != camera ||
      oldDelegate.image != image ||
      oldDelegate.pressed != pressed ||
      oldDelegate.interactive != interactive;
}

final _warpCache = <LobbyPlacement, List<double>>{};
List<double> _homography(LobbyPlacement placement) =>
    _warpCache.putIfAbsent(placement, () {
      if (!placement.warpToCorners || placement.corners.length != 4) {
        return [1, 0, 0, 0, 1, 0, 0, 0, 1];
      }
      final r = placement.bounds;
      return _solveHomography([
        for (final p in placement.corners)
          Offset((p.dx - r.left) / r.width, (p.dy - r.top) / r.height),
      ]);
    });

List<double> _solveHomography(List<Offset> points) {
  const targets = [Offset(0, 0), Offset(1, 0), Offset(1, 1), Offset(0, 1)];
  final rows = <List<double>>[];
  for (var i = 0; i < 4; i++) {
    final p = points[i], t = targets[i];
    final x = p.dx, y = p.dy;
    rows.add([x, y, 1, 0, 0, 0, -t.dx * x, -t.dx * y, t.dx]);
    rows.add([0, 0, 0, x, y, 1, -t.dy * x, -t.dy * y, t.dy]);
  }
  for (var col = 0; col < 8; col++) {
    var pivot = col;
    for (var row = col + 1; row < 8; row++) {
      if (rows[row][col].abs() > rows[pivot][col].abs()) pivot = row;
    }
    final tmp = rows[col];
    rows[col] = rows[pivot];
    rows[pivot] = tmp;
    final divisor = rows[col][col];
    if (divisor.abs() < 1e-10) return [1, 0, 0, 0, 1, 0, 0, 0, 1];
    for (var k = col; k < 9; k++) {
      rows[col][k] /= divisor;
    }
    for (var row = 0; row < 8; row++) {
      if (row == col) continue;
      final factor = rows[row][col];
      for (var k = col; k < 9; k++) {
        rows[row][k] -= factor * rows[col][k];
      }
    }
  }
  return [for (var i = 0; i < 8; i++) rows[i][8], 1];
}

Offset _mapUV(LobbyPlacement placement, Offset p) {
  final h = _homography(placement);
  final w = h[6] * p.dx + h[7] * p.dy + h[8];
  return Offset(
    (h[0] * p.dx + h[1] * p.dy + h[2]) / w,
    (h[3] * p.dx + h[4] * p.dy + h[5]) / w,
  );
}

class _ProjectedHitRegion extends SingleChildRenderObjectWidget {
  const _ProjectedHitRegion({required this.contains, required super.child});
  final bool Function(Offset) contains;
  @override
  RenderObject createRenderObject(BuildContext context) =>
      _ProjectedHitBox(contains);
  @override
  void updateRenderObject(
    BuildContext context,
    _ProjectedHitBox renderObject,
  ) => renderObject.contains = contains;
}

class _ProjectedHitBox extends RenderProxyBox {
  _ProjectedHitBox(this.contains);
  bool Function(Offset) contains;
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      contains(position) && super.hitTest(result, position: position);
}
