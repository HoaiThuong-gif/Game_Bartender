import '../../../settings/app_theme.dart';

import 'package:flutter/material.dart';

import '../models/game_item.dart';

/// Widget thùng rác — nhận vật phẩm kéo thả vào để loại bỏ.
///
/// Hỗ trợ hai cách dùng:
/// 1. Bấm nút "🗑️" trực tiếp (qua [ItemCardWidget]).
/// 2. Hiện thị khu vực Drop Target khi người dùng đang kéo vật phẩm.
///
/// Xem PROJECT_SPEC.md: "Người chơi có thể kéo/bấm bỏ vật phẩm vào thùng rác".
class TrashBinWidget extends StatefulWidget {
  const TrashBinWidget({
    super.key,
    required this.onDropped,
    this.isVisible = true,
    this.size = 64.0,
  });

  /// Callback khi một vật phẩm được thả vào thùng rác.
  final ValueChanged<GameItem> onDropped;

  /// Ẩn/hiện widget (ẩn khi không có vật phẩm để bỏ).
  final bool isVisible;

  /// Kích thước cạnh vuông (width & height). Mặc định là 64.
  final double size;

  @override
  State<TrashBinWidget> createState() => _TrashBinWidgetState();
}

class _TrashBinWidgetState extends State<TrashBinWidget>
    with SingleTickerProviderStateMixin {
  bool _isHovering = false;
  late final AnimationController _shakeController;
  late final Animation<double> _shakeAnimation;

  @override
  void initState() {
    super.initState();
    _shakeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _shakeAnimation =
        TweenSequence<double>([
          TweenSequenceItem(tween: Tween(begin: 0, end: -8), weight: 1),
          TweenSequenceItem(tween: Tween(begin: -8, end: 8), weight: 2),
          TweenSequenceItem(tween: Tween(begin: 8, end: -4), weight: 2),
          TweenSequenceItem(tween: Tween(begin: -4, end: 0), weight: 1),
        ]).animate(
          CurvedAnimation(parent: _shakeController, curve: Curves.easeInOut),
        );
  }

  @override
  void dispose() {
    _shakeController.dispose();
    super.dispose();
  }

  void _playShake() {
    _shakeController.forward(from: 0);
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isVisible) return const SizedBox.shrink();

    return DragTarget<GameItem>(
      onWillAcceptWithDetails: (_) {
        setState(() => _isHovering = true);
        return true;
      },
      onLeave: (_) {
        setState(() => _isHovering = false);
      },
      onAcceptWithDetails: (details) {
        setState(() => _isHovering = false);
        _playShake();
        widget.onDropped(details.data);
      },
      builder: (context, candidateData, rejectedData) {
        final isAccepting = candidateData.isNotEmpty;

        return AnimatedBuilder(
          animation: _shakeAnimation,
          builder: (context, child) {
            return Transform.translate(
              offset: Offset(_shakeAnimation.value, 0),
              child: child,
            );
          },
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeInOut,
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              color: isAccepting || _isHovering
                  ? Colors.red.withValues(alpha: 0.3)
                  : AppTheme.arenaSurface,
              borderRadius: BorderRadius.circular(widget.size * 0.25),
              border: Border.all(
                color: isAccepting || _isHovering
                    ? Colors.redAccent
                    : Colors.white12,
                width: isAccepting ? 2 : 1,
              ),
              boxShadow: isAccepting
                  ? [
                      BoxShadow(
                        color: Colors.redAccent.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 2,
                      ),
                    ]
                  : null,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isAccepting
                        ? (widget.size * 0.44)
                        : (widget.size * 0.35),
                  ),
                  child: const Text('🗑️'),
                ),
                SizedBox(height: widget.size < 56 ? 1 : 2),
                Text(
                  isAccepting ? 'THẢ VÀO' : 'RÁC',
                  style: TextStyle(
                    color: isAccepting ? Colors.redAccent : Colors.white24,
                    fontSize: widget.size < 56 ? 7 : 8,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Một vật phẩm có thể kéo thả (Draggable wrapper).
///
/// Dùng để bọc [ItemCardWidget] hoặc bất kỳ widget nào
/// khi muốn hỗ trợ kéo sang [TrashBinWidget].
class DraggableItemWrapper extends StatelessWidget {
  const DraggableItemWrapper({
    super.key,
    required this.item,
    required this.child,
  });

  final GameItem item;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Draggable<GameItem>(
      data: item,
      feedback: Material(
        color: Colors.transparent,
        child: Opacity(
          opacity: 0.8,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: AppTheme.arenaRaised,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.amberAccent.withValues(alpha: 0.5),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 12,
                ),
              ],
            ),
            child: Text(
              item.itemId,
              style: const TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
        ),
      ),
      childWhenDragging: Opacity(opacity: 0.3, child: child),
      child: child,
    );
  }
}
