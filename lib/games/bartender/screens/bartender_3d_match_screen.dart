import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../controllers/bartender_controller.dart';
import '../widgets/bartender_scene_view.dart';

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
    if (!_supported || _useFallback) return widget.fallback;
    final ctrl = widget.controller;
    return Scaffold(
      backgroundColor: const Color(0xFF7C4C2F),
      body: SafeArea(
        minimum: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (context, box) {
            final compact = box.maxHeight < 380;
            return Column(
              children: [
                SizedBox(height: compact ? 45 : 54, child: _status()),
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
    );
  }

  Widget _status() {
    final seconds = widget.controller.remainingSeconds.clamp(0, 99999);
    final clock =
        '${(seconds ~/ 60).toString().padLeft(2, '0')}:${(seconds % 60).toString().padLeft(2, '0')}';
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF0D1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            'VÒNG ${widget.controller.room?.currentRound?.number ?? 1}',
            style: const TextStyle(
              color: Color(0xFF714528),
              fontSize: 17,
              fontWeight: FontWeight.w900,
            ),
          ),
          Row(
            children: [
              Icon(
                Icons.timer_outlined,
                color: seconds < 15 ? Colors.red : const Color(0xFF287A63),
                size: 25,
              ),
              const SizedBox(width: 8),
              Text(
                clock,
                style: TextStyle(
                  color: seconds < 15 ? Colors.red : const Color(0xFF287A63),
                  fontSize: 27,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ],
          ),
          Text(
            '★ ${widget.controller.totalTeamOrders}',
            style: const TextStyle(
              color: Color(0xFF714528),
              fontSize: 22,
              fontWeight: FontWeight.w900,
            ),
          ),
        ],
      ),
    );
  }
}
