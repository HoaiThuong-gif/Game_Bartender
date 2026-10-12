import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/gacha_reward.dart';
import '../services/gacha_cinematic_server.dart';
import 'reward_model_viewer.dart';

/// Mounted exclusively by the open result dialog. A failed Three renderer is
/// released before mounting the established ModelViewer fallback.
class GachaCinematicViewer extends StatefulWidget {
  const GachaCinematicViewer({super.key, required this.reward});
  final GachaReward reward;

  @override
  State<GachaCinematicViewer> createState() => _GachaCinematicViewerState();
}

class _GachaCinematicViewerState extends State<GachaCinematicViewer> {
  // Reopening/next waits for the previous JS teardown, rather than stacking GL.
  static Future<void> _previousRelease = Future<void>.value();
  GachaCinematicServer? _server;
  WebViewController? _controller;
  Timer? _timeout;
  Future<void>? _releaseFuture;
  bool _fallback = false;
  bool _failing = false;
  bool _ready = false;
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    unawaited(
      _start(
        DefaultAssetBundle.of(context),
        MediaQuery.disableAnimationsOf(context),
      ),
    );
  }

  Future<void> _start(AssetBundle bundle, bool reducedMotion) async {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.android) {
      if (mounted) setState(() => _fallback = true);
      return;
    }
    try {
      await _previousRelease;
      if (!mounted) return;
      final manifest = await AssetManifest.loadFromAssetBundle(bundle);
      if (!mounted) return;
      if (!manifest.listAssets().contains(widget.reward.modelAssetPath)) {
        setState(() => _fallback = true);
        return;
      }
      final server = await GachaCinematicServer.start(
        bundle,
        widget.reward.modelAssetPath,
      );
      if (!mounted) {
        await server.close();
        return;
      }
      _server = server;
      final controller = WebViewController();
      _controller = controller;
      await controller.setJavaScriptMode(JavaScriptMode.unrestricted);
      await controller.setBackgroundColor(const Color(0xFFE8DDC7));
      await controller.addJavaScriptChannel(
        'GachaCinematic',
        onMessageReceived: (message) => _onMessage(message.message),
      );
      await controller.setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (request) =>
              request.url == 'about:blank' ||
                  request.url.startsWith('${server.uri.origin}/')
              ? NavigationDecision.navigate
              : NavigationDecision.prevent,
          onWebResourceError: (error) {
            if (error.isForMainFrame == true) {
              unawaited(_fail(error.description));
            }
          },
        ),
      );
      if (!mounted || _failing) {
        await _release();
        return;
      }
      setState(() {});
      _timeout = Timer(
        const Duration(seconds: 45),
        () => unawaited(_fail('load timeout')),
      );
      await controller.loadRequest(
        server.uri.replace(
          queryParameters: {'motion': reducedMotion ? 'reduced' : 'full'},
        ),
      );
    } catch (error) {
      await _fail('$error');
    }
  }

  void _onMessage(String raw) {
    if (!mounted || _failing) return;
    try {
      final message = jsonDecode(raw) as Map<String, dynamic>;
      if (kDebugMode) debugPrint('[GachaCinematic] $raw');
      if (message['type'] == 'ready') {
        _timeout?.cancel();
        setState(() => _ready = true);
      } else if (message['type'] == 'error') {
        unawaited(_fail('${message['message']}'));
      }
    } catch (error) {
      unawaited(_fail('invalid renderer message: $error'));
    }
  }

  Future<void> _fail(String reason) async {
    if (_failing || !mounted) return;
    _failing = true;
    if (kDebugMode) debugPrint('[GachaCinematic] fallback: $reason');
    await _release();
    if (mounted) setState(() => _fallback = true);
  }

  Future<void> _release() {
    _timeout?.cancel();
    return _releaseFuture ??= _previousRelease = (() async {
      final controller = _controller;
      _controller = null;
      try {
        await controller?.runJavaScript('window.disposeGacha?.();');
        await controller?.loadRequest(Uri.parse('about:blank'));
      } catch (_) {
        // Unmount may already have destroyed the platform WebView. pagehide
        // also tears down JS; Android releases its detached GL context.
      } finally {
        await _server?.close();
        _server = null;
      }
    })();
  }

  @override
  void dispose() {
    unawaited(_release());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_fallback) return RewardModelViewer(reward: widget.reward);
    return Column(
      children: [
        SizedBox(
          height: 260,
          width: double.infinity,
          child: Stack(
            children: [
              if (_controller != null)
                Positioned.fill(
                  child: WebViewWidget(
                    key: const ValueKey('gacha-three-webview'),
                    controller: _controller!,
                    gestureRecognizers: {
                      Factory<OneSequenceGestureRecognizer>(
                        () => EagerGestureRecognizer(),
                      ),
                    },
                  ),
                ),
              if (!_ready)
                const Positioned.fill(
                  child: IgnorePointer(
                    child: ColoredBox(
                      color: Color(0xFFE8DDC7),
                      child: Center(child: Text('Đang tải model 3D…')),
                    ),
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.reward.name} · Kéo ngang để xoay',
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}
