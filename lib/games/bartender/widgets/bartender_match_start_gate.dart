import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import 'bartender_visual_theme.dart';

/// The backend owns the shared countdown. This only blocks input and reports
/// a rendered fallback frame; the WebGL view reports its own first ready scene.
class BartenderMatchStartGate extends StatefulWidget {
  const BartenderMatchStartGate({
    super.key,
    required this.controller,
    required this.child,
    this.fallbackReady = false,
  });
  final BartenderController controller;
  final Widget child;
  final bool fallbackReady;
  @override
  State<BartenderMatchStartGate> createState() =>
      _BartenderMatchStartGateState();
}

class _BartenderMatchStartGateState extends State<BartenderMatchStartGate> {
  int? _queued;
  @override
  Widget build(BuildContext context) {
    final ctrl = widget.controller;
    final id = ctrl.isMatchPreparing ? ctrl.room!.timer!.startedAt : null;
    if (widget.fallbackReady && id != null && _queued != id) {
      _queued = id;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) ctrl.reportSceneReady(preparationId: id);
      });
    }
    final count = ctrl.startCountdownSeconds;
    final waiting = ctrl.isMatchPreparing || count > 0;
    return Stack(
      fit: StackFit.expand,
      children: [
        RepaintBoundary(
          child: IgnorePointer(ignoring: waiting, child: widget.child),
        ),
        if (waiting)
          Positioned.fill(
            child: ColoredBox(
              color: const Color(0xC9183F34),
              child: Material(
                color: Colors.transparent,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (ctrl.isMatchPreparing) ...[
                          const CircularProgressIndicator(
                            color: Color(0xFFF1CE88),
                          ),
                          const SizedBox(height: 16),
                          const Text(
                            'Đang chuẩn bị quầy...',
                            style: TextStyle(
                              color: bartenderCream,
                              fontSize: 23,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${ctrl.sceneReadyPlayerCount}/${ctrl.room!.connectedPlayerCount} người chơi đã sẵn sàng',
                            style: const TextStyle(
                              color: bartenderCream,
                              fontSize: 16,
                            ),
                          ),
                          if (ctrl.errorMessage?.startsWith(
                                'Không thể chuẩn bị trận:',
                              ) ==
                              true) ...[
                            const SizedBox(height: 8),
                            Text(
                              ctrl.errorMessage!,
                              style: const TextStyle(color: Color(0xFFFFC9AC)),
                            ),
                            TextButton(
                              onPressed: () =>
                                  ctrl.reportSceneReady(preparationId: id!),
                              child: const Text(
                                'Thử lại',
                                style: TextStyle(color: bartenderCream),
                              ),
                            ),
                          ],
                        ] else ...[
                          Text(
                            '$count',
                            key: const Key('match-countdown'),
                            style: const TextStyle(
                              color: Color(0xFFF1CE88),
                              fontSize: 96,
                              fontWeight: FontWeight.w900,
                              height: 1,
                            ),
                          ),
                          const SizedBox(height: 10),
                          const Text(
                            'SẴN SÀNG!',
                            style: TextStyle(
                              color: bartenderCream,
                              fontSize: 23,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}
