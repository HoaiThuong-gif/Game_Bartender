import '../../../../shared/services/fish_wallet.dart';
import 'rubik_challenge_service.dart';

class RubikRewardService {
  RubikRewardService(this.repository, {FishWallet? wallet})
    : wallet = wallet ?? FishWallet.instance;
  final RubikChallengeRepository repository;
  final FishWallet wallet;
  Future<Set<String>> sync() async {
    // Demo must never mint fish into the shared wallet.
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
