import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Shared local fish balance and deduplicated mini-game reward receipts.
class FishWallet {
  FishWallet({this.initialBalance = 2000, this.persist = true});
  static final instance = FishWallet();
  // Legacy key names retain existing balances and credited Rubik receipts.
  static const storageKey = 'gacha.fish_balance.v1';
  static const accountKey = 'gacha.fish_account.v2';
  final int initialBalance;
  final bool persist;
  int? _balance;
  final Set<String> _credits = {};
  Future<void> _queue = Future.value();
  int get balance => _balance ?? initialBalance;
  Future<void> load() async {
    if (_balance != null) return;
    final account = persist
        ? await SharedPreferencesAsync().getString(accountKey)
        : null;
    if (account != null) {
      final data = jsonDecode(account) as Map<String, dynamic>;
      _balance = (data['balance'] as num).toInt();
      _credits.addAll(List<String>.from(data['credits'] as List));
      return;
    }
    final saved = persist
        ? await SharedPreferencesAsync().getInt(storageKey)
        : null;
    _balance ??= (saved ?? initialBalance).clamp(0, 1 << 31);
  }

  Future<void> _save(int next, Set<String> credits) async {
    if (persist) {
      // Balance and receipt IDs commit in one value, so a crash cannot credit twice.
      await SharedPreferencesAsync().setString(
        accountKey,
        jsonEncode({'balance': next, 'credits': credits.toList()}),
      );
    }
  }

  /// Called only by the challenge receipt adapter after reading backend receipts.
  /// TODO: migrate the whole wallet authority to the backend for production.
  Future<bool> creditChallengeReceipt(String receiptId, int amount) {
    final operation = _queue.then((_) async {
      await load();
      if (_credits.contains(receiptId)) return false;
      if (![0, 10, 25, 50].contains(amount)) throw ArgumentError.value(amount);
      final credits = {..._credits, receiptId};
      final next = (balance + amount).clamp(0, 1 << 31);
      await _save(next, credits);
      _credits.add(receiptId);
      _balance = next;
      return true;
    });
    _queue = operation.then<void>((_) {}, onError: (Object e, StackTrace s) {});
    return operation;
  }
}
