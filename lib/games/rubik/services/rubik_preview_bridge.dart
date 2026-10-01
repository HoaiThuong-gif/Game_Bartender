import 'dart:convert';

import '../models/cube_state.dart';

/// Keeps only the latest pending state while a platform-channel call is running.
/// No WebView reload, and no queue growth when input changes quickly.
class RubikPreviewBridge {
  RubikPreviewBridge(this.runJavaScript);
  final Future<void> Function(String) runJavaScript;
  String? _pending;
  String? _sent;
  bool _ready = false;
  bool _sending = false;
  bool _disposed = false;

  void setState(CubeState state) {
    _pending = state.toFaceletDefinition(allowIncomplete: true);
    _flush();
  }

  void pageStarted() {
    _ready = false;
    _sent = null;
  }

  void pageReady() {
    _ready = true;
    _flush();
  }

  Future<void> _flush() async {
    if (!_ready || _sending || _disposed) return;
    _sending = true;
    try {
      while (_ready && !_disposed && _pending != null && _pending != _sent) {
        final value = _pending!;
        await runJavaScript('window.setCubeState(${jsonEncode(value)});');
        _sent = value;
      }
    } catch (_) {
      // Keep the newest state for the next update/page-ready event.
      // The platform view may have been detached while awaiting the channel.
    } finally {
      _sending = false;
    }
  }

  void dispose() {
    _disposed = true;
  }
}
