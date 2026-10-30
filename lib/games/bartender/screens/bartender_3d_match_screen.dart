import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../widgets/bartender_scene_view.dart';
import '../widgets/bartender_connection_banner.dart';
import '../widgets/bartender_visual_theme.dart';
import '../widgets/bartender_match_start_gate.dart';

/// Presentation only. The existing match screen supplies its order/status HUD;
/// both branches can keep evolving their room/controller/repository unchanged.
class Bartender3DMatchScreen extends StatefulWidget {
  const Bartender3DMatchScreen({
    super.key,
    required this.controller,
    required this.statusPanel,
    required this.ordersPanel,
    required this.fallback,
  });

  final BartenderController controller;
  final Widget statusPanel;
  final Widget ordersPanel;
  final Widget fallback;

  @override
  State<Bartender3DMatchScreen> createState() => _Bartender3DMatchScreenState();
}

class _Bartender3DMatchScreenState extends State<Bartender3DMatchScreen> {
  bool _useFallback = false;

  bool get _supported =>
      !kIsWeb &&
      defaultTargetPlatform == TargetPlatform.android &&
      !WidgetsBinding.instance.runtimeType.toString().contains('Test');

  @override
  Widget build(BuildContext context) {
    if (!_supported || _useFallback) {
      return BartenderMatchStartGate(
        controller: widget.controller,
        fallbackReady: true,
        child: widget.fallback,
      );
    }
    final ctrl = widget.controller;
    return BartenderMatchStartGate(
      controller: ctrl,
      child: Scaffold(
        backgroundColor: const Color(0xFF183F34),
        body: CustomPaint(
          painter: const BartenderBackdrop(),
          child: SafeArea(
            minimum: const EdgeInsets.all(8),
            child: LayoutBuilder(
              builder: (context, box) {
                final compact = box.maxHeight < 380;
                return Column(
                  children: [
                    SizedBox(height: compact ? 56 : 62, child: _status()),
                    BartenderConnectionBanner(state: ctrl.connectionState),
                    const SizedBox(height: 7),
                    Expanded(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Expanded(
                            flex: 70,
                            child: Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFEAD4AF),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: const Color(0xFFDBAE71),
                                  width: 2,
                                ),
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(14),
                                child: Column(
                                  children: [
                                    Expanded(
                                      child: BartenderSceneView(
                                        controller: ctrl,
                                        onUnavailable: () {
                                          if (mounted) {
                                            setState(() => _useFallback = true);
                                          }
                                        },
                                        fallback: const Center(
                                          child: Text('Đang mở chế độ nhẹ…'),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _status() {
    final seconds = widget.controller.remainingSeconds.clamp(0, 99999);
    final urgent = seconds < 15;
    final clock =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF3F7058), Color(0xFF2B5747)],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0x668CB394)),
        boxShadow: const [
          BoxShadow(
            color: Color(0x30000000),
            blurRadius: 7,
            offset: Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        children: [
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Icon(
                      Icons.local_bar_rounded,
                      color: Color(0xFFF1CE88),
                      size: 24,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'VÒNG ${widget.controller.room?.currentRound?.number ?? 1}',
                      style: const TextStyle(
                        color: bartenderCream,
                        fontSize: 17,
                        fontWeight: FontWeight.w900,
                        letterSpacing: .6,
                      ),
                    ),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 15,
                    vertical: 1,
                  ),
                  decoration: BoxDecoration(
                    color: urgent ? const Color(0xFFFFE0CB) : bartenderCream,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.timer_outlined,
                        color: urgent
                            ? const Color(0xFFB94D37)
                            : bartenderGreen,
                        size: 23,
                      ),
                      const SizedBox(width: 7),
                      Text(
                        clock,
                        style: TextStyle(
                          color: urgent
                              ? const Color(0xFFB94D37)
                              : bartenderGreen,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ],
                  ),
                ),
                Row(
                  children: [
                    const Icon(
                      Icons.stars_rounded,
                      color: Color(0xFFF1CE88),
                      size: 25,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      '${widget.controller.totalTeamOrders}',
                      style: const TextStyle(
                        color: bartenderCream,
                        fontSize: 23,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 4),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: (seconds / 60).clamp(0, 1).toDouble(),
              minHeight: 3,
              backgroundColor: const Color(0xFF214236),
              color: urgent ? const Color(0xFFEC9B72) : const Color(0xFFF1CE88),
            ),
          ),
        ],
      ),
    );
  }
}
