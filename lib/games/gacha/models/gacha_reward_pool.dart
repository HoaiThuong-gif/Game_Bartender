import 'dart:math';

import 'gacha_reward.dart';

/// The draw policy and its displayed probabilities must stay together.
/// Currently each list slot is equally likely; no rarity or weights are used.
class GachaRewardPool {
  const GachaRewardPool(this.rewards);

  final List<GachaReward> rewards;

  GachaReward draw(Random random) => rewards[random.nextInt(rewards.length)];

  double probabilityOf(GachaReward reward) =>
      rewards.where((entry) => identical(entry, reward)).length /
      rewards.length;
}
