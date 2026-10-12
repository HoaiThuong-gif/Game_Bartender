import 'package:flutter/material.dart';

import '../models/gacha_reward.dart';
import 'gacha_colors.dart';

class RewardIcon extends StatelessWidget {
  const RewardIcon({super.key, required this.reward, required this.size});

  final GachaReward reward;
  final double size;

  @override
  Widget build(BuildContext context) => Image.asset(
    reward.iconAssetPath,
    width: size,
    height: size,
    fit: BoxFit.contain,
    excludeFromSemantics: true,
    errorBuilder: (context, error, stackTrace) => SizedBox.square(
      dimension: size,
      child: Icon(
        Icons.card_giftcard_outlined,
        size: size * 0.6,
        color: GachaColors.ink,
      ),
    ),
  );
}
