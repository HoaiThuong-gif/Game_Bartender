import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/cozy_loading.dart';

import 'package:sensors_plus/sensors_plus.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../controllers/bartender_controller.dart';
import '../models/processing_rules.dart';
import '../models/station.dart';
import '../scene3d/scene_bundle.dart';
import '../services/bartender_scene_bridge.dart';
import '../services/shake_detector.dart';

/// Native Flutter HUD + one offline Three.js playfield. Clock ticks do not
/// recreate the WebView or send frames through the Flutter/JavaScript bridge.
class BartenderSceneView extends StatefulWidget {
  const BartenderSceneView({
    super.key,
    required this.controller,
    required this.fallback,
    this.onUnavailable,
  });

  final BartenderController controller;
  final Widget fallback;
  final VoidCallback? onUnavailable;

  @override
  State<BartenderSceneView> createState() => _BartenderSceneViewState();
}

class _BartenderSceneViewState extends State<BartenderSceneView>
    with WidgetsBindingObserver {
  static Future<void> _previousRelease = Future<void>.value();
  WebViewController? _web;
  late BartenderSceneBridge _bridge;
  StreamSubscription<UserAccelerometerEvent>? _sensor;
  final _shake = ShakeDetector();
  StationType? _lastStation;
  String? _selectedId;
  String? _sent;
  String? _failure;
  bool _ready = false;
  bool _sending = false;
  bool _acting = false;
  bool _resumed = true;
  bool _disposed = false;
  bool _sensorAvailable = true;
  bool _receivedSensor = false;
  Timer? _timeout;
  Timer? _sensorTimeout;
  Future<void>? _boot;
  Future<void>? _releaseFuture;

  bool get _supported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  void initState() {
    super.initState();
    _bridge = BartenderSceneBridge(widget.controller);
    widget.controller.addListener(_changed);
    WidgetsBinding.instance.addObserver(this);
    _resumed =
        WidgetsBinding.instance.lifecycleState == null ||
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed;
    if (_supported) {
      _boot = _start();
      _setupSensor();
    }
  }

  Future<void> _start() async {
    try {
      _timeout = Timer(const Duration(seconds: 25), () => unawaited(_fail()));
      await _previousRelease.timeout(const Duration(seconds: 6));
      if (_disposed) return;
      final controller = WebViewController();
      _web = controller;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0xFFEAD4AF));
      await controller.addJavaScriptChannel(
        'Bartender3D',
        onMessageReceived: (message) => _message(message.message),
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              request.url == 'about:blank' || request.url.startsWith('data:')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) unawaited(_fail());
          },
        ),
      );
      if (_disposed) return;
      setState(() {});
      // Bundle is compiled from the local installed Three.js. No CDN requests.
      final script = bartenderSceneScript.replaceAll('</script', r'<\/script');
      await controller.loadHtmlString(
        '<!doctype html><html lang="vi"><head>'
        '<meta charset="utf-8"><meta name="viewport" '
        'content="width=device-width,initial-scale=1,maximum-scale=1,user-scalable=no">'
        '</head><body><script>$script</script></body></html>',
      );
    } catch (_) {
      if (!_disposed) await _fail();
    }
  }

  void _changed() {
    if (_disposed) return;
    if (_lastStation != widget.controller.myStation && _supported) {
      _setupSensor();
    }
    unawaited(_flush());
  }

  Future<void> _flush({bool force = false}) async {
    if (force) _sent = null;
    if (!_ready || _sending || _disposed || _failure != null) return;
    _sending = true;
    try {
      while (!_disposed && _ready) {
        final next = _bridge.encodedSnapshot;
        if (next == _sent) break;
        await _web?.runJavaScript('window.setBartenderState?.($next);');
        _sent = next;
      }
    } catch (_) {
      if (!_disposed) unawaited(_fail());
    } finally {
      _sending = false;
    }
  }

  void _message(String raw) {
    if (_disposed || _failure != null || raw.length > 4096) return;
    try {
      final data = jsonDecode(raw);
      if (data is! Map<String, dynamic>) return;
      switch (data['type']) {
        case 'ready':
          _timeout?.cancel();
          setState(() => _ready = true);
          unawaited(_flush(force: true));
          _updateActivity();
          _sendSensorStatus();
        case 'selected':
          _selectedId = data['id'] as String?;
        case 'action':
          unawaited(_action(raw));
        case 'error':
          unawaited(_fail());
      }
    } catch (_) {
      // Ignore malformed renderer messages; Dart owns the game state.
    }
  }

  Future<void> _action(String raw, {bool fromSensor = false}) async {
    if (_acting || !_resumed || _disposed) return;
    _acting = true;
    try {
      await _bridge.handle(raw, allowShake: fromSensor || !_sensorAvailable);
    } finally {
      _acting = false;
      if (!_disposed) {
        await _flush(force: true); // Release pending even on no-op.
      }
    }
  }

  void _setupSensor() {
    unawaited(_sensor?.cancel());
    _sensor = null;
    _sensorTimeout?.cancel();
    _shake.reset();
    _lastStation = widget.controller.myStation;
    if (_lastStation != StationType.shaker || !_resumed || _disposed) return;
    _sensorAvailable = ShakeSensorConfig.isSensorAvailableOverride ?? true;
    _receivedSensor = false;
    _sendSensorStatus();
    if (!_sensorAvailable) return;
    _sensorTimeout = Timer(const Duration(seconds: 3), () {
      if (!_receivedSensor && !_disposed) {
        _sensorAvailable = false;
        _sendSensorStatus();
      }
    });
    _sensor = (ShakeSensorConfig.customStream ?? userAccelerometerEventStream())
        .listen(
          (event) {
            if (_disposed || !_resumed) return;
            if (!_receivedSensor) {
              _receivedSensor = true;
              _sensorAvailable = true;
              _sensorTimeout?.cancel();
              _sendSensorStatus();
            }
            if (!_shake.addSample(
              event.x,
              event.y,
              event.z,
              event.timestamp.millisecondsSinceEpoch,
            )) {
              return;
            }
            final eligible = widget.controller.myItems
                .where(
                  (item) =>
                      processItem(item.itemId, StationType.shaker) != null,
                )
                .toList();
            if (eligible.isEmpty) return;
            final selected = eligible.where((item) => item.id == _selectedId);
            final item = selected.isEmpty ? eligible.first : selected.first;
            unawaited(
              _action(
                jsonEncode({
                  'action': 'process',
                  'id': item.id,
                  'round': widget.controller.room?.currentRound?.number,
                }),
                fromSensor: true,
              ),
            );
          },
          onError: (Object error) {
            _sensorAvailable = false;
            _sendSensorStatus();
          },
        );
  }

  void _sendSensorStatus() {
    if (_ready && !_disposed) {
      unawaited(
        _web
            ?.runJavaScript('window.setBartenderSensor?.($_sensorAvailable);')
            .catchError((Object _) {}),
      );
    }
  }

  void _updateActivity() {
    if (_ready && !_disposed) {
      unawaited(
        _web
            ?.runJavaScript('window.setBartenderActive?.($_resumed);')
            .catchError((Object _) {}),
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    _updateActivity();
    _setupSensor();
  }

  Future<void> _fail() async {
    if (_disposed || _failure != null) return;
    _timeout?.cancel();
    _ready = false;
    _failure = 'Không tải được cảnh 3D. Bạn có thể tiếp tục chơi ở chế độ nhẹ.';
    await _release();
    if (mounted && !_disposed) {
      widget.onUnavailable?.call();
      setState(() {});
    }
  }

  Future<void> _release() => _releaseFuture ??= _previousRelease = (() async {
    final web = _web;
    _web = null;
    if (web == null) return;
    try {
      await web
          .runJavaScript('window.disposeBartender?.();')
          .timeout(const Duration(seconds: 2));
      await web
          .loadRequest(Uri.parse('about:blank'))
          .timeout(const Duration(seconds: 2));
    } catch (_) {
      // The Android platform view may already have been destroyed.
    }
  })();

  @override
  void dispose() {
    _disposed = true;
    _timeout?.cancel();
    _sensorTimeout?.cancel();
    unawaited(_sensor?.cancel());
    widget.controller.removeListener(_changed);
    WidgetsBinding.instance.removeObserver(this);
    // Wait for an in-flight load to finish before blanking its platform view.
    final release = (_boot ?? Future<void>.value())
        .timeout(const Duration(seconds: 6), onTimeout: () {})
        .then((_) => _release());
    _previousRelease = release;
    unawaited(release);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_supported) return widget.fallback;
    if (_failure != null) {
      return Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8),
            child: Text(
              _failure!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Color(0xFF733712), fontSize: 11),
            ),
          ),
          Expanded(child: widget.fallback),
        ],
      );
    }
    return Stack(
      fit: StackFit.expand,
      children: [
        if (_web != null)
          WebViewWidget(
            key: const ValueKey('bartender-3d-playfield'),
            controller: _web!,
            gestureRecognizers: {
              Factory<OneSequenceGestureRecognizer>(
                () => EagerGestureRecognizer(),
              ),
            },
          ),
        if (!_ready && !widget.controller.isBusy)
          const ColoredBox(
            color: Color(0xFFEAD4AF),
            child: CozyLoading(label: 'Đang chuẩn bị quầy pha chế…'),
          ),
      ],
    );
  }
}
