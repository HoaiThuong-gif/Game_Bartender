import '../../../gacha/services/gacha_wallet.dart';
import 'rubik_challenge_service.dart';

class RubikRewardService {
  RubikRewardService(this.repository, {GachaWallet? wallet})
    : wallet = wallet ?? GachaWallet.instance;
  final RubikChallengeRepository repository;
  final GachaWallet wallet;
  Future<Set<String>> sync() async {
    // Demo must never mint fish into the real Gacha wallet.
    if (repository.demo) return {};
    final receipts = await repository.rewardReceipts();
    for (final entry in receipts.entries) {
      await wallet.creditChallengeReceipt(
        'rubik:${repository.uid}:${entry.key}',
        entry.value,
      );
    }
    return receipts.keys.toSet();
  }
}
