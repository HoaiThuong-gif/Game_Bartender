import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../models/cube_state.dart';
import '../services/rubik_preview_bridge.dart';

class Rubik3DView extends StatefulWidget {
  const Rubik3DView({super.key, this.cubeState, this.active = true});
  final CubeState? cubeState;
  final bool active;

  @override
  State<Rubik3DView> createState() => _Rubik3DViewState();
}

class _Rubik3DViewState extends State<Rubik3DView> with WidgetsBindingObserver {
  late final WebViewController controller;
  bool _ready = false;
  late final RubikPreviewBridge _bridge;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);

    controller = WebViewController();
    _bridge = RubikPreviewBridge(controller.runJavaScript);
    if (widget.cubeState != null) _bridge.setState(widget.cubeState!);
    controller
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.transparent)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (_) {
            _ready = false;
            _bridge.pageStarted();
          },
          onPageFinished: (_) {
            if (!mounted) return;
            _ready = true;
            _bridge.pageReady();
            _setActive(
              WidgetsBinding.instance.lifecycleState ==
                  AppLifecycleState.resumed,
            );
          },
        ),
      )
      ..loadFlutterAsset('assets/rubik/index.html');
  }

  Future<void> _setActive(bool active) async {
    if (!_ready) return;
    try {
      await controller.runJavaScript(
        'window.setRubikActive?.(${active && widget.active});',
      );
    } catch (_) {
      // The platform view may already be detached during app shutdown.
    }
  }

  @override
  void didUpdateWidget(covariant Rubik3DView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!identical(widget.cubeState, oldWidget.cubeState) &&
        widget.cubeState != null) {
      _bridge.setState(widget.cubeState!);
    }
    if (oldWidget.active != widget.active) {
      _setActive(
        WidgetsBinding.instance.lifecycleState == AppLifecycleState.resumed,
      );
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _setActive(state == AppLifecycleState.resumed);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _bridge.dispose();
    _setActive(false);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WebViewWidget(
      controller: controller,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
  }
}
