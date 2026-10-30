import 'dart:math' as math;
import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../lobby_layout.dart';

/// One camera drives both the inverse panorama shader and forward actor planes.
class LobbyCamera extends InheritedWidget {
  const LobbyCamera({
    super.key,
    required this.yaw,
    required this.pitch,
    required this.fov,
    required this.viewport,
    this.onCatTouchStart,
    this.onCatTouchEnd,
    required super.child,
  });
  final double yaw, pitch, fov;
  final Size viewport;
  final ValueChanged<int>? onCatTouchStart, onCatTouchEnd;
  static LobbyCamera? maybeOf(BuildContext context) =>
      context.getInheritedWidgetOfExactType<LobbyCamera>();
  static LobbyCamera of(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<LobbyCamera>()!;

  (double, double, double) _view(double x, double y, double z) {
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final forward = sy * x + cy * z;
    return (cy * x - sy * z, cp * y - sp * forward, sp * y + cp * forward);
  }

  /// Plane coordinates use the original 1672-unit cat authoring height.
  /// Sizes/pose ratios are unchanged; only camera perspective changes them.
  Matrix4? plane(Offset pixel, Size size, Offset anchor) {
    final lon = (pixel.dx / 1774 - .5) * math.pi * 2;
    final lat = (.5 - pixel.dy / 887) * math.pi;
    final sl = math.sin(lon), cl = math.cos(lon);
    final st = math.sin(lat), ct = math.cos(lat);
    final center = _view(sl * ct, st, cl * ct);
    if (center.$3 < .18) return null;
    final unit = 2 * math.tan(75 * math.pi / 360) / 1672;
    final right = _view(cl * unit, 0, -sl * unit);
    final down = _view(sl * st * unit, -ct * unit, cl * st * unit);
    final origin = (
      center.$1 -
          right.$1 * size.width * anchor.dx -
          down.$1 * size.height * anchor.dy,
      center.$2 -
          right.$2 * size.width * anchor.dx -
          down.$2 * size.height * anchor.dy,
      center.$3 -
          right.$3 * size.width * anchor.dx -
          down.$3 * size.height * anchor.dy,
    );
    final focal = viewport.height / (2 * math.tan(fov / 2));
    final cx = viewport.width / 2, cy = viewport.height / 2;
    final matrix = Matrix4.zero()..setEntry(2, 2, 1);
    void column(int col, (double, double, double) v) {
      matrix.setEntry(0, col, focal * v.$1 + cx * v.$3);
      matrix.setEntry(1, col, -focal * v.$2 + cy * v.$3);
      matrix.setEntry(3, col, v.$3);
    }

    column(0, right);
    column(1, down);
    column(3, origin);
    return matrix;
  }

  /// Cats are upright sprites, unlike the calibrated furniture planes. Project
  /// their contact onto the sphere, but keep their angular size independent of
  /// 1 / camera-z, which can explode when an off-axis plane crosses the eye.
  Matrix4? actorPlane(Offset pixel, Size size, Offset anchor) {
    final contact = project(pixel);
    if (contact == null || size.isEmpty) return null;
    final focal = viewport.height / (2 * math.tan(fov / 2));
    final unit = 2 * math.tan(75 * math.pi / 360) / 1672;
    final scale = math.min(focal * unit, viewport.height * .42 / size.height);
    final left = contact.dx - size.width * anchor.dx * scale;
    final top = contact.dy - size.height * anchor.dy * scale;
    final bounds = Rect.fromLTWH(
      left,
      top,
      size.width * scale,
      size.height * scale,
    );
    if (!bounds.overlaps(Offset.zero & viewport)) return null;
    return Matrix4.identity()
      ..setEntry(0, 0, scale)
      ..setEntry(1, 1, scale)
      ..setEntry(0, 3, left)
      ..setEntry(1, 3, top);
  }

  Offset pixelAt(Offset screen) {
    final k = 2 * math.tan(fov / 2) / viewport.height;
    final x = (screen.dx - viewport.width / 2) * k;
    final y = -(screen.dy - viewport.height / 2) * k;
    final cp = math.cos(pitch), sp = math.sin(pitch);
    final cy = math.cos(yaw), sy = math.sin(yaw);
    final wy = y * cp + sp;
    final wz = cp - y * sp;
    final wx = x * cy + wz * sy;
    final zz = wz * cy - x * sy;
    final lon = math.atan2(wx, zz);
    final lat = math.asin((wy / math.sqrt(x * x + y * y + 1)).clamp(-1.0, 1.0));
    return Offset(
      (lon / (2 * math.pi) + .5) * 1774,
      (.5 - lat / math.pi) * 887,
    );
  }

  Offset? project(Offset pixel) {
    final lon = (pixel.dx / 1774 - .5) * 2 * math.pi;
    final lat = (.5 - pixel.dy / 887) * math.pi;
    final p = _view(
      math.sin(lon) * math.cos(lat),
      math.sin(lat),
      math.cos(lon) * math.cos(lat),
    );
    if (p.$3 <= .025) return null;
    final focal = viewport.height / (2 * math.tan(fov / 2));
    return Offset(
      viewport.width / 2 + focal * p.$1 / p.$3,
      viewport.height / 2 - focal * p.$2 / p.$3,
    );
  }

  /// Conservative curved-patch bounds reduce fill cost for many PNG layers.
  Rect paintBounds(Rect source) {
    final points = <Offset>[];
    var clipped = false;
    for (var i = 0; i <= 8; i++) {
      final t = i / 8;
      for (final p in [
        Offset(source.left + source.width * t, source.top),
        Offset(source.left + source.width * t, source.bottom),
        Offset(source.left, source.top + source.height * t),
        Offset(source.right, source.top + source.height * t),
      ]) {
        final projected = project(p);
        if (projected == null) {
          clipped = true;
        } else {
          points.add(projected);
        }
      }
    }
    if (points.isEmpty) return Rect.zero;
    if (clipped) return Offset.zero & viewport;
    var result = Rect.fromPoints(points.first, points.first);
    for (final p in points.skip(1)) {
      result = result.expandToInclude(Rect.fromPoints(p, p));
    }
    return result.inflate(3).intersect(Offset.zero & viewport);
  }

  @override
  bool updateShouldNotify(LobbyCamera oldWidget) =>
      yaw != oldWidget.yaw ||
      pitch != oldWidget.pitch ||
      fov != oldWidget.fov ||
      viewport != oldWidget.viewport;
}

class PanoramaActor extends StatelessWidget {
  const PanoramaActor({
    super.key,
    required this.contact,
    required this.size,
    required this.anchor,
    required this.child,
  });
  final Offset contact, anchor;
  final Size size;
  final Widget child;
  @override
  Widget build(BuildContext context) {
    final matrix = LobbyCamera.of(context).actorPlane(contact, size, anchor);
    return Positioned(
      left: 0,
      top: 0,
      width: size.width,
      height: size.height,
      child: Transform(
        transform: matrix ?? Matrix4.identity(),
        alignment: Alignment.topLeft,
        child: Offstage(offstage: matrix == null, child: child),
      ),
    );
  }
}

class LobbyViewController extends ChangeNotifier {
  Offset? focus;
  String imageInfo = '';
  String gpuInfo = '';
  void lookAt(Offset pixel) {
    focus = pixel;
    notifyListeners();
  }
}

class LobbyPanorama extends StatefulWidget {
  const LobbyPanorama({super.key, required this.children, this.controller});
  final LobbyViewController? controller;
  final List<Widget> children;
  @override
  State<LobbyPanorama> createState() => _LobbyPanoramaState();
}

class _LobbyPanoramaState extends State<LobbyPanorama>
    with SingleTickerProviderStateMixin {
  ui.Image? _image;
  ui.FragmentShader? _shader;
  Object? _error;
  double _yaw = 0, _pitch = -.28, _fov = 75 * math.pi / 180;
  double _startFov = 0;
  Size _viewport = Size.zero;
  Offset _last = Offset.zero, _velocity = Offset.zero;
  late final AnimationController _coast = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 650),
  )..addListener(_inertia);
  double _previous = 0;
  final _catPointers = <int>{};
  bool _gestureOnCat = false;

  void _catTouchStart(int pointer) {
    _catPointers.add(pointer);
    _gestureOnCat = true;
    _coast.stop();
  }

  void _catTouchEnd(int pointer) {
    _catPointers.remove(pointer);
  }

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_focus);
    _load();
  }

  void _focus() {
    final point = widget.controller?.focus;
    if (point == null) return;
    _coast.stop();
    setState(() {
      _yaw = (point.dx / 1774 - .5) * 2 * math.pi;
      _pitch = (.5 - point.dy / 887) * math.pi;
    });
  }

  Future<void> _load() async {
    try {
      final program = await ui.FragmentProgram.fromAsset(
        'shaders/lobby_panorama.frag',
      );
      final data = await rootBundle.load(LobbyLayout.backgroundAsset);
      final buffer = await ui.ImmutableBuffer.fromUint8List(
        data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes),
      );
      final descriptor = await ui.ImageDescriptor.encoded(buffer);
      final encoded = Size(
        descriptor.width.toDouble(),
        descriptor.height.toDouble(),
      );
      final codec = await descriptor.instantiateCodec();
      late ui.Image image;
      try {
        image = (await codec.getNextFrame()).image;
      } finally {
        codec.dispose();
        descriptor.dispose();
        buffer.dispose();
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      final info =
          'source=${encoded.width.toInt()}x${encoded.height.toInt()} '
          'decoded=${image.width}x${image.height} bilinear/no mipmap';
      debugPrint('[LobbyPanorama] $info');
      widget.controller?.imageInfo = info;
      try {
        final gpu = await const MethodChannel('meomeo/lobby')
            .invokeMapMethod<String, dynamic>('gpuInfo');
        final gpuInfo =
            'GL_MAX_TEXTURE_SIZE=${gpu?['maxTextureSize']} ${gpu?['renderer']}';
        debugPrint('[LobbyPanorama] $gpuInfo');
        widget.controller?.gpuInfo = gpuInfo;
      } on PlatformException catch (error) {
        debugPrint('[LobbyPanorama] GPU query unavailable: ${error.message}');
      } on MissingPluginException {
        debugPrint('[LobbyPanorama] GPU query not supported on this platform');
      }
      if (!mounted) {
        image.dispose();
        return;
      }
      setState(() {
        _image = image;
        _shader = program.fragmentShader();
      });
    } catch (error) {
      if (mounted) setState(() => _error = error);
    }
  }

  void _move(Offset delta, Size size) {
    final radiansPerPixel = 2 * math.tan(_fov / 2) / size.height;
    _yaw =
        (_yaw - delta.dx * radiansPerPixel + math.pi) % (2 * math.pi) - math.pi;
    _pitch = (_pitch + delta.dy * radiansPerPixel).clamp(-1.38, 1.38);
  }

  void _inertia() {
    final dt = _coast.value - _previous;
    _previous = _coast.value;
    if (!mounted ||
        _viewport.isEmpty ||
        !TickerMode.valuesOf(context).enabled) {
      return;
    }
    setState(
      () => _move(
        _velocity * (.65 * dt * math.pow(1 - _coast.value, 2)),
        _viewport,
      ),
    );
  }

  @override
  void dispose() {
    widget.controller?.removeListener(_focus);
    _coast.dispose();
    _shader?.dispose();
    _image?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final size = constraints.biggest;
      _viewport = size;
      if (_error != null) {
        return Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Không tải được panorama.'),
              TextButton(
                onPressed: () {
                  setState(() => _error = null);
                  _load();
                },
                child: const Text('Thử lại'),
              ),
            ],
          ),
        );
      }
      if (_image == null || _shader == null) {
        return const Center(child: CircularProgressIndicator());
      }
      return LobbyCamera(
        yaw: _yaw,
        pitch: _pitch,
        fov: _fov,
        viewport: size,
        onCatTouchStart: _catTouchStart,
        onCatTouchEnd: _catTouchEnd,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onScaleStart: (details) {
            _coast.stop();
            _gestureOnCat = _catPointers.isNotEmpty;
            _last = details.localFocalPoint;
            _startFov = _fov;
          },
          onScaleUpdate: (details) {
            if (_gestureOnCat || _catPointers.isNotEmpty) {
              _last = details.localFocalPoint;
              return;
            }
            setState(() {
              _move(details.localFocalPoint - _last, size);
              _last = details.localFocalPoint;
              _fov = (_startFov / details.scale).clamp(
                60 * math.pi / 180,
                85 * math.pi / 180,
              );
            });
          },
          onScaleEnd: (details) {
            if (_gestureOnCat || _catPointers.isNotEmpty) return;
            if (MediaQuery.disableAnimationsOf(context)) return;
            _velocity = details.velocity.pixelsPerSecond;
            if (_velocity.distance > 80) {
              _previous = 0;
              _coast.forward(from: 0);
            }
          },
          child: ClipRect(
            child: Stack(
              clipBehavior: Clip.none,
              children: [
                Positioned.fill(
                  child: RepaintBoundary(
                    child: CustomPaint(
                      painter: _PanoramaPainter(
                        _shader!,
                        _image!,
                        _yaw,
                        _pitch,
                        _fov,
                      ),
                    ),
                  ),
                ),
                ...widget.children,
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 14,
                  child: IgnorePointer(
                    child: SafeArea(
                      top: false,
                      child: Center(
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: const Color(0x88000000),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: const Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 7,
                            ),
                            child: Text(
                              'Vuốt để nhìn quanh · Chụm để thu phóng',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _PanoramaPainter extends CustomPainter {
  _PanoramaPainter(this.shader, this.image, this.yaw, this.pitch, this.fov);
  final ui.FragmentShader shader;
  final ui.Image image;
  final double yaw, pitch, fov;
  @override
  void paint(Canvas canvas, Size size) {
    shader
      ..setFloat(0, size.width)
      ..setFloat(1, size.height)
      ..setFloat(2, yaw)
      ..setFloat(3, pitch)
      ..setFloat(4, math.tan(fov / 2))
      ..setFloat(5, 0)
      ..setFloat(6, 0)
      ..setFloat(7, 1)
      ..setFloat(8, 1)
      ..setFloat(9, image.width.toDouble())
      ..setFloat(10, image.height.toDouble())
      ..setFloat(11, 1)
      ..setFloat(12, 0)
      ..setFloat(13, 0)
      ..setFloat(14, 0)
      ..setFloat(15, 1)
      ..setFloat(16, 0)
      ..setFloat(17, 0)
      ..setFloat(18, 0)
      ..setFloat(19, 1)
      ..setFloat(20, 0)
      ..setImageSampler(0, image, filterQuality: FilterQuality.low);
    canvas.drawRect(Offset.zero & size, Paint()..shader = shader);
  }

  @override
  bool shouldRepaint(_PanoramaPainter oldDelegate) => true;
}
