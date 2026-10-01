import 'package:flutter/material.dart';
import '../controllers/solution_controller.dart';

class SolutionPlaybackControls extends StatelessWidget {
  const SolutionPlaybackControls({super.key, required this.controller, required this.onShowMoves});
  final SolutionController controller;
  final VoidCallback onShowMoves;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      Row(children: [
        _control('first-step', 'Đầu', Icons.first_page,
          controller.completed == 0 || controller.busy ? null : controller.first),
        _control('previous-step', 'Lùi', Icons.fast_rewind,
          controller.completed == 0 || controller.busy ? null : controller.previous),
        Expanded(child: Column(mainAxisSize: MainAxisSize.min, children: [
          IconButton.filled(
            key: const ValueKey('play-pause'),
            tooltip: controller.isPlaying ? 'Tạm dừng' : 'Phát lời giải',
            iconSize: 32,
            style: IconButton.styleFrom(backgroundColor: const Color(0xFF087F8C), foregroundColor: Colors.white,
              minimumSize: const Size(56, 56)),
            onPressed: controller.isPlaying ? controller.pause
              : controller.isComplete || controller.busy ? null : controller.play,
            icon: Icon(controller.isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          Text(controller.isPlaying ? 'Dừng' : 'Phát', style: const TextStyle(fontSize: 11)),
        ])),
        _control('next-step', 'Tiến', Icons.fast_forward,
          controller.isComplete || controller.busy ? null : controller.next),
        _control('last-step', 'Cuối', Icons.last_page,
          controller.isComplete || controller.busy ? null : controller.last),
      ]),
      const SizedBox(height: 4),
      Wrap(spacing: 8, crossAxisAlignment: WrapCrossAlignment.center, alignment: WrapAlignment.center, children: [
        const Text('Tốc độ', style: TextStyle(fontSize: 12, color: Color(0xFF64748B))),
        for (final speed in [0.5, 1.0, 2.0]) ChoiceChip(
          key: ValueKey('speed-$speed'),
          label: Text('${speed.toStringAsFixed(1)}x'),
          selected: controller.playbackSpeed == speed,
          selectedColor: const Color(0xFFD7EFEC),
          showCheckmark: false,
          visualDensity: VisualDensity.compact,
          onSelected: (_) => controller.setSpeed(speed),
        ),
      ]),
      TextButton.icon(
        onPressed: onShowMoves,
        icon: const Icon(Icons.format_list_numbered, size: 18),
        label: const Text('Xem tất cả các bước'),
        style: TextButton.styleFrom(foregroundColor: const Color(0xFF087F8C)),
      ),
    ]),
  );

  Widget _control(String key, String label, IconData icon, VoidCallback? callback) => Expanded(
    child: Column(mainAxisSize: MainAxisSize.min, children: [
      IconButton(key: ValueKey(key), tooltip: label, onPressed: callback, icon: Icon(icon),
        color: const Color(0xFF334155)),
      Text(label, style: const TextStyle(fontSize: 11, color: Color(0xFF64748B))),
    ]),
  );
}
