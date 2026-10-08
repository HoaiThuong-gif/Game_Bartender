import '../models/gacha_reward.dart';
import '../models/gacha_reward_pool.dart';

const gachaRewardPool = GachaRewardPool(gachaRewards);

// Retained for viewer test fixtures only; never substitute it for a won item.
const gachaBenchmarkModelPath = 'assets/models/gacha/test_item.glb';

const gachaRewards = <GachaReward>[
  GachaReward(
    number: 1,
    name: 'Áo bà ba',
    iconAssetPath: 'assets/images/gacha/icons/ao_ba_ba.png',
    modelAssetPath: 'assets/models/gacha/ao_ba_ba.glb',
  ),
  GachaReward(
    number: 2,
    name: 'Nón lá',
    iconAssetPath: 'assets/images/gacha/icons/non_la.png',
    modelAssetPath: 'assets/models/gacha/non_la.glb',
  ),
  GachaReward(
    number: 3,
    name: 'Khăn rằn',
    iconAssetPath: 'assets/images/gacha/icons/khan_ran.png',
    modelAssetPath: 'assets/models/gacha/khan_ran.glb',
  ),
  GachaReward(
    number: 4,
    name: 'Dép tổ ong',
    iconAssetPath: 'assets/images/gacha/icons/dep_to_ong.png',
    modelAssetPath: 'assets/models/gacha/dep_to_ong.glb',
  ),
  GachaReward(
    number: 5,
    name: 'Mũ tai bèo',
    iconAssetPath: 'assets/images/gacha/icons/non_tai_beo.png',
    modelAssetPath: 'assets/models/gacha/non_tai_beo.glb',
  ),
  GachaReward(
    number: 6,
    name: 'Túi vải',
    iconAssetPath: 'assets/images/gacha/icons/tui_vai.png',
    modelAssetPath: 'assets/models/gacha/tui_vai.glb',
  ),
];
