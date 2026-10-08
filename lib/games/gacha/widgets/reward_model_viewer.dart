import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';
import 'package:webview_flutter/webview_flutter.dart' show WebViewController;

import '../models/gacha_reward.dart';
import 'gacha_colors.dart';
import 'reward_icon.dart';

/// Loads a local reward model with missing-asset and renderer-error fallbacks.
class RewardModelViewer extends StatelessWidget {
  const RewardModelViewer({super.key, this.reward, this.viewerBuilder});

  final GachaReward? reward;

  /// Tests inspect the real viewer configuration without mounting a WebView.
  @visibleForTesting
  final Widget Function(ModelViewer viewer)? viewerBuilder;

  @override
  Widget build(BuildContext context) => SizedBox(
    width: double.infinity,
    child: reward == null
        ? const _ModelMessage('Xé phiếu để xem vật phẩm 3D')
        : _LocalRewardViewer(
            key: ValueKey(reward!.modelAssetPath),
            reward: reward!,
            bundle: DefaultAssetBundle.of(context),
            viewerBuilder: viewerBuilder,
          ),
  );
}

class _LocalRewardViewer extends StatefulWidget {
  const _LocalRewardViewer({
    super.key,
    required this.reward,
    required this.bundle,
    this.viewerBuilder,
  });

  final GachaReward reward;
  final AssetBundle bundle;
  final Widget Function(ModelViewer viewer)? viewerBuilder;

  @override
  State<_LocalRewardViewer> createState() => _LocalRewardViewerState();
}

class _LocalRewardViewerState extends State<_LocalRewardViewer> {
  bool _checked = false;
  bool _exists = false;
  bool _loaded = false;
  String? _failure;
  Timer? _loadTimeout;
  bool _viewerMounted = false;
  WebViewController? _webController;

  void _releaseModel() {
    final controller = _webController;
    _webController = null;
    if (controller == null) return;
    unawaited(() async {
      try {
        await controller.runJavaScript('''
          const item = document.querySelector('model-viewer');
          if (item) { item.removeAttribute('src'); item.remove(); }
        ''');
        await controller.loadRequest(Uri.parse('about:blank'));
      } catch (error) {
        // The platform view may already have been destroyed by unmounting.
        if (kDebugMode) debugPrint('[Gacha3D] Cleanup after unmount: $error');
      }
    }());
  }

  @override
  void initState() {
    super.initState();
    unawaited(_checkAsset());
  }

  Future<void> _checkAsset() async {
    final path = widget.reward.modelAssetPath;
    // Restrict this benchmark to bundled GLBs. Reject URLs and path traversal.
    if (!RegExp(r'^assets/models/gacha/[A-Za-z0-9_-]+\.glb$').hasMatch(path)) {
      _checked = true;
      _failure = 'Đường dẫn model GLB local không hợp lệ';
      return;
    }
    try {
      // Check metadata only; don't duplicate the GLB's bytes in Dart memory.
      final manifest = await AssetManifest.loadFromAssetBundle(widget.bundle);
      if (!mounted) return;
      setState(() {
        _checked = true;
        _exists = manifest.listAssets().contains(path);
      });
    } catch (error) {
      if (kDebugMode) debugPrint('[Gacha3D] Asset manifest failed: $error');
      if (!mounted) return;
      setState(() {
        _checked = true;
        _failure = 'Không thể kiểm tra asset model 3D';
      });
    }
  }

  void _modelEvent(String message) {
    if (!mounted || _failure != null) return;
    if (message == 'loaded') {
      _loadTimeout?.cancel();
      if (_loaded) return;
      if (kDebugMode) {
        debugPrint('[Gacha3D] Loaded: ${widget.reward.modelAssetPath}');
      }
      setState(() => _loaded = true);
    } else if (message == 'error') {
      _fail('Không thể hiển thị model 3D này');
    }
  }

  void _fail(String message) {
    if (!mounted) return;
    _loadTimeout?.cancel();
    _releaseModel();
    if (kDebugMode && _viewerMounted) {
      debugPrint('[Gacha3D] Remove viewer: $message');
    }
    _viewerMounted = false;
    setState(() => _failure = message);
  }

  @override
  void dispose() {
    _loadTimeout?.cancel();
    _releaseModel();
    if (kDebugMode) {
      debugPrint('[Gacha3D] Dispose viewer: ${widget.reward.modelAssetPath}');
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_checked) return const _ModelMessage('Đang kiểm tra model 3D…');
    if (_failure != null) return _fallback(_failure!);
    if (!_exists) {
      return _fallback('Chưa có model 3D cho vật phẩm này');
    }
    if (widget.viewerBuilder == null &&
        (kIsWeb || defaultTargetPlatform != TargetPlatform.android)) {
      return _fallback('Xem ảnh vật phẩm trên thiết bị này');
    }

    if (!_viewerMounted) {
      _viewerMounted = true;
      if (kDebugMode) {
        debugPrint(
          '[Gacha3D] Mount ModelViewer: ${widget.reward.modelAssetPath}',
        );
      }
    }
    final viewer = ModelViewer(
      key: ValueKey(widget.reward.modelAssetPath),
      src: widget.reward.modelAssetPath,
      alt: widget.reward.name,
      backgroundColor: const Color(0xFFE8DDC7),
      ar: false,
      xrEnvironment: false,
      cameraControls: true,
      disablePan: true,
      disableZoom: true,
      autoRotate: false,
      autoPlay: false,
      shadowIntensity: 0,
      environmentImage: 'neutral',
      interactionPrompt: InteractionPrompt.none,
      loading: Loading.eager,
      debugLogging: false,
      javascriptChannels: {
        JavascriptChannel(
          'GachaModelStatus',
          onMessageReceived: (message) => _modelEvent(message.message),
        ),
      },
      relatedJs: '''
        const model = document.querySelector('model-viewer');
        let revealed = false;
        function reveal() {
          if (revealed) return;
          revealed = true;
          model.cameraOrbit = '20deg 75deg auto';
          model.jumpCameraToGoal();
          requestAnimationFrame(() => {
            model.cameraOrbit = '0deg 75deg auto';
            GachaModelStatus.postMessage('loaded');
          });
        }
        model.addEventListener('load', reveal);
        model.addEventListener('error', () => GachaModelStatus.postMessage('error'));
        if (model.loaded) reveal();
      ''',
      onWebViewCreated: (controller) {
        if (!mounted || _loaded || _failure != null) return;
        _webController = controller;
        _loadTimeout?.cancel();
        _loadTimeout = Timer(
          const Duration(seconds: 45),
          () => _fail(
            'Model 3D tải quá lâu. Hãy kiểm tra file GLB và Android WebView.',
          ),
        );
      },
    );
    return Column(
      children: [
        SizedBox(
          height: 260,
          child: TweenAnimationBuilder<double>(
            tween: Tween(begin: 0, end: _loaded ? 1 : 0),
            duration: const Duration(milliseconds: 300),
            builder: (_, value, child) => Transform.scale(
              scale: .92 + .08 * value,
              child: Opacity(opacity: _loaded ? value : 1, child: child),
            ),
            child: Stack(
              children: [
                Positioned.fill(
                  child: widget.viewerBuilder?.call(viewer) ?? viewer,
                ),
                if (!_loaded)
                  const Positioned.fill(
                    child: IgnorePointer(
                      child: ColoredBox(
                        color: Color(0xFFE8DDC7),
                        child: _ModelMessage('Đang tải model 3D…'),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '${widget.reward.name} · Kéo ngang để xoay',
          textAlign: TextAlign.center,
          style: const TextStyle(color: GachaColors.ink),
        ),
      ],
    );
  }

  Widget _fallback(String message) {
    if (kDebugMode) {
      debugPrint(
        '[Gacha3D] ${widget.reward.modelAssetPath}: $message; PNG fallback',
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RewardIcon(
          key: const ValueKey('gacha-model-fallback'),
          reward: widget.reward,
          size: 180,
        ),
        _ModelMessage(message),
      ],
    );
  }
}

class _ModelMessage extends StatelessWidget {
  const _ModelMessage(this.message);

  final String message;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 20),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(Icons.view_in_ar_outlined, size: 38, color: GachaColors.ink),
        const SizedBox(height: 8),
        Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(color: GachaColors.ink),
        ),
      ],
    ),
  );
}
