import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

import '../lobby_cats.dart';
import '../lobby_layout.dart';
import '../nam_cat_assets.dart';
import '../nam_cat_state_controller.dart';
import 'lobby_panorama.dart';

class NamCatCharacter extends StatefulWidget {
  const NamCatCharacter({
    super.key,
    required this.pose,
    required this.anchor,
    this.type = CatType.black,
    this.targetSize,
    this.onPoseChanged,
    this.onBusyChanged,
    this.sprites,
    this.sceneAnchor,
  });
  final CatPose pose;
  final Offset anchor;
  final CatType type;
  final Size? targetSize;
  final ValueChanged<CatPose>? onPoseChanged;
  final ValueChanged<bool>? onBusyChanged;
  final Future<NamSpriteSet>? sprites;
  final Offset? sceneAnchor;
  @override
  State<NamCatCharacter> createState() => _NamCatCharacterState();
}

class _NamCatCharacterState extends State<NamCatCharacter>
    with WidgetsBindingObserver {
  late final _state = CatStateController(
    widget.pose,
    hasFrame: (pose, expression) =>
        NamFrames.supports(pose, expression, widget.type),
  )..addListener(_changed);
  late final Future<NamSpriteSet> _sprites =
      widget.sprites ?? NamSpriteSet.load(type: widget.type);
  bool _resumed = true;
  bool _enabled = true;
  Offset? _lastHeadPoint;
  Duration? _strokeStart;
  double _travel = 0;
  int? _pointer;
  ValueChanged<int>? _releaseCamera;
  bool _didStroke = false;
  LobbyAtmosphere? _atmosphere;
  int _environmentEvent = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _resumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final atmosphere = LobbyEnvironment.maybeOf(context)?.atmosphere;
    if (atmosphere != _atmosphere) {
      _atmosphere?.removeListener(_environmentChanged);
      _atmosphere = atmosphere;
      _environmentEvent = atmosphere?.event ?? 0;
      atmosphere?.addListener(_environmentChanged);
    }
    _enabled = TickerMode.valuesOf(context).enabled;
    _state.setActive(_enabled && _resumed);
    _state.setIdleEnabled(!MediaQuery.disableAnimationsOf(context));
    if (!_enabled) {
      _releasePointer();
      _didStroke = true;
      _resetStroke();
      widget.onBusyChanged?.call(false);
    }
  }

  void _environmentChanged() {
    final atmosphere = _atmosphere;
    if (atmosphere == null || atmosphere.event == _environmentEvent) return;
    _environmentEvent = atmosphere.event;
    if (_pointer != null ||
        !_enabled ||
        !_resumed ||
        atmosphere.reactingCat != widget.type ||
        atmosphere.game == null) {
      return;
    }
    _state.noticeEnvironment(atmosphere.game!);
  }

  @override
  void didUpdateWidget(covariant NamCatCharacter oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.pose != _state.pose) {
      _resetStroke();
      _releasePointer();
      _didStroke = true;
      _state.setPose(widget.pose, notify: false);
      widget.onBusyChanged?.call(false);
    }
  }

  void _changed() {
    if (!mounted) return;
    widget.onBusyChanged?.call(_state.busy || _pointer != null);
    if (_state.pose != widget.pose) widget.onPoseChanged?.call(_state.pose);
    setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _state.setActive(_enabled && _resumed);
    if (!_resumed) {
      _releasePointer();
      _didStroke = true;
      _resetStroke();
      widget.onBusyChanged?.call(false);
    }
    if (mounted) setState(() {});
  }

  void _resetStroke() {
    _lastHeadPoint = null;
    _strokeStart = null;
    _travel = 0;
  }

  void _stroke(Offset point, Duration time, NamFrame frame, Size size) {
    // Once a head stroke starts, authored face movement must not cancel it.
    // Pointer up/cancel still ends the reaction immediately.
    if (_didStroke) return;
    if (!frame.opaque(point, size) ||
        frame.region(point, size) != CatRegion.head) {
      _resetStroke();
      _state.endHeadStroke();
      return;
    }
    _strokeStart ??= time;
    if (_lastHeadPoint != null) _travel += (point - _lastHeadPoint!).distance;
    _lastHeadPoint = point;
    // Use local proportions so thresholds follow the character's actual size.
    if (time - _strokeStart! >= const Duration(milliseconds: 250) &&
        _travel >= size.width * .12) {
      _state.startHeadStroke();
      _didStroke = true;
    }
  }

  void _finishPointer(PointerEvent event) {
    if (event.pointer != _pointer) return;
    _releasePointer();
    _resetStroke();
    _state.endHeadStroke();
    widget.onBusyChanged?.call(_state.busy);
  }

  void _releasePointer() {
    final pointer = _pointer;
    _pointer = null;
    if (pointer != null) _releaseCamera?.call(pointer);
    _releaseCamera = null;
  }

  @override
  void dispose() {
    _releasePointer();
    _atmosphere?.removeListener(_environmentChanged);
    WidgetsBinding.instance.removeObserver(this);
    _state.removeListener(_changed);
    _state.dispose();
    widget.onBusyChanged?.call(false);
    if (widget.sprites == null) {
      _sprites.then((sprites) => sprites.dispose(), onError: (Object _) {});
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<NamSpriteSet>(
    future: _sprites,
    builder: (context, snapshot) {
      if (snapshot.hasError) {
        return const Center(
          child: Tooltip(
            message: 'Không tải được ảnh Nam',
            child: Icon(Icons.broken_image_outlined),
          ),
        );
      }
      if (!snapshot.hasData) return const SizedBox();
      final frame = snapshot.data!.frames[(_state.pose, _state.expression)]!;
      return LayoutBuilder(
        builder: (context, constraints) {
          final viewport = MediaQuery.sizeOf(context);
          if (viewport.isEmpty) return const SizedBox();
          final scene = LobbyLayout.designSize;
          final cover = math.max(
            viewport.width / scene.width,
            viewport.height / scene.height,
          );
          final target =
              widget.targetSize ??
              Size(constraints.maxWidth * .82, constraints.maxHeight * .8);
          var referenceScale = math.min(
            target.width / frame.referenceSize.width,
            target.height / frame.referenceSize.height,
          );
          final contact = frame.contactPoint;
          // Size the painted character rather than its transparent canvas.
          // Cover crops narrow phones; keep feet at the same surface height.
          // This is static layout sizing, never a touch/idle animation.
          if (widget.sceneAnchor case final point?) {
            final left = (scene.width - viewport.width / cover) / 2;
            final top = (scene.height - viewport.height / cover) / 2;
            final margin = 4 / cover;
            final headRoom = point.dy - top - margin;
            final leftRoom = point.dx - left - margin;
            final rightRoom = scene.width - left - margin - point.dx;
            // Reduce only to the available surface/viewport space. Never move
            // the paws away from their designated seat to fit the tail.
            for (final entry in snapshot.data!.frames.entries.where(
              (entry) => entry.key.$1 == _state.pose,
            )) {
              final variant = entry.value;
              final units = variant.pixelsPerReferenceUnit;
              final support = variant.contactPoint;
              referenceScale = math.max(
                0,
                math.min(
                  referenceScale,
                  math.min(
                    headRoom / ((support.dy - variant.bounds.top) / units),
                    math.min(
                      leftRoom / ((support.dx - variant.bounds.left) / units),
                      rightRoom / ((variant.bounds.right - support.dx) / units),
                    ),
                  ),
                ),
              );
            }
          }
          final scale = referenceScale / frame.pixelsPerReferenceUnit;
          final display = Size(
            frame.image.width * scale,
            frame.image.height * scale,
          );
          return Stack(
            clipBehavior: Clip.none,
            children: [
              Positioned(
                left:
                    constraints.maxWidth * widget.anchor.dx -
                    contact.dx * scale,
                top:
                    constraints.maxHeight * widget.anchor.dy -
                    contact.dy * scale,
                width: display.width,
                height: display.height,
                child: Semantics(
                  label:
                      'Mèo ${NamFrames.name(widget.type)}, ${NamFrames.label(_state.pose)}, ${_state.expression.name}',
                  child: _NamHitRegion(
                    frame: frame,
                    child: Listener(
                      key: ValueKey(
                        '${NamFrames.name(widget.type).toLowerCase()}-interaction',
                      ),
                      behavior: HitTestBehavior.opaque,
                      // Pointer distances are relative to Nam, rather than the
                      // fixed pan slop which can exceed a small cat's head.
                      onPointerDown: (event) {
                        if (_pointer != null || !_enabled || !_resumed) return;
                        _pointer = event.pointer;
                        final camera = LobbyCamera.maybeOf(context);
                        _releaseCamera = camera?.onCatTouchEnd;
                        camera?.onCatTouchStart?.call(event.pointer);
                        _didStroke = false;
                        _resetStroke();
                        _stroke(
                          event.localPosition,
                          event.timeStamp,
                          frame,
                          display,
                        );
                        widget.onBusyChanged?.call(true);
                      },
                      onPointerMove: (event) {
                        if (event.pointer == _pointer) {
                          _stroke(
                            event.localPosition,
                            event.timeStamp,
                            frame,
                            display,
                          );
                        }
                      },
                      onPointerUp: _finishPointer,
                      onPointerCancel: (event) {
                        _didStroke = true;
                        _finishPointer(event);
                      },
                      child: GestureDetector(
                        behavior: HitTestBehavior.opaque,
                        // Claim a drag that starts on opaque cat pixels. Raw
                        // pointer strokes still work; the parent scale/pan
                        // recognizer must not drag the apartment as well.
                        onPanStart: (_) {},
                        onPanUpdate: (_) {},
                        onPanEnd: (_) {},
                        onTapUp: (details) {
                          if (_didStroke) return;
                          _state.tap(
                            frame.region(details.localPosition, display),
                          );
                          widget.onBusyChanged?.call(_state.busy);
                        },
                        child: RawImage(
                          image: frame.image,
                          fit: BoxFit.contain,
                          filterQuality: FilterQuality.high,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      );
    },
  );
}

class _NamHitRegion extends SingleChildRenderObjectWidget {
  const _NamHitRegion({required this.frame, required super.child});
  final NamFrame frame;
  @override
  RenderObject createRenderObject(BuildContext context) => _NamHitBox(frame);
  @override
  void updateRenderObject(BuildContext context, _NamHitBox renderObject) {
    renderObject.frame = frame;
  }
}

class _NamHitBox extends RenderProxyBox {
  _NamHitBox(this.frame);
  NamFrame frame;
  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) =>
      frame.opaque(position, size) && super.hitTest(result, position: position);
}
