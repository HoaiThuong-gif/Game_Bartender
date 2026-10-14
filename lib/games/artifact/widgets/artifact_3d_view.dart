import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/artifact_puzzle.dart';

class Artifact3DView extends StatefulWidget {
  const Artifact3DView({
    super.key,
    required this.snapshot,
    required this.onAction,
    required this.onSelect,
    required this.onReady,
    required this.onBusy,
    required this.onComplete,
  });

  final Map<String, Object> snapshot;
  final bool Function(ArtifactAction) onAction;
  final void Function(ArtifactMechanism, int) onSelect;
  final ValueChanged<bool> onReady;
  final ValueChanged<bool> onBusy;
  final void Function(int, int) onComplete;

  @override
  State<Artifact3DView> createState() => _Artifact3DViewState();
}

class _Artifact3DViewState extends State<Artifact3DView>
    with WidgetsBindingObserver {
  late final WebViewController _web;
  Timer? _timeout;
  bool _ready = false;
  bool _resumed = true;
  bool _sending = false;
  bool _disposed = false;
  String? _pending;
  String? _failure;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _resumed = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFECE0C9))
      ..addJavaScriptChannel('ArtifactGame', onMessageReceived: _message)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) => _ready = false,
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) _fail();
          },
        ),
      );
    _load();
  }

  void _load() {
    _timeout?.cancel();
    _ready = false;
    _failure = null;
    _pending = jsonEncode(widget.snapshot);
    unawaited(
      _web
          .loadFlutterAsset('assets/artifact/index.html')
          .catchError((Object _) => _fail()),
    );
    _timeout = Timer(const Duration(seconds: 25), _fail);
  }

  void _fail() {
    if (!mounted || _disposed) return;
    _timeout?.cancel();
    setState(() {
      _ready = false;
      _failure = 'Chưa tải được cổ vật 3D. Hãy thử lại.';
    });
    widget.onReady(false);
    widget.onBusy(false);
  }

  void _message(JavaScriptMessage message) {
    if (!mounted || _disposed) return;
    try {
      final data = jsonDecode(message.message) as Map<String, dynamic>;
      final type = data['type'];
      if (type == 'error') {
        _fail();
        return;
      }
      if (type == 'ready') {
        _timeout?.cancel();
        setState(() {
          _ready = true;
          _failure = null;
        });
        widget.onReady(true);
        _queueSnapshot();
        unawaited(_setActive());
        return;
      }
      if (data['epoch'] != widget.snapshot['epoch'] ||
          data['revision'] != widget.snapshot['revision']) {
        return;
      }
      switch (type) {
        case 'action':
          final kind = data['kind'];
          final matches = ArtifactMechanism.values.where(
            (value) => value.name == kind,
          );
          if (matches.isEmpty) return;
          final index = data['index'];
          final direction = data['direction'];
          if (index is! int || direction is! int) return;
          widget.onBusy(true);
          final accepted = widget.onAction(
            ArtifactAction(matches.first, index, direction),
          );
          if (!accepted) {
            unawaited(
              _web
                  .runJavaScript('window.rejectArtifactAction();')
                  .catchError((Object _) => _fail()),
            );
          }
        case 'select':
          final kind = data['kind'];
          final index = data['index'];
          final matches = ArtifactMechanism.values.where(
            (value) => value.name == kind,
          );
          if (index is! int || matches.isEmpty) return;
          widget.onSelect(matches.first, index);
        case 'busy':
          widget.onBusy(true);
        case 'settled':
          widget.onBusy(false);
        case 'complete':
          widget.onBusy(false);
          widget.onComplete(data['epoch'] as int, data['revision'] as int);
      }
    } catch (_) {
      // Ignore malformed or late messages from an already detached page.
    }
  }

  void _queueSnapshot() {
    _pending = jsonEncode(widget.snapshot);
    unawaited(_flush());
  }

  Future<void> _flush() async {
    if (!_ready || _sending || _disposed) return;
    _sending = true;
    try {
      while (_ready && !_disposed && _pending != null) {
        final payload = _pending!;
        _pending = null;
        await _web.runJavaScript('window.applyArtifactSnapshot($payload);');
      }
    } catch (_) {
      if (!_disposed) _fail();
    } finally {
      _sending = false;
    }
  }

  Future<void> _setActive() async {
    if (!_ready || _disposed) return;
    try {
      await _web.runJavaScript('window.setArtifactActive($_resumed);');
    } catch (_) {
      if (!_disposed) _fail();
    }
  }

  @override
  void didUpdateWidget(covariant Artifact3DView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queueSnapshot();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _resumed = state == AppLifecycleState.resumed;
    unawaited(_setActive());
  }

  @override
  void dispose() {
    _disposed = true;
    _timeout?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(() async {
      try {
        await _web.runJavaScript('window.disposeArtifact?.();');
        await _web.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // The native platform view may already have been released.
      }
    }());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Stack(
    fit: StackFit.expand,
    children: [
      if (_failure == null)
        WebViewWidget(
          controller: _web,
          gestureRecognizers: {
            Factory<OneSequenceGestureRecognizer>(
              () => EagerGestureRecognizer(),
            ),
          },
        ),
      if (!_ready && _failure == null)
        const ColoredBox(
          color: Color(0xFFECE0C9),
          child: Center(
            child: CircularProgressIndicator(color: Color(0xFF896037)),
          ),
        ),
      if (_failure != null)
        ColoredBox(
          color: const Color(0xFFECE0C9),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_failure!, textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => setState(_load),
                    icon: const Icon(Icons.refresh),
                    label: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          ),
        ),
    ],
  );
}
