import 'dart:math';

import 'package:flutter/material.dart';
import 'package:model_viewer_plus/model_viewer_plus.dart';

import '../models/gacha_reward.dart';
import 'gacha_colors.dart';
import 'reward_icon.dart';
import 'reward_model_viewer.dart';
import 'item_reveal_particles.dart';
import 'gacha_cinematic_viewer.dart';

/// Mounted only while the result is open; closing removes the model WebView.
class GachaResultPanel extends StatelessWidget {
  const GachaResultPanel({
    super.key,
    required this.reward,
    required this.onClose,
    required this.onDrawNext,
    this.viewerBuilder,
    this.duplicate = false,
    this.busy = false,
  });

  final GachaReward reward;
  final bool duplicate;
  final bool busy;
  final VoidCallback onClose;
  final VoidCallback onDrawNext;
  final Widget Function(ModelViewer viewer)? viewerBuilder;

  @override
  Widget build(BuildContext context) => TweenAnimationBuilder<double>(
    tween: Tween(begin: 0, end: 1),
    duration: const Duration(milliseconds: 240),
    builder: (_, value, child) => Opacity(
      opacity: value,
      child: Transform.scale(scale: .94 + .06 * value, child: child),
    ),
    child: Dialog(
      key: const ValueKey('gacha-result'),
      backgroundColor: GachaColors.paper,
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 480),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Bạn nhận được',
                style: TextStyle(color: GachaColors.ink),
              ),
              const SizedBox(height: 8),
              if (duplicate)
                const Text(
                  'Đã sở hữu',
                  key: ValueKey('gacha-duplicate'),
                  style: TextStyle(color: GachaColors.brick),
                ),
              Flexible(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TweenAnimationBuilder<double>(
                        tween: Tween(begin: .85, end: 1),
                        duration: const Duration(milliseconds: 220),
                        builder: (_, scale, child) =>
                            Transform.scale(scale: scale, child: child),
                        child: RewardIcon(
                          key: const ValueKey('gacha-result-icon'),
                          reward: reward,
                          size: min(
                            MediaQuery.sizeOf(context).width * .30,
                            140,
                          ),
                        ),
                      ),
                      Text(
                        reward.name,
                        key: const ValueKey('gacha-result-name'),
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: GachaColors.ink,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Stack(
                        children: [
                          RepaintBoundary(
                            child: viewerBuilder != null
                                ? RewardModelViewer(
                                    reward: reward,
                                    viewerBuilder: viewerBuilder,
                                  )
                                : GachaCinematicViewer(
                                    key: ValueKey(reward.modelAssetPath),
                                    reward: reward,
                                  ),
                          ),
                          if (viewerBuilder != null)
                            const Positioned.fill(child: ItemRevealParticles()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: GachaColors.ink,
                        side: const BorderSide(color: GachaColors.brick),
                      ),
                      key: const ValueKey('gacha-result-close'),
                      onPressed: busy ? null : onClose,
                      child: const Text('Nhận'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: GachaColors.brick,
                        foregroundColor: GachaColors.paper,
                      ),
                      key: const ValueKey('gacha-result-next'),
                      onPressed: busy ? null : onDrawNext,
                      child: const Text('Bốc tiếp'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
