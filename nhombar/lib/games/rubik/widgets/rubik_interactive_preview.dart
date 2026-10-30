import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../shared/widgets/cozy_loading.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:webview_flutter/webview_flutter.dart';

/// Practice progress is persisted separately from solver and challenge state.
class RubikInteractivePreview extends StatefulWidget {
  const RubikInteractivePreview({
    super.key,
    this.active = true,
    this.oneFingerOrbit = false,
    this.challengeMoves,
    this.interactionEnabled = true,
    this.onPrepared,
    this.onSolved,
  });
  final bool active;
  final bool oneFingerOrbit;
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
  Widget build(BuildContext context) => _InteractiveWebView(
    active: widget.active && _resumed,
    oneFingerOrbit: widget.oneFingerOrbit,
    challengeMoves: widget.challengeMoves,
    interactionEnabled: widget.interactionEnabled,
    onPrepared: widget.onPrepared,
    onSolved: widget.onSolved,
  );
}

class _InteractiveWebView extends StatefulWidget {
  const _InteractiveWebView({
    this.challengeMoves,
    required this.active,
    required this.oneFingerOrbit,
    required this.interactionEnabled,
    this.onPrepared,
    this.onSolved,
  });
  final bool active;
  final bool oneFingerOrbit;
  final List<String>? challengeMoves;
  final bool interactionEnabled;
  final VoidCallback? onPrepared;
  final ValueChanged<bool>? onSolved;
  @override
  State<_InteractiveWebView> createState() => _InteractiveWebViewState();
}

class _InteractiveWebViewState extends State<_InteractiveWebView> {
  static const _sessionKey = 'rubik.practice.session.v1';
  static Future<void> _storageQueue = Future<void>.value();
  late final WebViewController _controller;
  late final Widget _webView;
  String? _failure;
  Timer? _timeout;
  bool _ready = false;
  bool _canUndo = false;
  late bool _orbitWithOneFinger = widget.oneFingerOrbit;
  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0xFFDCEFFC))
      ..addJavaScriptChannel(
        'RubikToy',
        onMessageReceived: (event) {
          final dynamic decoded;
          try {
            decoded = jsonDecode(event.message);
          } catch (_) {
            return;
          }
          if (decoded is! Map<String, dynamic>) return;
          final status = decoded;
          if (status['type'] == 'save') {
            if (widget.challengeMoves == null) _saveSession(status['session']);
            return;
          }
          if (!mounted || status['type'] == 'disposed') return;
          if (status['type'] == 'ready') {
            _timeout?.cancel();
            unawaited(_initialize());
            return;
          }
          if (status['type'] == 'invalidSession') {
            _notice(
              'Dữ liệu Rubik đã lưu không hợp lệ. Đã khôi phục khối mặc định.',
            );
          }
          if (status['type'] == 'prepared') widget.onPrepared?.call();
          if (['move', 'prepared'].contains(status['type'])) {
            widget.onSolved?.call(
              status['solved'] == true && status['busy'] != true,
            );
          }
          final canUndo = (status['historyDepth'] as num? ?? 0) > 0;
          if (!_ready || _canUndo != canUndo) {
            setState(() {
              _ready = true;
              _canUndo = canUndo;
            });
          }
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
    _webView = WebViewWidget(
      key: const ValueKey('rubik-interactive-webview'),
      controller: _controller,
      gestureRecognizers: {
        Factory<OneSequenceGestureRecognizer>(() => EagerGestureRecognizer()),
      },
    );
    _timeout = Timer(const Duration(seconds: 30), () {
      if (mounted) setState(() => _failure = 'Không tải được Rubik');
    });
  }

  void _notice(String message) {
    if (mounted) {
      ScaffoldMessenger.maybeOf(context)
          ?.showSnackBar(SnackBar(content: Text(message)));
    }
  }

  void _saveSession(dynamic session) {
    final value = jsonEncode(session);
    _storageQueue = _storageQueue
        .then((_) async {
          final prefs = await SharedPreferences.getInstance();
          if (!await prefs.setString(_sessionKey, value)) {
            throw StateError('Cannot save Rubik session');
          }
        })
        .catchError((Object _) {
          _notice('Không lưu được tiến trình Rubik trên thiết bị.');
        });
  }

  Future<void> _initialize() async {
    try {
      if (widget.challengeMoves != null) {
        await _prepareChallenge();
      } else {
        dynamic session;
        try {
          await _storageQueue;
          final prefs = await SharedPreferences.getInstance();
          final raw = prefs.getString(_sessionKey);
          if (raw != null) session = jsonDecode(raw);
        } catch (_) {
          _notice(
            'Không đọc được tiến trình Rubik đã lưu. Đang mở khối mặc định.',
          );
        }
        if (!mounted) return;
        await _controller.runJavaScript(
          'window.restoreRubikToy(${jsonEncode(session)});',
        );
      }
      if (mounted) {
        await _controller.runJavaScript(
          'window.setRubikOneFingerOrbit($_orbitWithOneFinger);',
        );
        await _setActive();
      }
    } catch (_) {
      if (mounted) setState(() => _failure = 'Không khôi phục được Rubik');
    }
  }

  Future<void> _toggleGestureMode() async {
    final next = !_orbitWithOneFinger;
    try {
      await _controller.runJavaScript('window.setRubikOneFingerOrbit($next);');
      if (mounted) setState(() => _orbitWithOneFinger = next);
    } catch (_) {
      _notice('Chưa đổi được thao tác. Hãy thử lại.');
    }
  }

  Future<void> _scramble() async {
    bool needsConfirmation;
    try {
      final result = await _controller.runJavaScriptReturningResult(
        'window.rubikToyNeedsScrambleConfirmation();',
      );
      needsConfirmation = result == true || result.toString() == 'true';
    } catch (_) {
      _notice('Không đọc được trạng thái Rubik. Hãy thử lại.');
      return;
    }
    if (!mounted) return;
    if (needsConfirmation) {
      final confirmed = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Tự xáo Rubik?'),
          content: const Text(
            'Khối Rubik đang chơi dở sẽ được xáo thêm. Bạn vẫn có thể hoàn tác các lượt xáo.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Hủy'),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Tự xáo'),
            ),
          ],
        ),
      );
      if (confirmed != true || !mounted) return;
    }
    await _command('scrambleRubikToy');
  }

  Future<void> _setActive() async {
    try {
      await _controller.runJavaScript(
        'window.setRubikToyActive(${widget.active});',
      );
    } catch (_) {
      // A platform view may be closing while a route is popped.
    }
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
    if (_ready && oldWidget.active != widget.active) unawaited(_setActive());
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
    try {
      await _controller.runJavaScript('window.$name?.();');
    } catch (_) {
      _notice('Không thực hiện được thao tác Rubik. Hãy thử lại.');
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
            _webView,
            if (!_ready)
              const Positioned.fill(
                child: ColoredBox(
                  color: Color(0xFFFFF8F1),
                  child: CozyLoading(label: 'Đang mở Rubik…'),
                ),
              ),
            if (widget.challengeMoves == null)
              Positioned(
                top: 8,
                right: 12,
                left: 12,
                child: Wrap(
                  alignment: WrapAlignment.end,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    if (widget.oneFingerOrbit)
                      _smallButton(
                        key: const ValueKey('rubik-gesture-mode'),
                        icon: _orbitWithOneFinger
                            ? Icons.threed_rotation
                            : Icons.grid_3x3,
                        label: _orbitWithOneFinger
                            ? 'Xoay góc nhìn'
                            : 'Xoay tầng',
                        onPressed: _ready ? _toggleGestureMode : null,
                      ),
                    _smallButton(
                      key: const ValueKey('rubik-toy-scramble'),
                      icon: Icons.shuffle_rounded,
                      label: 'Tự xáo',
                      onPressed: _ready ? _scramble : null,
                    ),
                    _smallButton(
                      key: const ValueKey('rubik-toy-undo'),
                      icon: Icons.undo_rounded,
                      label: 'Hoàn tác',
                      onPressed: _ready && _canUndo
                          ? () => _command('undoRubikToy')
                          : null,
                    ),
                    _smallButton(
                      key: const ValueKey('rubik-toy-reset'),
                      icon: Icons.restart_alt_rounded,
                      label: 'Đặt lại',
                      onPressed: _ready
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
