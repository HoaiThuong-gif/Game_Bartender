import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class SongCuTVView extends StatefulWidget {
  const SongCuTVView({
    super.key,
    required this.snapshot,
    required this.active,
    required this.onAction,
  });

  final Map<String, Object> snapshot;
  final bool active;
  final ValueChanged<Map<String, dynamic>> onAction;

  @override
  State<SongCuTVView> createState() => _SongCuTVViewState();
}

class _SongCuTVViewState extends State<SongCuTVView>
    with WidgetsBindingObserver {
  late final WebViewController _web;
  Timer? _timeout;
  bool _ready = false;
  bool _disposed = false;
  bool _sending = false;
  bool _foreground = true;
  String? _pending;
  String? _failure;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    final lifecycle = WidgetsBinding.instance.lifecycleState;
    _foreground = lifecycle == null || lifecycle == AppLifecycleState.resumed;
    _web = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFECE2D1))
      ..addJavaScriptChannel('SongCuGame', onMessageReceived: _message)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              request.url.startsWith(
                    'file:///android_asset/flutter_assets/assets/song_cu/',
                  ) ||
                  request.url == 'about:blank'
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) _fail();
          },
        ),
      );
    _load();
  }

  Map<String, Object> get _payload => {
    ...widget.snapshot,
    'active': widget.active && _foreground,
  };

  void _load() {
    _timeout?.cancel();
    _ready = false;
    _failure = null;
    _pending = jsonEncode(_payload);
    unawaited(
      _web
          .loadFlutterAsset('assets/song_cu/index.html')
          .catchError((Object _) => _fail()),
    );
    _timeout = Timer(const Duration(seconds: 25), _fail);
  }

  void _message(JavaScriptMessage message) {
    if (_disposed || !mounted) return;
    try {
      final data = Map<String, dynamic>.from(
        jsonDecode(message.message) as Map,
      );
      if (data['type'] == 'ready') {
        _timeout?.cancel();
        setState(() {
          _ready = true;
          _failure = null;
        });
        _queue();
      } else if (data['type'] == 'error') {
        _fail();
      } else if (data['type'] == 'action' &&
          widget.active &&
          _foreground &&
          _ready &&
          _failure == null) {
        widget.onAction(data);
      }
    } catch (_) {
      // Ignore incomplete or stale bridge messages.
    }
  }

  void _fail() {
    if (_disposed || !mounted || _failure != null) return;
    _timeout?.cancel();
    setState(() {
      _ready = false;
      _failure =
          'Chưa mở được TV 3D. Thiết bị cần Android WebView hỗ trợ WebGL 2.';
    });
    unawaited(
      _web.runJavaScript('window.pauseSongCu?.();').catchError((Object _) {}),
    );
  }

  void _queue() {
    _pending = jsonEncode(_payload);
    unawaited(_flush());
  }

  Future<void> _flush() async {
    if (!_ready || _sending || _disposed) return;
    _sending = true;
    try {
      while (_ready && !_disposed && _pending != null) {
        final payload = _pending!;
        _pending = null;
        await _web.runJavaScript('window.applySongCu($payload);');
      }
    } catch (_) {
      _fail();
    } finally {
      _sending = false;
    }
  }

  @override
  void didUpdateWidget(covariant SongCuTVView oldWidget) {
    super.didUpdateWidget(oldWidget);
    _queue();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _foreground = state == AppLifecycleState.resumed;
    _queue();
  }

  @override
  void dispose() {
    _disposed = true;
    _timeout?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    unawaited(() async {
      try {
        await _web.runJavaScript('window.disposeSongCu?.();');
        await _web.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // Platform view may have been released already.
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
      if (!_ready)
        ColoredBox(
          color: const Color(0xFFECE2D1),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: _failure == null
                  ? const CircularProgressIndicator(color: Color(0xFF706046))
                  : Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.tv_off_rounded, size: 42),
                        const SizedBox(height: 16),
                        Text(_failure!, textAlign: TextAlign.center),
                        const SizedBox(height: 16),
                        FilledButton(
                          onPressed: () => setState(_load),
                          child: const Text('Thử lại'),
                        ),
                      ],
                    ),
            ),
          ),
        ),
    ],
  );
}
