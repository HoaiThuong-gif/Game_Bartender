import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Local toy on the main Rubik screen. No solver/scan state or persistence.
class RubikInteractivePreview extends StatefulWidget {
  const RubikInteractivePreview({
    super.key,
    this.active = true,
    this.challengeMoves,
    this.interactionEnabled = true,
    this.onPrepared,
    this.onSolved,
  });
  final bool active;
  final List<String>? challengeMoves;
  final bool interactionEnabled;
  final VoidCallback? onPrepared;
  final ValueChanged<bool>? onSolved;
  @override
  State<RubikInteractivePreview> createState() =>
      _RubikInteractivePreviewState();
}

class _RubikInteractivePreviewState extends State<RubikInteractivePreview>
    with WidgetsBindingObserver {
  bool _resumed = true;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (mounted) setState(() => _resumed = state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) =>
      widget.active && (_resumed || widget.challengeMoves != null)
      ? _InteractiveWebView(
          challengeMoves: widget.challengeMoves,
          interactionEnabled: widget.interactionEnabled,
          onPrepared: widget.onPrepared,
          onSolved: widget.onSolved,
        )
      : const SizedBox.expand();
}

class _InteractiveWebView extends StatefulWidget {
  const _InteractiveWebView({
    this.challengeMoves,
    required this.interactionEnabled,
    this.onPrepared,
    this.onSolved,
  });
  final List<String>? challengeMoves;
  final bool interactionEnabled;
  final VoidCallback? onPrepared;
  final ValueChanged<bool>? onSolved;
  @override
  State<_InteractiveWebView> createState() => _InteractiveWebViewState();
}

class _InteractiveWebViewState extends State<_InteractiveWebView> {
  late final WebViewController _controller;
  String? _failure;
  Timer? _timeout;
  bool _ready = false;
  bool _busy = false;
  bool _canUndo = false;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFDCEFFC))
      ..addJavaScriptChannel(
        'RubikToy',
        onMessageReceived: (event) {
          if (!mounted) return;
          final status = jsonDecode(event.message) as Map<String, dynamic>;
          if (status['type'] == 'ready') _timeout?.cancel();
          if (status['type'] == 'ready' && widget.challengeMoves != null) {
            unawaited(_prepareChallenge());
          }
          if (status['type'] == 'prepared') widget.onPrepared?.call();
          if (status['type'] != 'ready') {
            widget.onSolved?.call(
              status['solved'] == true && status['busy'] != true,
            );
          }
          setState(() {
            _ready = true;
            _busy = status['busy'] == true;
            _canUndo = (status['historyDepth'] as num? ?? 0) > 0;
          });
          if (kDebugMode) debugPrint('[RubikToy] ${event.message}');
        },
      )
      ..setNavigationDelegate(
        NavigationDelegate(
          onWebResourceError: (error) {
            if (mounted && error.isForMainFrame == true) {
              setState(() => _failure = 'Không tải được Rubik');
            }
          },
        ),
      )
      ..loadFlutterAsset('assets/rubik/interactive.html');
    _timeout = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _failure = 'Không tải được Rubik');
    });
  }

  Future<void> _prepareChallenge() async {
    try {
      await _controller.runJavaScript(
        'window.prepareRubikChallenge(${jsonEncode(widget.challengeMoves)});',
      );
      await _controller.runJavaScript(
        'window.enableRubikChallenge(${widget.interactionEnabled});',
      );
    } catch (_) {
      if (mounted) setState(() => _failure = 'Không tải được đề Rubik');
    }
  }

  @override
  void didUpdateWidget(covariant _InteractiveWebView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_ready &&
        widget.challengeMoves != null &&
        oldWidget.interactionEnabled != widget.interactionEnabled) {
      unawaited(
        _controller
            .runJavaScript(
              'window.enableRubikChallenge(${widget.interactionEnabled});',
            )
            .catchError((Object _) {}),
      );
    }
  }

  Future<void> _command(String name) async {
    setState(() => _busy = true);
    try {
      await _controller.runJavaScript('window.$name?.();');
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  void dispose() {
    _timeout?.cancel();
    unawaited(() async {
      try {
        await _controller.runJavaScript('window.disposeRubikToy?.();');
        await _controller.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        /* Platform view may already be destroyed by unmount. */
      }
    }());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _failure != null
      ? Center(
          child: Text(
            _failure!,
            style: const TextStyle(color: Color(0xFF155A91)),
          ),
        )
      : Stack(
          fit: StackFit.expand,
          children: [
            WebViewWidget(
              key: const ValueKey('rubik-interactive-webview'),
              controller: _controller,
              gestureRecognizers: {
                Factory<OneSequenceGestureRecognizer>(
                  () => EagerGestureRecognizer(),
                ),
              },
            ),
            if (widget.challengeMoves == null)
              Positioned(
                top: 8,
                right: 12,
                child: Row(
                  children: [
                    _smallButton(
                      key: const ValueKey('rubik-toy-undo'),
                      icon: Icons.undo_rounded,
                      label: 'Hoàn tác',
                      onPressed: _ready && !_busy && _canUndo
                          ? () => _command('undoRubikToy')
                          : null,
                    ),
                    const SizedBox(width: 8),
                    _smallButton(
                      key: const ValueKey('rubik-toy-reset'),
                      icon: Icons.restart_alt_rounded,
                      label: 'Đặt lại',
                      onPressed: _ready && !_busy
                          ? () => _command('resetRubikToy')
                          : null,
                    ),
                  ],
                ),
              ),
          ],
        );

  Widget _smallButton({
    required Key key,
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) => FilledButton.tonalIcon(
    key: key,
    onPressed: onPressed,
    icon: Icon(icon, size: 18),
    label: Text(label),
    style: FilledButton.styleFrom(
      foregroundColor: const Color(0xFF155A91),
      backgroundColor: const Color(0xFFF1F8FE),
      textStyle: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      minimumSize: const Size(0, 34),
    ),
  );
}
