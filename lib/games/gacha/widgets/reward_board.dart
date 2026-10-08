import 'package:flutter/material.dart';

import '../models/gacha_reward.dart';
import 'gacha_colors.dart';
import 'reward_icon.dart';

/// Overlays rewards and selection feedback without changing the board artwork.
class RewardBoard extends StatelessWidget {
  const RewardBoard({
    super.key,
    required this.rewards,
    this.selectedNumber,
    this.emphasizeSelection = false,
  });

  final List<GachaReward> rewards;
  final int? selectedNumber;
  final bool emphasizeSelection;

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1122 / 1402,
    child: LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final height = constraints.maxHeight;
        return Stack(
          children: [
            Positioned.fill(
              child: Image.asset(
                'assets/images/gacha/ui/danh_sach_item.png',
                fit: BoxFit.contain,
                excludeFromSemantics: true,
              ),
            ),
            Positioned(
              left: width * .12,
              top: height * .15,
              width: width * .76,
              height: height * .07,
              child: const FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  'BẢNG GIẢI THƯỞNG',
                  style: TextStyle(
                    color: GachaColors.brick,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            for (var index = 0; index < rewards.length; index++)
              Positioned(
                left: width * (.075 + (index % 4) * .218),
                top: height * (.26 + (index ~/ 4) * .178),
                width: width * .195,
                height: height * .175,
                child: Semantics(
                  selected: rewards[index].number == selectedNumber,
                  label:
                      '${rewards[index].displayNumber} · ${rewards[index].name}',
                  child: AnimatedOpacity(
                    opacity:
                        emphasizeSelection &&
                            rewards[index].number != selectedNumber
                        ? .4
                        : 1,
                    duration: const Duration(milliseconds: 180),
                    child: AnimatedScale(
                      scale: rewards[index].number == selectedNumber
                          ? (emphasizeSelection ? 1.08 : 1.04)
                          : 1,
                      duration: const Duration(milliseconds: 220),
                      child: DecoratedBox(
                        key: ValueKey('gacha-reward-${rewards[index].number}'),
                        decoration: BoxDecoration(
                          // Selection is gameplay feedback, not a replacement frame.
                          color: rewards[index].number == selectedNumber
                              ? GachaColors.paper.withValues(alpha: .45)
                              : null,
                          border: rewards[index].number == selectedNumber
                              ? Border.all(color: GachaColors.paper, width: 2)
                              : null,
                          boxShadow: rewards[index].number == selectedNumber
                              ? [
                                  BoxShadow(
                                    color: GachaColors.paper.withValues(
                                      alpha: .35,
                                    ),
                                    blurRadius: 8,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: RewardIcon(
                            reward: rewards[index],
                            size: width * .18,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        );
      },
    ),
  );
}
