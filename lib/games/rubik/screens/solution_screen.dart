import 'package:flutter/material.dart';

import '../controllers/solution_controller.dart';
import '../helpers/rubik_move_helper.dart';
import '../models/cube_state.dart';
import '../models/rubik_move.dart';
import '../widgets/move_legend.dart';
import '../widgets/rubik_theme.dart';
import '../widgets/rubik_preview_panel.dart';

class SolutionScreen extends StatefulWidget {
  const SolutionScreen({
    super.key,
    required this.moves,
    required this.initialState,
    this.previewBuilder,
  });
  final List<RubikMove> moves;
  final CubeState initialState;
  final CubePreviewBuilder? previewBuilder;

  @override
  State<SolutionScreen> createState() => _SolutionScreenState();
}

class _SolutionScreenState extends State<SolutionScreen> {
  late final SolutionController _controller = SolutionController(
    initialState: widget.initialState,
    moves: widget.moves,
  );
  bool _legendOpen = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _showLegend() async {
    setState(() => _legendOpen = true);
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      useSafeArea: true,
      builder: (_) => const FractionallySizedBox(
        heightFactor: 0.8,
        child: RubikTheme(child: MoveLegend()),
      ),
    );
    if (mounted) setState(() => _legendOpen = false);
  }

  @override
  Widget build(BuildContext context) => ListenableBuilder(
    listenable: _controller,
    builder: (context, _) {
      final move = _controller.currentMove;
      return RubikTheme(
        child: Scaffold(
          appBar: AppBar(title: const Text('HƯỚNG DẪN GIẢI')),
          bottomNavigationBar: SafeArea(
            minimum: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    key: const ValueKey('previous-step'),
                    icon: const Icon(Icons.arrow_back, size: 18),
                    onPressed: _controller.completed == 0 || _controller.busy
                        ? null
                        : _controller.previous,
                    label: const Text('Bước trước'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: FilledButton.icon(
                    key: const ValueKey('next-step'),
                    icon: Icon(
                      _controller.isComplete
                          ? Icons.check
                          : Icons.arrow_forward,
                      size: 18,
                    ),
                    onPressed: _controller.busy
                        ? null
                        : _controller.isComplete
                        ? () => Navigator.pop(context)
                        : _controller.next,
                    label: Text(
                      _controller.isComplete ? 'Hoàn thành' : 'Bước tiếp',
                    ),
                  ),
                ),
              ],
            ),
          ),
          body: SafeArea(
            child: LayoutBuilder(
              builder: (context, constraints) => Column(
                children: [
                  SizedBox(
                    height: (constraints.maxHeight * 0.38).clamp(80.0, 280.0),
                    child: RubikPreviewPanel(
                      state: _controller.state,
                      builder: widget.previewBuilder,
                      active: !_legendOpen,
                    ),
                  ),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        children: [
                          if (move == null) ...[
                            const SizedBox(height: 20),
                            const Icon(
                              Icons.check_circle_outline,
                              color: Colors.green,
                              size: 48,
                            ),
                            const Text(
                              'Rubik đã được giải!',
                              style: TextStyle(fontSize: 22),
                            ),
                          ] else ...[
                            const SizedBox(height: 16),
                            Text(
                              'Bước ${_controller.completed + 1} / ${_controller.moves.length}',
                              style: Theme.of(context).textTheme.titleMedium,
                            ),
                            const SizedBox(height: 12),
                            Container(
                              width: double.infinity,
                              constraints: const BoxConstraints(maxWidth: 440),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 20,
                                vertical: 16,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                                border: Border.all(
                                  color: const Color(0xFFDCE3ED),
                                ),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    move.toString(),
                                    style: const TextStyle(
                                      fontSize: 60,
                                      height: 1.1,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF1670D2),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    move.faceLabel.toUpperCase(),
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 16,
                                      color: Color(0xFF17233D),
                                    ),
                                  ),
                                  const SizedBox(height: 14),
                                  Icon(
                                    move.turn == RubikTurn.counterClockwise
                                        ? Icons.rotate_left
                                        : move.turn == RubikTurn.half
                                        ? Icons.sync
                                        : Icons.rotate_right,
                                    color: const Color(0xFF1670D2),
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    move.instruction,
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      color: Color(0xFF475569),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                          if (_controller.lastUndo != null)
                            Padding(
                              padding: const EdgeInsets.only(top: 12),
                              child: Text(
                                'Để lùi trên Rubik thật: ${_controller.lastUndo!.description}.',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          if (_controller.error != null)
                            Text(_controller.error!),
                          TextButton.icon(
                            onPressed: _showLegend,
                            icon: const Icon(Icons.help_outline),
                            label: const Text('Xem chú thích'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    },
  );
}
