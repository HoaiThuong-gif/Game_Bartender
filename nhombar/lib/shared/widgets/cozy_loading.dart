import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Show only while the caller's real initialization or request is pending.
/// The decorative cat never decides how long the operation takes.
class CozyLoading extends StatelessWidget {
  const CozyLoading({super.key, this.label = 'Đang chuẩn bị…'});
  final String label;

  @override
  Widget build(BuildContext context) => Center(child: SingleChildScrollView(
    padding: const EdgeInsets.all(16), child: Column(mainAxisSize: MainAxisSize.min, children: [
      const SizedBox(width: 180, height: 135, child: _CozyCat()),
      const SizedBox(height: 12), Text(label, textAlign: TextAlign.center),
      const SizedBox(height: 12), const SizedBox(width: 96, child: LinearProgressIndicator()),
      const SizedBox(height: 8), const Text('Mèo: DreamNoms · CC BY 4.0', style: TextStyle(fontSize: 10)),
    ]),
  ));
}

class _CozyCat extends StatefulWidget {
  const _CozyCat();
  @override
  State<_CozyCat> createState() => _CozyCatState();
}

class _CozyCatState extends State<_CozyCat> with WidgetsBindingObserver {
  WebViewController? _controller;
  bool _failed = false;
  bool _started = false;
  bool _reduceMotion = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _reduceMotion = MediaQuery.disableAnimationsOf(context);
    if (_started) return;
    _started = true;
    WidgetsBinding.instance.addObserver(this);
    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android &&
        !WidgetsBinding.instance.runtimeType.toString().contains('Test')) {
      _load();
    }
  }

  Future<void> _load() async {
    try {
      final script = await rootBundle.loadString('assets/loading/cozy_cat.js');
      final data = await rootBundle.load('assets/loading/cat.glb');
      if (!mounted) return;
      final encoded = base64Encode(data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes));
      final controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setBackgroundColor(Colors.transparent)
        ..addJavaScriptChannel('CatStatus', onMessageReceived: (_) {
          if (mounted) setState(() => _failed = true);
        });
      await controller.loadHtmlString('<html><meta name="viewport" content="width=device-width,initial-scale=1">'
        '<body style="margin:0;overflow:hidden;background:transparent"><script>$script'
        '\nwindow.loadCozyCat(${jsonEncode(encoded)}, ${!_reduceMotion});</script></body></html>');
      if (mounted) setState(() => _controller = controller);
    } catch (error) {
      debugPrint('[CozyCat] ${error.runtimeType}');
      if (mounted) setState(() => _failed = true);
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _pause(state != AppLifecycleState.resumed || _reduceMotion);
  }

  Future<void> _pause(bool paused) async {
    try { await _controller?.runJavaScript('window.setCatActive?.(${!paused});'); }
    catch (_) { /* The WebView may already be detached. */ }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _pause(true);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => !_failed && _controller != null
      ? IgnorePointer(child: WebViewWidget(controller: _controller!))
      : Icon(Icons.pets_rounded, size: 64, color: Theme.of(context).colorScheme.primary);
}
