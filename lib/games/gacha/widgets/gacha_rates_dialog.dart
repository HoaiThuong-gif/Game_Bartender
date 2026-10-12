import 'package:flutter/material.dart';

import '../models/gacha_reward_pool.dart';
import 'gacha_colors.dart';
import 'reward_icon.dart';

class GachaRatesDialog extends StatelessWidget {
  const GachaRatesDialog({super.key, required this.pool});

  final GachaRewardPool pool;

  @override
  Widget build(BuildContext context) => Dialog(
    key: const ValueKey('gacha-rates-dialog'),
    backgroundColor: GachaColors.paper,
    insetPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: GachaColors.brick, width: 3),
    ),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 400),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Tỷ lệ nhận vật phẩm',
                    style: TextStyle(
                      color: GachaColors.brick,
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                IconButton(
                  key: const ValueKey('gacha-rates-close'),
                  tooltip: 'Đóng',
                  color: GachaColors.ink,
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close),
                ),
              ],
            ),
            const Divider(color: GachaColors.brick),
            Flexible(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    for (final reward in pool.rewards)
                      Padding(
                        key: ValueKey('gacha-rate-${reward.number}'),
                        padding: const EdgeInsets.symmetric(vertical: 6),
                        child: Row(
                          children: [
                            RewardIcon(reward: reward, size: 44),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                reward.name,
                                style: const TextStyle(
                                  color: GachaColors.ink,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${(pool.probabilityOf(reward) * 100).toStringAsFixed(2)}%',
                              style: const TextStyle(
                                color: GachaColors.brick,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Tỷ lệ được làm tròn đến 2 chữ số thập phân.',
              textAlign: TextAlign.center,
              style: TextStyle(color: GachaColors.ink, fontSize: 12),
            ),
          ],
        ),
      ),
    ),
  );
}
